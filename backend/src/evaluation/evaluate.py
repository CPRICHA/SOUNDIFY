import os
import numpy as np
import tensorflow as tf

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix,
)

import matplotlib.pyplot as plt

# =====================================================
# Load Model
# =====================================================

print("=" * 60)
print("Loading AIISH Model...")
print("=" * 60)

model = tf.keras.models.load_model(
    "checkpoints/AIISH_v1.keras"
)

# =====================================================
# Load Embeddings
# =====================================================

data = np.load(
    "data/embeddings/urbansound8k_embeddings.npz"
)

embeddings = data["embeddings"]
labels = data["labels"]
folds = data["folds"]

# =====================================================
# Test Set (Official Fold 10)
# =====================================================

test_mask = folds == 10

x_test = embeddings[test_mask]
y_test = labels[test_mask]

# =====================================================
# Prediction
# =====================================================

predictions = model.predict(x_test, verbose=0)

y_pred = np.argmax(predictions, axis=1)

# =====================================================
# Metrics
# =====================================================

accuracy = accuracy_score(y_test, y_pred)

precision = precision_score(
    y_test,
    y_pred,
    average="weighted"
)

recall = recall_score(
    y_test,
    y_pred,
    average="weighted"
)

f1 = f1_score(
    y_test,
    y_pred,
    average="weighted"
)

print("\n" + "=" * 60)
print("Evaluation Results")
print("=" * 60)

print(f"Accuracy : {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall   : {recall:.4f}")
print(f"F1 Score : {f1:.4f}")

# =====================================================
# Class Names
# =====================================================

CLASS_NAMES = [
    "air_conditioner",
    "car_horn",
    "children_playing",
    "dog_bark",
    "drilling",
    "engine_idling",
    "gun_shot",
    "jackhammer",
    "siren",
    "street_music",
]

# =====================================================
# Classification Report
# =====================================================

report = classification_report(
    y_test,
    y_pred,
    target_names=CLASS_NAMES
)

print("\n")
print(report)

os.makedirs("results", exist_ok=True)

with open(
    "results/classification_report.txt",
    "w"
) as f:
    f.write(report)

# =====================================================
# Confusion Matrix
# =====================================================

cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(10, 8))

plt.imshow(cm)

plt.colorbar()

plt.xticks(
    range(len(CLASS_NAMES)),
    CLASS_NAMES,
    rotation=45,
    ha="right"
)

plt.yticks(
    range(len(CLASS_NAMES)),
    CLASS_NAMES
)

plt.xlabel("Predicted")

plt.ylabel("Actual")

plt.title("AIISH Confusion Matrix")

plt.tight_layout()

plt.savefig(
    "results/confusion_matrix.png",
    dpi=300
)

plt.show()

print("\nSaved:")
print("results/classification_report.txt")
print("results/confusion_matrix.png")