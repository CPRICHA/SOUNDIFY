from src.data.dataset import UrbanSound8KDataset
from src.data.preproc import load_audio
from src.model.yamnet_loader import load_yamnet
from src.model.yamnet_labels import CLASS_NAMES
from src.evaluation.label_mapper import map_label

import tensorflow as tf

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
)

# ======================================================
# Load Dataset
# ======================================================

dataset = UrbanSound8KDataset("data/UrbanSound8K")

df = dataset.add_audio_paths()

# Test on 100 random samples first
df = df.sample(n=100, random_state=42)

# ======================================================
# Load Model
# ======================================================

model = load_yamnet()

# ======================================================
# Evaluation Variables
# ======================================================

actual_labels = []
classification_predictions = []

semantic_correct = 0

print("=" * 80)
print("Running Baseline Evaluation on YAMNet...")
print("=" * 80)

# ======================================================
# Evaluation Loop
# ======================================================

for i, (_, sample) in enumerate(df.iterrows(), start=1):

    waveform = load_audio(sample["audio_path"])

    scores, embeddings, spectrogram = model(waveform)

    mean_scores = tf.reduce_mean(scores, axis=0)

    # -----------------------------
    # Top-5 Predictions
    # -----------------------------

    top5_indices = tf.argsort(
        mean_scores,
        direction="DESCENDING"
    )[:5]

    top5_audio_labels = [
        CLASS_NAMES[int(idx)]
        for idx in top5_indices
    ]

    # -----------------------------
    # Classification Mapping
    # -----------------------------

    mapped_labels = []

    for label in top5_audio_labels:

        mapped = map_label(label)

        if mapped != "unknown":
            mapped_labels.append(mapped)

    # -----------------------------
    # Semantic Accuracy
    # -----------------------------

    if sample["class"] in mapped_labels:
        semantic_correct += 1

    # -----------------------------
    # Classification Accuracy
    # -----------------------------

    actual_labels.append(sample["class"])

    if len(mapped_labels) > 0:
        classification_predictions.append(mapped_labels[0])
    else:
        classification_predictions.append("unknown")

    # -----------------------------
    # Print
    # -----------------------------

    print(
        f"[{i:03d}] "
        f"Actual: {sample['class']:<18}"
        f"Top5: {top5_audio_labels}"
    )

    print(
        f"      Mapped: {mapped_labels}"
    )

# ======================================================
# Metrics
# ======================================================

semantic_accuracy = semantic_correct / len(df)

classification_accuracy = accuracy_score(
    actual_labels,
    classification_predictions
)

precision = precision_score(
    actual_labels,
    classification_predictions,
    average="weighted",
    zero_division=0
)

recall = recall_score(
    actual_labels,
    classification_predictions,
    average="weighted",
    zero_division=0
)

f1 = f1_score(
    actual_labels,
    classification_predictions,
    average="weighted",
    zero_division=0
)

print("\n" + "=" * 80)
print("Baseline Results")
print("=" * 80)

print(f"Semantic Accuracy      : {semantic_accuracy:.4f}")
print()

print(f"Classification Accuracy: {classification_accuracy:.4f}")
print(f"Precision              : {precision:.4f}")
print(f"Recall                 : {recall:.4f}")
print(f"F1 Score               : {f1:.4f}")

print("=" * 80)