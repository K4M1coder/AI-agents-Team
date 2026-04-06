# Audio & Speech Metrics Reference

Comprehensive guide to objective and subjective audio quality metrics.

## Objective Speech Quality Metrics

### PESQ (Perceptual Evaluation of Speech Quality)

| Property | Value |
| ---------- | ------- |
| **Standard** | ITU-T P.862 |
| **Range** | -0.5 to 4.5 (MOS-LQO scale) |
| **Input** | Reference + degraded audio (same length, aligned) |
| **Sample Rate** | 8 kHz (narrowband) or 16 kHz (wideband) |
| **Use Case** | Codec quality, network degradation |

```python
from pesq import pesq

# Wideband PESQ (16 kHz)
score = pesq(16000, ref_audio, degraded_audio, 'wb')
# Narrowband PESQ (8 kHz)
score = pesq(8000, ref_audio, degraded_audio, 'nb')
```

**Interpretation:**

| Score | Quality |
| ------- | --------- |
| > 4.0 | Excellent (transparent) |
| 3.5-4.0 | Good |
| 3.0-3.5 | Fair |
| 2.5-3.0 | Poor |
| < 2.5 | Bad |

### POLQA (ITU-T P.863)

Successor to PESQ, supports super-wideband (48 kHz) and better handles:

- Temporal stretching (TTS)
- Time-varying degradations
- High quality codecs

Not freely available (licensed by OPTICOM/Swissqual).

### STOI (Short-Time Objective Intelligibility)

| Property | Value |
| ---------- | ------- |
| **Range** | 0 to 1 |
| **Input** | Reference + degraded (same sample rate) |
| **Use Case** | Speech intelligibility prediction |

```python
from pystoi import stoi

score = stoi(ref_audio, degraded_audio, sr, extended=False)
# Extended STOI (eSTOI) for better correlation with listening tests:
score = stoi(ref_audio, degraded_audio, sr, extended=True)
```

**Interpretation:**

| Score | Intelligibility |
| ------- | ---------------- |
| > 0.92 | Fully intelligible |
| 0.85-0.92 | Good |
| 0.75-0.85 | Fair (some effort) |
| 0.60-0.75 | Poor |
| < 0.60 | Unintelligible |

### SI-SDR / SI-SNR (Scale-Invariant Signal-to-Distortion Ratio)

| Property | Value |
| ---------- | ------- |
| **Range** | -∞ to +∞ dB (higher = better) |
| **Input** | Reference + estimated signal |
| **Use Case** | Source separation, codec reconstruction |

```python
import torch
from torchmetrics.audio import ScaleInvariantSignalDistortionRatio

si_sdr = ScaleInvariantSignalDistortionRatio()
score = si_sdr(estimated, reference)  # in dB
```

**Interpretation:**

| Score (dB) | Quality |
| ----------- | --------- |
| > 20 | Excellent |
| 15-20 | Good |
| 10-15 | Fair |
| 5-10 | Poor |
| < 5 | Bad |

## Subjective Metrics

### MOS (Mean Opinion Score)

**Protocol (ITU-T P.800):**

1. Select ≥20 native-language listeners (balanced gender, age)
2. Present stimuli in randomized order, one at a time
3. Rate on 5-point scale:
   - 5: Excellent
   - 4: Good
   - 3: Fair
   - 2: Poor
   - 1: Bad
4. Report mean ± 95% CI per condition
5. Screen listeners: remove outliers (> 2 SD from mean on anchors)

**Proxy MOS (automated):**

| Model | Source | Correlation with MOS |
| ------- | -------- | --------------------- |
| **UTMOS** | UTMOS22 (sarulab-speech) | ρ ≈ 0.91 |
| **DNSMOS** | Microsoft DNS Challenge | ρ ≈ 0.94 (for noise) |
| **NISQA** | TU Ilmenau | ρ ≈ 0.89 |
| **MOSNet** | Original MOS predictor | ρ ≈ 0.85 |

### MUSHRA (Multi-Stimulus with Hidden Reference and Anchor)

Used for codec comparison. Rate each condition 0-100 against a hidden reference.

## ASR Metrics

### WER (Word Error Rate)

```text formula
WER = (S + D + I) / N

S = substitutions, D = deletions, I = insertions, N = total reference words
```

```python
import jiwer

wer = jiwer.wer(reference_text, hypothesis_text)
cer = jiwer.cer(reference_text, hypothesis_text)
```

**Thresholds (English, clean speech):**

| WER | Quality |
| ----- | --------- |
| < 3% | State-of-the-art |
| 3-8% | Good |
| 8-15% | Acceptable |
| > 15% | Needs improvement |

### CER (Character Error Rate)

Same formula as WER but at character level. Useful for:

- Languages without clear word boundaries (Chinese, Japanese)
- Assessing fine-grained errors

## Speaker & Prosody Metrics

### Speaker Similarity

```python
# ECAPA-TDNN speaker embeddings
from speechbrain.inference.speaker import EncoderClassifier

encoder = EncoderClassifier.from_hparams(source="speechbrain/spkrec-ecapa-voxceleb")
emb_ref = encoder.encode_batch(ref_audio)
emb_syn = encoder.encode_batch(syn_audio)

similarity = torch.nn.functional.cosine_similarity(emb_ref, emb_syn)
# > 0.85 = same speaker, > 0.92 = very similar
```

### F0 (Pitch) Metrics

| Metric | Description | Tool |
| -------- | ------------- | ------ |
| F0 RMSE | Root mean square error in Hz | CREPE, WORLD |
| F0 Pearson | Correlation of F0 contours | |
| V/UV accuracy | Voiced/unvoiced classification | |
| GPE | Gross Pitch Error (> 20% deviation) | |

### Prosody Metrics (TTS)

- **Duration RMSE**: Phone/word duration accuracy
- **Energy correlation**: Volume contour similarity
- **Speaking rate**: Words per minute comparison
- **Pause accuracy**: Correct placement and duration of pauses

## Metric Selection Guide

| Task | Primary Metrics | Secondary |
| ------ | --------------- | ----------- |
| **Codec evaluation** | PESQ, STOI, SI-SDR | MOS, MUSHRA |
| **TTS quality** | MOS (or UTMOS), WER | Speaker sim, F0 RMSE |
| **ASR quality** | WER, CER | |
| **Voice conversion** | Speaker sim, MOS | PESQ, F0 accuracy |
| **Speech enhancement** | PESQ, SI-SDR, STOI | DNSMOS |
| **S2ST (Hibiki)** | BLEU, WER, MOS, speaker sim | Latency |
| **Dialogue (Moshi)** | Response quality (MOS), latency, WER | Turn-taking accuracy |

## Evaluation Script Template

```python
"""Audio quality evaluation pipeline."""
import json
from pathlib import Path
from pesq import pesq
from pystoi import stoi
import jiwer
import numpy as np
import soundfile as sf

def evaluate_codec(ref_dir: Path, deg_dir: Path, sr: int = 16000) -> dict:
    """Evaluate codec quality on a test set."""
    results = {"pesq": [], "stoi": [], "si_sdr": []}

    for ref_path in sorted(ref_dir.glob("*.wav")):
        deg_path = deg_dir / ref_path.name
        if not deg_path.exists():
            continue

        ref, _ = sf.read(ref_path)
        deg, _ = sf.read(deg_path)

        # Align lengths
        min_len = min(len(ref), len(deg))
        ref, deg = ref[:min_len], deg[:min_len]

        results["pesq"].append(pesq(sr, ref, deg, 'wb'))
        results["stoi"].append(stoi(ref, deg, sr))

    return {k: {"mean": np.mean(v), "std": np.std(v)} for k, v in results.items()}

if __name__ == "__main__":
    metrics = evaluate_codec(Path("test/reference"), Path("test/degraded"))
    print(json.dumps(metrics, indent=2))
```text
