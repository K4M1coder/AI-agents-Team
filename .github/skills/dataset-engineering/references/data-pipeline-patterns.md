# Data Pipeline Patterns

Reusable patterns for ML data processing pipelines.

## Pattern 1: Audio Dataset Pipeline (Reference: Kyutai/Moshi)

```text
Raw Audio → Resample (24kHz) → VAD Segmentation → Loudness Normalization → Transcript Alignment
         → Quality Filter (SNR > 15dB) → Dedup (perceptual hash) → Train/Val/Test Split
         → JSONL Manifest → DVC Version
```

### JSONL Manifest Format (from `moshi/data/tts.jsonl`)

```json
{"audio_path": "data/audio/001.wav", "text": "Hello world", "speaker_id": "spk_01", "duration": 3.5}
```

### Key Parameters

- Sample rate: 24,000 Hz (Mimi codec standard)
- Segment length: 5-30 seconds (for training)
- SNR threshold: > 15 dB for clean speech
- Format: WAV (16-bit PCM) or FLAC for storage

---

## Pattern 2: Text Corpus Pipeline

```text
Raw Text → Language Detection → Encoding Fix (UTF-8) → Deduplication (MinHash)
        → Quality Filter (perplexity, length, repetition) → Tokenize (SentencePiece)
        → Shuffle → Shard (Parquet/Arrow) → DVC Version
```

### Deduplication Parameters

- MinHash: 128 permutations, Jaccard threshold 0.8
- N-gram size: 5 words (for MinHash shingling)
- Exact dedup: SHA-256 hash on normalized text

### Quality Filters

- Min length: 50 characters
- Max length: 100,000 characters
- Max repetition ratio: 0.3 (repeated n-grams / total n-grams)
- Perplexity: KenLM model, discard top 5% and bottom 1%

---

## Pattern 3: Synthetic Data Generation

```text
Define Distribution → Template/Prompt Design → Generate (LLM/TTS) → Quality Filter
                   → Human Spot-Check (5%) → Merge with Real Data → Validate Balance
```

### Audio Synthetic Data

- Use TTS (Pocket-TTS or similar) to generate speech from text
- Apply room simulation (pyroomacoustics) for acoustic diversity
- Add noise at various SNR levels (5-30 dB)
- Vary speed (0.9×-1.1×) and pitch (±2 semitones)

### Text Synthetic Data

- Use LLM to generate variations of existing samples
- Back-translation for paraphrasing
- Entity substitution for named entity augmentation
- Limit synthetic ratio: ≤ 30% of total training data

---

## Pattern 4: Streaming Data Pipeline

For large datasets that don't fit in memory:

```python
import webdataset as wds

dataset = (
    wds.WebDataset("s3://bucket/shards-{000000..000999}.tar")
    .shuffle(1000)
    .decode("pil")  # or "torch" for audio
    .to_tuple("audio.wav", "transcript.txt")
    .map(preprocess)
    .batched(32)
)
```

### Shard Sizing

- Target: 100-500 MB per shard
- ~1000-10000 samples per shard
- Use tar format for sequential read efficiency

---

## Pattern 5: Augmentation Pipeline

### Audio Augmentations (training-time)

| Augmentation | Parameters | Probability |
| ------------- | ----------- | ------------- |
| Speed perturbation | 0.9-1.1× | 0.5 |
| Pitch shift | ±2 semitones | 0.3 |
| Additive noise | SNR 10-30 dB | 0.4 |
| Room simulation | RT60 0.1-0.8s | 0.3 |
| SpecAugment | F=27, T=100, mF=2, mT=2 | 0.8 |
| Volume perturbation | ±6 dB | 0.5 |

### Text Augmentations

| Augmentation | Parameters | Probability |
| ------------- | ----------- | ------------- |
| Synonym replacement | 15% of words | 0.3 |
| Random insertion | 10% extra words | 0.2 |
| Random swap | 10% of word pairs | 0.2 |
| Back-translation | Via MarianMT | 0.2 |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| ------------- | --------- | ----- |
| No deduplication | Train/test leakage, memorization | Dedup before splitting |
| Test set augmented | Inflated metrics | Only augment train set |
| No data versioning | Can't reproduce results | Use DVC or HF Datasets |
| Inconsistent preprocessing | Train/inference mismatch | Single preprocessing function |
| No quality checks | Garbage in, garbage out | Validate with schema + stats |
