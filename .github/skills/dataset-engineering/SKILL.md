---
name: dataset-engineering
description: "**WORKFLOW SKILL** — End-to-end ML data pipeline: collection, cleaning, labeling, augmentation, synthetic data, versioning. USE FOR: building training datasets, data quality analysis, ETL for ML, annotation workflows, audio data processing, text corpus construction, data cards. USE WHEN: preparing data for model training, auditing dataset quality, designing data pipelines, versioning datasets with DVC."
argument-hint: "Describe the dataset task: what data, what format, what quality requirements"
---

# Dataset Engineering

Build, clean, validate, and version high-quality datasets for ML training and evaluation.

## When to Use

- Building a new training dataset from scratch or existing sources
- Cleaning and deduplicating an existing dataset
- Setting up annotation workflows (LabelStudio, Prodigy)
- Designing data augmentation strategies
- Generating synthetic training data
- Versioning datasets with DVC or HF Datasets

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Data Card** | Metadata document: source, size, splits, format, license, preprocessing |
| **Data Pipeline** | Reproducible ETL: extract → transform → load → validate |
| **Data Quality** | Completeness, consistency, accuracy, timeliness, uniqueness |
| **Augmentation** | Expanding dataset via transformations that preserve labels |
| **Synthetic Data** | Generated data (LLM, TTS, procedural) to fill gaps |
| **Versioning** | Tracking data changes alongside code (DVC, git-lfs) |

## Procedure

### Phase 1: Requirements Analysis

1. **Define the task**: What model will be trained? What are the inputs/outputs?
2. **Estimate volume**: How much data is needed? (rule of thumb: 10× model parameters for fine-tuning)
3. **Identify sources**: Public datasets, internal data, APIs, web, synthetic
4. **Check licenses**: Verify data can be used for intended purpose
5. **Define quality criteria**: Minimum acceptable quality, labeling guidelines

### Phase 2: Collection & Cleaning

1. **Collect** raw data from identified sources
2. **Deduplicate** (exact hash + fuzzy/MinHash for text, perceptual hash for audio/images)
3. **Normalize** formats (sample rate, encoding, text encoding, schema)
4. **Filter** low-quality samples (signal-to-noise, confidence scores, outlier detection)
5. **Profile** distributions (class balance, length distributions, language mix)

### Phase 3: Labeling & Augmentation

1. **Label** via annotation tool or weak supervision
2. **Validate** labels (inter-annotator agreement, spot checks)
3. **Augment** to address class imbalance or increase diversity
4. **Review** augmented samples for validity

### Phase 4: Validation & Versioning

1. **Validate** schema (Great Expectations, Pydantic)
2. **Compute** statistics (mean, std, distributions, outliers)
3. **Split** into train/val/test (stratified, temporal, or random)
4. **Version** with DVC or HF Datasets
5. **Document** in data card

## Audio Data Reference Patterns (Kyutai Stack)

Reference patterns from Kyutai open-source projects:

- **Format**: JSONL with audio paths and metadata (`moshi/data/tts.jsonl`)
- **Sample Rate**: 24 kHz (Mimi codec standard)
- **Codec**: Mimi encodes to 12.5 Hz, 1.1 kbps, 8 RVQ codebooks
- **VAD**: Voice Activity Detection for segmentation
- **Normalization**: Peak normalization, loudness (LUFS) standardization
- **Augmentation**: Speed perturbation (0.9-1.1×), pitch shift, noise injection, room simulation

## Text Data Specifics

- **Tokenization**: SentencePiece, BPE, WordPiece — match the target model's tokenizer
- **Deduplication**: MinHash (datasketch) for near-duplicate detection
- **Quality Filtering**: Perplexity-based (KenLM), language detection (fasttext), heuristics
- **Format**: JSONL, Parquet (columnar, fast), Arrow (HF Datasets)

## Tools Reference

| Tool | Purpose |
| ------ | --------- |
| HF Datasets | Loading, processing, streaming large datasets |
| webdataset | Tar-based shards for large-scale training |
| DVC | Data versioning (S3/GCS/Azure backends) |
| LabelStudio | Multi-modal annotation |
| Great Expectations | Data validation and profiling |
| librosa / torchaudio | Audio feature extraction |
| datasketch | MinHash deduplication |
