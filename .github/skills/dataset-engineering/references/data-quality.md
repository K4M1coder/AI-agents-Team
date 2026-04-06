# Data Quality Reference

Standards and checks for ensuring ML dataset quality.

## Quality Dimensions

| Dimension | Description | Example Check |
| ----------- | ------------- | -------------- |
| **Completeness** | No missing required fields | Null check on all columns |
| **Consistency** | Same format across samples | Schema validation |
| **Accuracy** | Labels correctly match content | Inter-annotator agreement |
| **Timeliness** | Data is recent enough | Timestamp checks |
| **Uniqueness** | No unwanted duplicates | Hash-based dedup |
| **Balance** | Reasonable class distribution | Class ratio checks |

## Audio Quality Checks

| Check | Tool | Threshold |
| ------- | ------ | ----------- |
| Sample rate | torchaudio.info | Must match target (24 kHz) |
| Duration | torchaudio.info | 0.5s - 30s for speech |
| SNR | WADA-SNR / custom | > 15 dB |
| Clipping | Peak detection | < 1% of samples clipped |
| Silence ratio | Energy-based VAD | < 50% silence |
| Bit depth | torchaudio.info | ≥ 16-bit |
| Channels | torchaudio.info | Mono (1 channel) |
| Loudness | pyloudnorm (LUFS) | -23 ± 3 LUFS (EBU R128) |

## Text Quality Checks

| Check | Tool | Threshold |
| ------- | ------ | ----------- |
| Encoding | chardet | UTF-8 |
| Language | fasttext (lid.176.bin) | Confidence > 0.8 |
| Length | len() | Task-dependent min/max |
| Repetition | n-gram analysis | Repetition ratio < 0.3 |
| Perplexity | KenLM | Discard outliers (top 5%) |
| PII | presidio / regex | No emails, phones, SSNs |
| Profanity | profanity-filter | Flag for review |

## Validation Framework (Great Expectations)

```python
import great_expectations as gx

context = gx.get_context()
validator = context.sources.pandas_default.read_csv("data.csv")

# Define expectations
validator.expect_column_values_to_not_be_null("audio_path")
validator.expect_column_values_to_be_between("duration", min_value=0.5, max_value=30.0)
validator.expect_column_values_to_be_in_set("language", ["en", "fr", "es", "de"])
validator.expect_column_values_to_match_regex("audio_path", r".*\.(wav|flac|mp3)$")

# Run validation
results = validator.validate()
```

## Label Quality

### Inter-Annotator Agreement (IAA)

| Metric | Use Case | Good Threshold |
| -------- | ---------- | --------------- |
| Cohen's Kappa | 2 annotators, categories | > 0.8 |
| Fleiss' Kappa | N annotators, categories | > 0.7 |
| Krippendorff's Alpha | Any annotators/types | > 0.8 |
| IoU (Jaccard) | Bounding boxes, segments | > 0.7 |

### Label Review Process

1. Double-annotate 10-20% of dataset
2. Compute IAA metrics
3. Review disagreements (adjudication)
4. Update labeling guidelines based on common errors
5. Re-annotate problematic categories

## Data Splits

### Split Strategy

| Strategy | When to Use |
| ---------- | ------------ |
| **Random** | Default, i.i.d. assumption holds |
| **Stratified** | Imbalanced classes, maintain ratios |
| **Temporal** | Time-series, avoid future data leakage |
| **Group** | Speaker/user splits, prevent entity leakage |
| **K-fold** | Small datasets, cross-validation |

### Standard Ratios

- Large dataset (>100k): 90/5/5 (train/val/test)
- Medium dataset (10k-100k): 80/10/10
- Small dataset (<10k): 70/15/15 or K-fold

### Leakage Prevention

- Speaker-level splits for speech (no speaker in both train and test)
- Document-level splits for text (no document in both)
- Dedup before splitting (never after)
- No augmented data in validation/test sets

## Dataset Documentation (Data Card)

Template for every dataset:

```markdown
# Dataset Card: [Name]

## Overview
- **Size**: X samples, Y hours/tokens
- **Format**: JSONL + WAV / Parquet
- **Language**: en, fr
- **License**: [license]
- **Version**: 1.0.0

## Collection
- **Source**: [where it came from]
- **Date**: [collection period]
- **Method**: [how it was collected]

## Processing
- **Cleaning**: [steps applied]
- **Filtering**: [criteria used]
- **Deduplication**: [method and stats]

## Statistics
- **Duration distribution**: [min, max, mean, std]
- **Class balance**: [per-class counts]
- **Quality metrics**: [SNR, etc.]

## Splits
| Split | Samples | % |
| ------- | --------- | --- |
| Train | X | 80% |
| Val   | Y | 10% |
| Test  | Z | 10% |

## Known Issues
- [any known quality issues]
- [class imbalances]
- [representation gaps]
```text
