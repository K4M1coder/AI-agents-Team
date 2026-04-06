# Neural Audio Codec Patterns Reference

Architecture patterns, integration guides, and best practices for neural audio codecs.

## Codec Architecture Overview

### General Architecture

```text schema
┌─────────────────────────────────────────────────────────┐
│                  Neural Audio Codec                      │
│                                                          │
│  Audio ──▶ [Encoder] ──▶ [Quantizer (RVQ)] ──▶ Tokens   │
│                              ↕                           │
│  Audio ◀── [Decoder] ◀── [Dequantizer] ◀───── Tokens    │
│                                                          │
│  Training losses:                                        │
│  - Reconstruction (L1/L2 on mel spectrogram)             │
│  - Adversarial (multi-scale/multi-period discriminator)  │
│  - VQ commitment + codebook diversity                    │
│  - Feature matching                                      │
└─────────────────────────────────────────────────────────┘
```

### RVQ (Residual Vector Quantization)

```text schema
Input z ──▶ VQ₁(z) = z₁, residual r₁ = z - z₁
            VQ₂(r₁) = z₂, residual r₂ = r₁ - z₂
            VQ₃(r₂) = z₃, residual r₃ = r₂ - z₃
            ...
            VQₖ(rₖ₋₁) = zₖ

Reconstructed: ẑ = z₁ + z₂ + z₃ + ... + zₖ
```

**Key parameters:**

- `n_codebooks`: Number of RVQ levels (Mimi: 8)
- `codebook_size`: Entries per codebook (typically 1024 or 2048)
- `codebook_dim`: Dimension of each codebook entry

**Codebook collapse prevention:**

- EMA (Exponential Moving Average) codebook update
- Codebook reset for unused entries
- Commitment loss weight tuning (β = 0.25 typical)
- Random restart for dead codes (usage < threshold)

## Mimi Codec (Kyutai)

### Specifications

| Parameter | Value |
| ----------- | ------- |
| Sample rate | 24,000 Hz |
| Frame rate | 12.5 Hz (80ms per frame) |
| Hop length | 1,920 samples |
| Bitrate | ~1.1 kbps |
| RVQ codebooks | 8 |
| Codebook size | 2,048 entries |
| Encoder | Causal convolutional |
| Decoder | Causal convolutional |
| Latent dim | 256 |
| Streaming | ✅ Fully causal (no look-ahead) |

### Streaming Encode/Decode Pattern

```python
import torch
from moshi.mimi import MimiCodec

codec = MimiCodec.from_pretrained("kyutai/mimi")
codec.eval()
codec.set_num_codebooks(8)

# Streaming mode
CHUNK_SIZE = 1920  # 80ms at 24kHz = 1 frame

def stream_encode(audio_stream):
    """Encode audio chunks one frame at a time."""
    for chunk in audio_stream:
        # chunk shape: (1, 1, 1920)
        with torch.no_grad():
            codes = codec.encode(chunk)  # (1, 8, 1)
        yield codes

def stream_decode(code_stream):
    """Decode code chunks one frame at a time."""
    for codes in code_stream:
        # codes shape: (1, 8, 1)
        with torch.no_grad():
            audio = codec.decode(codes)  # (1, 1, 1920)
        yield audio
```

### Batch Encode/Decode Pattern

```python
# Full file encode/decode
audio, sr = torchaudio.load("input.wav")
if sr != 24000:
    audio = torchaudio.transforms.Resample(sr, 24000)(audio)

# Pad to frame boundary
remainder = audio.shape[-1] % 1920
if remainder:
    audio = torch.nn.functional.pad(audio, (0, 1920 - remainder))

audio = audio.unsqueeze(0)  # (1, 1, T)

with torch.no_grad():
    codes = codec.encode(audio)   # (1, 8, S)
    recon = codec.decode(codes)   # (1, 1, T)
```

## EnCodec (Meta)

### EnCodec Specifications

| Parameter | 24 kHz | 48 kHz |
| ----------- | -------- | -------- |
| Sample rate | 24,000 Hz | 48,000 Hz |
| Frame rate | 75 Hz | 75 Hz |
| Hop length | 320 | 640 |
| Bandwidth modes | 1.5/3/6/12/24 kbps | 3/6/12/24 kbps |
| RVQ codebooks | 2-32 (bandwidth-dependent) | 4-32 |
| Streaming | ✅ (causal mode) | ✅ (causal mode) |

### Integration Pattern

```python
from encodec import EncodecModel
from encodec.utils import convert_audio

model = EncodecModel.encodec_model_24khz()
model.set_target_bandwidth(6.0)  # kbps

audio, sr = torchaudio.load("input.wav")
audio = convert_audio(audio, sr, model.sample_rate, model.channels)
audio = audio.unsqueeze(0)

with torch.no_grad():
    frames = model.encode(audio)
    recon = model.decode(frames)
```

## DAC (Descript Audio Codec)

### DAC Specifications

| Parameter | Value |
| ----------- | ------- |
| Sample rates | 16, 24, 44.1 kHz |
| Frame rate | ~86 Hz (varies by sr) |
| Quality | Higher fidelity than EnCodec at same bitrate |
| RVQ codebooks | 9-12 |
| Streaming | ❌ Non-causal |

### DAC Integration Pattern

```python
import dac

model = dac.DAC.load(dac.utils.download(model_type="44khz"))
audio = dac.AudioSignal("input.wav")

with torch.no_grad():
    compressed = model.compress(audio)
    recon = model.decompress(compressed)
```

## WebSocket Audio Streaming Protocol

### Client → Server (Audio)

```text
Frame format (binary):
┌──────────────┬───────────────────────┐
│ Header (1B)  │ Payload               │
│ 0x01 = audio │ PCM int16 LE samples  │
│ 0x02 = codes │ uint16 codes × 8      │
│ 0xFF = end   │ (empty)               │
└──────────────┴───────────────────────┘
```

### Jitter Buffer Implementation

```python
import collections
import threading

class JitterBuffer:
    """Ring buffer for smooth audio playback despite network jitter."""

    def __init__(self, capacity: int = 5, frame_size: int = 1920):
        self.buffer = collections.deque(maxlen=capacity)
        self.frame_size = frame_size
        self.lock = threading.Lock()
        self._underrun_count = 0

    def push(self, frame):
        with self.lock:
            self.buffer.append(frame)

    def pop(self):
        with self.lock:
            if self.buffer:
                return self.buffer.popleft()
            self._underrun_count += 1
            return None  # Underrun: generate silence

    @property
    def fill_level(self):
        return len(self.buffer)

    @property
    def underrun_count(self):
        return self._underrun_count
```

## Audio Preprocessing Pipeline

### Standard Pipeline (for Mimi/Moshi)

```python
import torchaudio
import torch

def preprocess_audio(
    path: str,
    target_sr: int = 24000,
    target_lufs: float = -23.0,
    vad_threshold: float = 0.5,
) -> torch.Tensor:
    """Standard Kyutai audio preprocessing."""
    audio, sr = torchaudio.load(path)

    # 1. Mono
    if audio.shape[0] > 1:
        audio = audio.mean(dim=0, keepdim=True)

    # 2. Resample
    if sr != target_sr:
        audio = torchaudio.transforms.Resample(sr, target_sr)(audio)

    # 3. Normalize loudness (simplified peak norm)
    audio = audio / (audio.abs().max() + 1e-8) * 0.95

    # 4. Pad to frame boundary (1920 samples for Mimi)
    hop = 1920
    remainder = audio.shape[-1] % hop
    if remainder:
        audio = torch.nn.functional.pad(audio, (0, hop - remainder))

    return audio
```

### VAD Segmentation

```python
# Silero VAD — recommended for Kyutai open-source audio pipelines (Moshi/Pocket-TTS)
model, utils = torch.hub.load('snakers4/silero-vad', 'silero_vad')
get_speech_timestamps, _, _, _, _ = utils

speech_timestamps = get_speech_timestamps(
    audio,
    model,
    sampling_rate=16000,
    threshold=0.5,
    min_speech_duration_ms=250,
    min_silence_duration_ms=300,
)
# Returns: [{'start': 1000, 'end': 5000}, ...]
```

## Quality vs Bitrate Trade-offs

```schema
Quality (PESQ)
  4.5 ┤
      │                                    *** DAC 8kbps
  4.0 ┤                          *** EnCodec 6kbps
      │                    ***
  3.5 ┤              *** Mimi 1.1kbps
      │         ***
  3.0 ┤    *** EnCodec 1.5kbps
      │***
  2.5 ┤
      └──┬──────┬──────┬──────┬──────┬──
         1     3      6     12     24   kbps
```

Mimi achieves competitive quality at 1.1 kbps through:

- Semantic + acoustic token decomposition
- Larger receptive field (causal convolutions)
- Training on diverse speech data
