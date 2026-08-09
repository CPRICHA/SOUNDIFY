# Sound-Detection-Model

## Overview

The **AIISH Sound Detection Model** repository contains the machine learning pipeline for environmental sound classification developed as part of the AIISH project.

The system uses **YAMNet** as a pretrained audio feature extractor and a custom neural network classifier trained through transfer learning to recognize environmental sounds relevant to assistive hearing applications.

The repository is organized into modular components for feature extraction, model training, evaluation, and testing, making it easy to extend with additional datasets and sound classes.

---

## Repository Structure

```text
Sound-Detection-Model/
│
├── checkpoints/          # Training checkpoints
├── data/
│   ├── custom/           # Custom AIISH dataset
│   ├── embeddings/       # Extracted YAMNet embeddings
│   ├── mappings/         # Label mappings
│   └── UrbanSound8K/     # UrbanSound8K dataset
│
├── models/               # Trained AIISH models
├── notebooks/            # Experiment notebooks
├── results/              # Evaluation reports and confusion matrices
├── saved_models/         # Exported model formats
│
├── src/
│   ├── data/
│   ├── evaluation/
│   ├── model/
│   ├── training/
│   └── utils/
│
├── tests/                # Testing scripts
├── yamnet_official/      # Official YAMNet implementation
│
├── requirements.txt
└── README.md
```
## Key Scripts

### Training (`src/training/`)

| Script | Purpose |
|---------|---------|
| `extract_embeddings.py` | Extract YAMNet embeddings from UrbanSound8K |
| `extract_embeddings_v2.py` | Extract YAMNet embeddings from the custom AIISH dataset |
| `merge_embeddings.py` | Merge UrbanSound8K and AIISH embeddings into a unified dataset |
| `train.py` | Train AIISH v1 classifier |
| `train_v2.py` | Train AIISH v2 classifier using transfer learning |

### Evaluation (`src/evaluation/`)

| Script | Purpose |
|---------|---------|
| `evaluate.py` | Evaluate AIISH v1 model |
| `evaluate_v2.py` | Evaluate AIISH v2 model and generate reports/confusion matrix |

### Tests (`tests/`)

| Script | Purpose |
|---------|---------|
| `gpu_test.py` | Verify TensorFlow GPU setup |
| `yamnet_test.py` | Test YAMNet loading |
| `dataset_test.py` | Validate dataset loading |
| `baseline_yamnet.py` | Evaluate baseline YAMNet performance |
| `check_embeddings.py` | Inspect extracted embeddings |
| `check_v1_model.py` | Verify AIISH v1 model loading |
| `model_test.py` | General model testing utilities |
---

## Model Pipeline

```text
Environmental Audio
        │
        ▼
Audio Preprocessing
        │
        ▼
Pretrained YAMNet
        │
        ▼
1024-D Audio Embeddings
        │
        ▼
AIISH Classifier
        │
        ▼
Environmental Sound Prediction
```

---

## Datasets

The current model is developed using a combination of public and custom datasets.

- **AudioSet** – Used indirectly through the pretrained YAMNet model.
- **UrbanSound8K** – Benchmark dataset containing 10 urban environmental sound classes.
- **Custom AIISH Dataset** – Environmental sounds collected for assistive hearing applications.

---

## Technologies

- Python
- TensorFlow / Keras
- TensorFlow Hub
- NumPy
- Pandas
- Librosa
- Scikit-learn

---

## Features

- Transfer learning using YAMNet
- Audio embedding extraction
- Unified multi-dataset training pipeline
- Environmental sound classification
- Model evaluation and confusion matrix generation
- Modular project structure for future expansion

---

## License

This repository is intended for academic research and educational purposes.
