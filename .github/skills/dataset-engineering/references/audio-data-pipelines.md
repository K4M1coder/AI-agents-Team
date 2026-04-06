# Audio Data Pipelines Reference

End-to-end patterns for building audio datasets for training speech AI models.

## Pipeline Overview

```schema
Raw Audio Sources ──▶ Ingestion ──▶ Preprocessing ──▶ Quality Filter ──▶ Segmentation
                                                                            ↓
                                                              Annotation ◀──┘
                                                                 ↓
                                                         Augmentation
                                                                 ↓
                                                     Dataset Packaging (HF / DVC)
```

## Ingestion Patterns

### Source Types

| Source | Format | Typical SR | Notes |
| -------- | -------- | ----------- | ------- |
| Podcast/YouTube | mp3/m4a/webm | 44.1/48 kHz | ffmpeg extract, check license |
| Audiobook | mp3/flac | 22.05/44.1 kHz | LibriSpeech, LibriVox |
| Studio recording | wav/flac | 44.1/48 kHz | Highest quality, controlled |
| Phone/VoIP | opus/amr | 8/16 kHz | Narrow/wideband, noise |
| Field recording | wav | 44.1/48 kHz | Environmental noise |

### Batch Download Pattern

```python
from pathlib import Path
import subprocess

def download_audio(url: str, output_dir: Path, target_sr: int = 24000) -> Path:
    """Download and convert audio to target format."""
    output = output_dir / f"{hash(url)}.wav"
    subprocess.run([
        "ffmpeg", "-i", url,
        "-ar", str(target_sr),
        "-ac", "1",           # mono
        "-sample_fmt", "s16", # 16-bit
        "-y", str(output)
    ], check=True, capture_output=True)
    return output
```

## Preprocessing for Kyutai Models

### Standard Pipeline (Mimi/Moshi compatible)

```python
import torchaudio
import torch
from pathlib import Path

def preprocess_for_mimi(
    input_path: Path,
    output_path: Path,
    target_sr: int = 24000,
    target_lufs: float = -23.0,
):
    """Preprocess audio for Mimi codec / Moshi training."""
    audio, sr = torchaudio.load(input_path)

    # Mono mixdown
    if audio.shape[0] > 1:
        audio = audio.mean(dim=0, keepdim=True)

    # Resample to 24 kHz (Mimi native)
    if sr != target_sr:
        resampler = torchaudio.transforms.Resample(sr, target_sr)
        audio = resampler(audio)

    # Peak normalization (LUFS normalization preferred for production)
    peak = audio.abs().max()
    if peak > 0:
        audio = audio / peak * 0.95

    # Remove DC offset
    audio = audio - audio.mean()

    # Pad to Mimi frame boundary (1920 samples = 80ms)
    hop = 1920
    remainder = audio.shape[-1] % hop
    if remainder:
        audio = torch.nn.functional.pad(audio, (0, hop - remainder))

    torchaudio.save(output_path, audio, target_sr)
```

### LUFS Normalization

```python
import pyloudnorm as pyln

def normalize_lufs(audio, sr, target_lufs=-23.0):
    """ITU-R BS.1770 loudness normalization."""
    meter = pyln.Meter(sr)
    loudness = meter.integrated_loudness(audio.numpy())
    normalized = pyln.normalize.loudness(audio.numpy(), loudness, target_lufs)
    return torch.from_numpy(normalized)
```

## Quality Filtering

### Automated Quality Gates

```python
import torch
import torchaudio
import numpy as np

def quality_check(audio: torch.Tensor, sr: int) -> dict:
    """Run quality checks on audio sample."""
    checks = {}

    # 1. Duration check (5s - 30s for training)
    duration = audio.shape[-1] / sr
    checks["duration_ok"] = 5.0 <= duration <= 30.0
    checks["duration_s"] = round(duration, 2)

    # 2. SNR estimation (simple energy-based)
    frame_energy = audio.unfold(-1, sr // 10, sr // 20).pow(2).mean(-1)
    noise_floor = frame_energy.quantile(0.1)
    signal_peak = frame_energy.quantile(0.9)
    snr_db = 10 * torch.log10(signal_peak / (noise_floor + 1e-10))
    checks["snr_db"] = round(snr_db.item(), 1)
    checks["snr_ok"] = snr_db.item() > 10  # Minimum 10 dB SNR

    # 3. Clipping detection
    clip_ratio = (audio.abs() > 0.99).float().mean().item()
    checks["clip_ratio"] = round(clip_ratio, 4)
    checks["clipping_ok"] = clip_ratio < 0.01  # < 1% clipped samples

    # 4. Silence ratio (VAD-based preferred, energy-based fallback)
    silence_ratio = (frame_energy < noise_floor * 2).float().mean().item()
    checks["silence_ratio"] = round(silence_ratio, 2)
    checks["silence_ok"] = silence_ratio < 0.5  # < 50% silence

    # 5. Sample rate check
    checks["sr_ok"] = sr >= 16000

    checks["pass"] = all(checks[k] for k in checks if k.endswith("_ok"))
    return checks
```

### Quality Tiers

| Tier | SNR | Clipping | Silence | Use Case |
| ------ | ----- | ---------- | --------- | ---------- |
| **A (Studio)** | > 30 dB | < 0.1% | < 10% | TTS training, codec evaluation |
| **B (Clean)** | > 20 dB | < 0.5% | < 20% | ASR training, fine-tuning |
| **C (Noisy)** | > 10 dB | < 1% | < 30% | Robust ASR, noise augmentation |
| **D (Reject)** | < 10 dB | > 1% | > 50% | Discard or heavy preprocessing |

## Segmentation

### VAD-Based Segmentation

```python
import torch

def segment_with_vad(
    audio: torch.Tensor,
    sr: int = 16000,
    min_duration_ms: int = 3000,
    max_duration_ms: int = 30000,
    min_silence_ms: int = 300,
) -> list[dict]:
    """Segment audio using Silero VAD."""
    model, utils = torch.hub.load('snakers4/silero-vad', 'silero_vad')
    get_speech_timestamps, _, _, _, _ = utils

    timestamps = get_speech_timestamps(
        audio.squeeze(),
        model,
        sampling_rate=sr,
        threshold=0.5,
        min_speech_duration_ms=min_duration_ms,
        min_silence_duration_ms=min_silence_ms,
    )

    # Merge short segments, split long ones
    segments = []
    for ts in timestamps:
        duration_ms = (ts['end'] - ts['start']) / sr * 1000
        if duration_ms > max_duration_ms:
            # Split at silence points within the segment
            for sub_start in range(ts['start'], ts['end'], int(max_duration_ms * sr / 1000)):
                sub_end = min(sub_start + int(max_duration_ms * sr / 1000), ts['end'])
                segments.append({'start': sub_start, 'end': sub_end})
        else:
            segments.append(ts)

    return segments
```

### Speaker Diarization + Segmentation

```python
# pyannote.audio pipeline for speaker-aware segmentation
from pyannote.audio import Pipeline

pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1")
diarization = pipeline("audio.wav")

# Extract per-speaker segments
for turn, _, speaker in diarization.itertracks(yield_label=True):
    print(f"Speaker {speaker}: {turn.start:.1f}s - {turn.end:.1f}s")
```

## Audio Augmentation for Training

### Common Augmentations

| Augmentation | Range | Purpose |
| ------------- | ------- | --------- |
| **Speed perturbation** | 0.9-1.1x | Tempo invariance |
| **Pitch shift** | ±2 semitones | Pitch invariance |
| **Additive noise** | SNR 10-30 dB | Noise robustness |
| **Room impulse response** | Small-large rooms | Reverb robustness |
| **Volume perturbation** | ±6 dB | Level invariance |
| **Codec simulation** | mp3/opus | Compression artifacts |
| **Telephone band** | 300-3400 Hz | Narrow-band robustness |

### Implementation with torch-audiomentations

```python
from torch_audiomentations import (
    Compose, Gain, PolarityInversion,
    AddColoredNoise, HighPassFilter, LowPassFilter
)

augment = Compose([
    Gain(min_gain_in_db=-6.0, max_gain_in_db=6.0, p=0.5),
    AddColoredNoise(min_snr_in_db=10, max_snr_in_db=30, p=0.3),
    HighPassFilter(min_cutoff_freq=80, max_cutoff_freq=400, p=0.3),
    LowPassFilter(min_cutoff_freq=3000, max_cutoff_freq=7500, p=0.2),
])

augmented = augment(audio.unsqueeze(0), sample_rate=24000)
```

## Dataset Packaging

### Kyutai TTS JSONL Format

Based on `moshi/data/tts.jsonl`:

```jsonl
{"audio_path": "data/train/utt_0001.wav", "text": "Hello, how are you?", "speaker_id": "spk_001", "duration": 3.2}
{"audio_path": "data/train/utt_0002.wav", "text": "I am doing well.", "speaker_id": "spk_001", "duration": 2.1}
```

### HuggingFace Datasets Format

```python
from datasets import Dataset, Audio

dataset = Dataset.from_dict({
    "audio": audio_paths,
    "text": transcriptions,
    "speaker_id": speaker_ids,
}).cast_column("audio", Audio(sampling_rate=24000))

dataset.push_to_hub("your-org/dataset-name", private=True)
```

### DVC Versioning

```bash
# Track large audio directories
dvc add data/audio/train/
dvc add data/audio/test/

# Push to remote storage
dvc push

# Reproduce pipeline
dvc repro
```

## Dataset Statistics Report

After building a dataset, always report:

```markdown
## Dataset Card

| Metric | Value |
| -------- | ------- |
| Total hours | XX h |
| Total utterances | XX,XXX |
| Unique speakers | XXX |
| Languages | en, fr, ... |
| Sample rate | 24,000 Hz |
| Mean duration | X.X s |
| Min/Max duration | X.X / XX.X s |
| SNR (mean ± std) | XX.X ± X.X dB |
| Silence ratio (mean) | X.X% |
| Quality tier A/B/C/D | XX% / XX% / XX% / XX% |
```
