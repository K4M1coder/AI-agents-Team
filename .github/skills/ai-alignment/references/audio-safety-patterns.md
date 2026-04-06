# Audio Safety Patterns Reference

Safety evaluation and mitigation patterns for audio and speech AI systems.

## Threat Taxonomy

### Audio-Specific Risks

| Risk | Description | Severity |
| ------ | ------------- | ---------- |
| **Voice cloning / deepfake** | Unauthorized replication of a person's voice | Critical |
| **Harmful content generation** | TTS generating threats, hate speech, etc. | Critical |
| **Speaker impersonation** | Generating audio that sounds like a specific person | High |
| **Biometric spoofing** | Bypassing voice-based authentication | High |
| **Privacy leakage** | Model memorizing and reproducing training data | High |
| **Bias in voice** | Accent, gender, age bias in ASR/TTS quality | Medium |
| **Consent violation** | Using voice data without speaker consent | Critical |
| **Misinformation audio** | Generating realistic fake news audio | High |

## Evaluation Framework

### Audio Safety Benchmark Suite

```python
"""Audio safety evaluation pipeline."""

class AudioSafetyEvaluator:
    """Evaluate audio model for safety risks."""

    def __init__(self, model):
        self.model = model
        self.results = {}

    def eval_voice_consent(self, test_speakers: list[str]) -> dict:
        """Verify model cannot clone non-consented voices."""
        # Test with known non-consented speaker embeddings
        # Model should refuse or degrade quality significantly
        pass

    def eval_content_safety(self, harmful_prompts: list[str]) -> dict:
        """Test refusal of harmful text-to-speech requests."""
        # Categories: threats, hate speech, impersonation requests
        # Expected: model refuses or generates safe alternative
        pass

    def eval_watermark_robustness(self, attacks: list[str]) -> dict:
        """Test audio watermark survival under attacks."""
        # Attacks: compression, resampling, cropping, noise addition
        pass

    def eval_bias(self, demographic_groups: dict) -> dict:
        """Measure quality disparity across demographics."""
        # Compare WER, MOS across accent, gender, age groups
        pass
```

### Safety Metrics

| Metric | Target | Method |
| -------- | -------- | -------- |
| **Harmful content refusal rate** | > 99% | Test with curated harmful prompts |
| **Watermark detection rate** | > 95% after attacks | AudioSeal or custom |
| **Voice consent compliance** | 100% | Only generate consented voices |
| **ASR WER bias gap** | < 3% across demographics | Compare across groups |
| **TTS MOS bias gap** | < 0.3 across demographics | Compare naturalness scores |
| **Memorization rate** | < 0.1% | Membership inference test |

## Voice Consent Framework

### Consent Verification Pipeline

```text
Speaker registers ──▶ Record consent audio (≥30s)
                              ↓
                    Extract speaker embedding (ECAPA-TDNN)
                              ↓
                    Store in consented speaker registry
                              ↓
    TTS Request ──▶ Compare requested voice vs registry
                              ↓
                    Match? ──▶ Generate audio + watermark
                    No match? ──▶ Refuse or use default voice
```

### Implementation

```python
import torch
from speechbrain.inference.speaker import EncoderClassifier

class VoiceConsentChecker:
    """Verify voice consent before TTS generation."""

    SIMILARITY_THRESHOLD = 0.75  # Cosine similarity

    def __init__(self, consent_registry_path: str):
        self.encoder = EncoderClassifier.from_hparams(
            source="speechbrain/spkrec-ecapa-voxceleb"
        )
        self.consented_embeddings = self._load_registry(consent_registry_path)

    def is_consented(self, target_embedding: torch.Tensor) -> bool:
        """Check if target voice matches any consented speaker."""
        for name, emb in self.consented_embeddings.items():
            sim = torch.nn.functional.cosine_similarity(
                target_embedding, emb, dim=-1
            )
            if sim > self.SIMILARITY_THRESHOLD:
                return True
        return False

    def _load_registry(self, path: str) -> dict:
        """Load consented speaker embeddings."""
        return torch.load(path, weights_only=True)
```

## Audio Watermarking

### AudioSeal (Meta)

Proactive watermarking for AI-generated speech detection.

```python
# Detection-only (common pattern)
from audioseal import AudioSeal

detector = AudioSeal.load_detector("audioseal_detector_16bits")

# Detect watermark in audio
result, message = detector.detect_watermark(audio_16khz)
# result > 0.5 → watermarked (AI-generated)
```

### Watermark Robustness Requirements

| Attack | Watermark Must Survive |
| -------- | ---------------------- |
| MP3 compression (128 kbps) | ✅ |
| Opus compression (32 kbps) | ✅ |
| Resampling (24→16→24 kHz) | ✅ |
| Gaussian noise (SNR 20 dB) | ✅ |
| Volume change (±10 dB) | ✅ |
| Cropping (remove 10%) | ✅ |
| Speed change (±5%) | ⚠️ Best effort |
| Adversarial attack | ⚠️ Best effort |

## Bias Evaluation

### ASR Bias Audit

Compare WER across demographic groups:

```python
def audit_asr_bias(model, test_sets: dict[str, list]) -> dict:
    """Compute WER per demographic group."""
    import jiwer
    results = {}

    for group_name, samples in test_sets.items():
        wers = []
        for audio, reference in samples:
            hypothesis = model.transcribe(audio)
            wers.append(jiwer.wer(reference, hypothesis))
        results[group_name] = {
            "mean_wer": sum(wers) / len(wers),
            "std_wer": (sum((w - sum(wers)/len(wers))**2 for w in wers) / len(wers)) ** 0.5,
            "n_samples": len(wers),
        }

    # Flag bias if max gap > 3%
    wer_values = [r["mean_wer"] for r in results.values()]
    results["_bias_gap"] = max(wer_values) - min(wer_values)
    results["_bias_flag"] = results["_bias_gap"] > 0.03

    return results
```

### Demographic Groups to Test

| Dimension | Groups |
| ----------- | -------- |
| **Accent** | Native, non-native (L1 categories), regional dialects |
| **Gender** | Male, female, non-binary |
| **Age** | Youth (< 18), adult (18-65), elderly (> 65) |
| **Speaking style** | Read speech, spontaneous, whispered, emotional |
| **Language** | Per supported language (en, fr for Kyutai) |
| **Noise conditions** | Clean, mild noise, heavy noise |

## Content Safety for TTS

### Text Filtering Before Synthesis

```python
import re

# Categories of harmful content to block
BLOCKED_PATTERNS = [
    # These are pattern categories — implement with proper NLP classifier
    "threat_patterns",
    "impersonation_patterns",
    "misinformation_markers",
]

def is_safe_for_synthesis(text: str) -> tuple[bool, str]:
    """Check if text is safe to synthesize."""
    # Use a content classifier (not regex) in production
    # Example: OpenAI moderation API, Perspective API, or custom classifier
    # Return (is_safe, reason_if_blocked)
    pass
```

### Voice Impersonation Prevention

```text
TTS Request: "Generate {public_figure_name} saying..."
                              ↓
Check if voice target is a public figure / non-consented person
                              ↓
    Detected? ──▶ Block request, log attempt
    Not detected? ──▶ Proceed with consent check
```

## Kyutai Open-Source Reference — Safety Context

### Moshi Dialogue Safety

| Concern | Mitigation |
| --------- | ----------- |
| Harmful dialogue responses | Content classifier on text output before TTS |
| Voice cloning through dialogue | Fixed voice identity, no voice cloning feature |
| User audio privacy | No audio storage by default, local processing option |
| Deepfake generation | Watermark all generated audio |

### Pocket-TTS / Unmute Safety

| Concern | Mitigation |
| --------- | ----------- |
| Unauthorized voice cloning | Voice consent registry in `voices.yaml` |
| API abuse for deepfakes | Rate limiting, usage logging, terms of service |
| Harmful TTS content | Text content filter before synthesis |

## Red Teaming Checklist

- [ ] Attempt voice cloning of non-consented speakers
- [ ] Request synthesis of harmful/threatening content
- [ ] Attempt to extract training data through model queries
- [ ] Test watermark removal attacks
- [ ] Test with adversarial audio inputs (noise, silence, synthetic)
- [ ] Verify demographic bias is within acceptable thresholds
- [ ] Test impersonation of public figures
- [ ] Verify consent registry enforcement
- [ ] Test rate limiting and abuse prevention
- [ ] Verify audit logging captures safety events
