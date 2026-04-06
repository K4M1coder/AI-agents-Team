---
name: audio-speech-engineering
description: "**WORKFLOW SKILL** — Audio & speech engineering: neural audio codecs (Mimi, EnCodec, RVQ), speech quality metrics (MOS, PESQ, STOI, WER), streaming audio (WebSocket, ring buffers), VAD, diarization, TTS/ASR evaluation, acoustic features. USE FOR: audio pipeline design, codec integration, speech quality evaluation, real-time streaming, audio preprocessing. USE WHEN: working with audio models, evaluating speech quality, designing streaming pipelines, integrating Mimi codec."
argument-hint: "Describe the audio/speech task: codec integration, quality evaluation, streaming pipeline, or preprocessing"
---

# Audio & Speech Engineering

Design, implement, and evaluate audio processing pipelines for speech AI systems.

## When to Use

- Integrating or configuring a neural audio codec (Mimi, EnCodec, DAC)
- Evaluating speech quality (MOS, PESQ, STOI, WER)
- Designing real-time audio streaming pipelines (WebSocket, ring buffers)
- Preprocessing audio data (resampling, VAD, normalization, segmentation)
- Implementing TTS or ASR evaluation workflows
- Working with Kyutai open-source audio projects as integrator/operator (Moshi, Mimi, Hibiki, Pocket-TTS)

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Neural Audio Codec** | Encodes audio to discrete tokens at low bitrate (Mimi: 1.1 kbps) |
| **RVQ** | Residual Vector Quantization — multi-codebook compression |
| **Frame Rate** | Codec output rate (Mimi: 12.5 Hz = 80ms per frame) |
| **MOS** | Mean Opinion Score — perceptual quality (1-5 scale) |
| **PESQ** | Perceptual Evaluation of Speech Quality (ITU-T P.862) |
| **STOI** | Short-Time Objective Intelligibility |
| **VAD** | Voice Activity Detection — segment speech vs silence |
| **LUFS** | Loudness Units Full Scale — standard loudness normalization |
| **Mel Spectrogram** | Time-frequency representation for audio ML |
| **SI-SDR** | Scale-Invariant Signal-to-Distortion Ratio |

## Procedure

### Phase 1: Requirements

1. **Define** audio constraints: sample rate (24 kHz for Mimi), channels (mono), bit depth
2. **Set** quality targets: minimum PESQ, STOI, WER threshold
3. **Determine** latency budget: codec + network + inference + decode
4. **Identify** downstream task: TTS, ASR, dialogue, translation, codec-only

### Phase 2: Audio Preprocessing

1. **Resample** to target rate (24 kHz for Mimi/Moshi, torchaudio or librosa)
2. **Normalize** loudness (LUFS -23 for broadcast, -16 for voice)
3. **VAD** to detect speech segments (Silero VAD recommended, WebRTC for low latency)
4. **Segment** into chunks (5-30s for training, frame-aligned for streaming)
5. **Filter** low-quality samples (SNR < 10 dB, clipping detection, silence ratio)

### Phase 3: Codec Integration

Choose codec based on requirements:

| Codec | Sample Rate | Frame Rate | Bitrate | RVQ Books | Streaming |
| ------- | ------------ | ------------ | --------- | ----------- | ----------- |
| **Mimi** | 24 kHz | 12.5 Hz | 1.1 kbps | 8 | ✅ Causal |
| **EnCodec** | 24/48 kHz | 75 Hz | 1.5-24 kbps | 2-32 | ✅ Causal mode |
| **DAC** | 16-44.1 kHz | 86 Hz | 8+ kbps | 9-12 | ❌ |
| **SoundStream** | 16 kHz | 50 Hz | 3-18 kbps | 4-8 | ✅ |

**Mimi integration (Kyutai standard):**
```python
import torch
from moshi.mimi import MimiCodec

codec = MimiCodec.from_pretrained("kyutai/mimi")
codec.eval()

# Encode: audio (B, 1, T) → codes (B, 8, S) at 12.5 Hz
with torch.no_grad():
    codes = codec.encode(audio_24khz)

# Decode: codes → reconstructed audio
reconstructed = codec.decode(codes)
```

### Phase 4: Streaming Pipeline

```text
icrophone → Resample (24kHz) → Frame buffer (80ms = 1920 samples)
                                        ↓
                              Mimi Encode → [8 codes per frame]
                                        ↓
                              WebSocket send (binary, 8 bytes/frame)
                                        ↓ (server)
                              Model inference (text + audio tokens)
                                        ↓
                              Mimi Decode → Playback buffer → Speaker
```

Key parameters:
- **Chunk size**: 1920 samples = 80ms at 24 kHz = 1 Mimi frame
- **Buffer**: 3-5 frames look-ahead for jitter compensation
- **Protocol**: Binary WebSocket, little-endian uint16 codes
- **Heartbeat**: Ping every 5s, reconnect on 3 missed pongs

### Phase 5: Quality Evaluation

Run on held-out test set (≥100 utterances, diverse speakers):

```python
from pesq import pesq
from pystoi import stoi

# Objective metrics
pesq_score = pesq(16000, ref_16k, deg_16k, 'wb')  # -0.5 to 4.5
stoi_score = stoi(ref_16k, deg_16k, 16000)  # 0 to 1

# Proxy MOS (no human listeners needed)
# UTMOS: https://github.com/sarulab-speech/UTMOS22
mos_proxy = utmos_model.predict(audio_16k)
```

**Quality checklist:**
- [ ] PESQ > 3.0 (wideband)
- [ ] STOI > 0.85
- [ ] SI-SDR > 10 dB
- [ ] WER degradation < 2% vs uncompressed
- [ ] Speaker similarity > 0.85 (ECAPA-TDNN cosine)
- [ ] No audible artifacts (clicks, buzzing, metallic)
- [ ] Latency < target (measure end-to-end)

## Kyutai Project Reference Files

| Resource | Location | Content |
| ---------- | ---------- | --------- |
| TTS data format | `moshi/data/tts.jsonl` | JSONL with audio paths and metadata |
| Mimi streaming test | `scripts/mimi_streaming_test.py` | Streaming encode/decode validation |
| Mimi MLX | `scripts/mimi_mlx.py` | MLX backend for Mimi codec |
| Pocket-TTS tests | `pocket-tts/tests/` | TTS evaluation patterns |
| Moshi benchmark | `scripts/moshi_benchmark.py` | Performance profiling |
| Unmute voices | `unmute/voices.yaml` | Voice configuration for TTS serving |

## Common Issues

| Symptom | Cause | Fix |
| --------- | ------- | ----- |
| Metallic/robotic audio | RVQ codebook collapse | Retrain with commitment loss, EMA codebook update |
| Clicking at chunk boundaries | Misaligned frames | Ensure chunk = multiple of hop_length, use crossfade |
| High WER after codec | Information loss | Increase bitrate (more RVQ books), check sample rate |
| Inconsistent loudness | No normalization | Apply LUFS normalization before encoding |
| Speaker identity drift | Poor codec fidelity | Verify speaker similarity metric, fine-tune codec |
| Audio cuts out | WebSocket frame drops | Implement jitter buffer, retry logic, FEC |
