import os
import json
import numpy as np
import tensorflow as tf

import matplotlib.pyplot as plt

from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    ConfusionMatrixDisplay,
    accuracy_score,
)

# =====================================================
# Paths
# =====================================================

MODEL_PATH = "models/AIISH_v2.keras"
EMBEDDING_PATH = "data/embeddings/combined_embeddings.npz"
LABEL_PATH = "data/mappings/unified_labels.json"

RESULTS_DIR = "results"

# =====================================================
# Load Model
# =====================================================

print("=" * 60)
print("Loading AIISH_v2 Model...")
print("=" * 60)

model = tf.keras.models.load_model(MODEL_PATH)

# =====================================================
# Load Dataset
# =====================================================

print("\nLoading Test Dataset...")

data = np.load(EMBEDDING_PATH, allow_pickle=True)

embeddings = data["embeddings"]
labels = data["labels"]
splits = data["splits"]

test_mask = splits == "test"

x_test = embeddings[test_mask]
y_test = labels[test_mask]

print(f"Test Samples : {len(x_test)}")

# =====================================================
# Load Label Names
# =====================================================

with open(LABEL_PATH, "r") as f:
    label_map = json.load(f)

class_names = [label_map[str(i)] for i in range(len(label_map))]

# =====================================================
# Predict
# =====================================================

print("\nRunning Predictions...")

predictions = model.predict(x_test, verbose=0)

y_pred = np.argmax(predictions, axis=1)

# =====================================================
# Accuracy
# =====================================================

accuracy = accuracy_score(y_test, y_pred)

# =====================================================
# Classification Report
# =====================================================

report = classification_report(
    y_test,
    y_pred,
    target_names=class_names,
    digits=4,
)

# =====================================================
# Confusion Matrix
# =====================================================

cm = confusion_matrix(y_test, y_pred)

# =====================================================
# Save Results
# =====================================================

os.makedirs(RESULTS_DIR, exist_ok=True)

# ---------- Evaluation Summary ----------

with open(
    os.path.join(
        RESULTS_DIR,
        "v2_evaluation_summary.txt",
    ),
    "w",
) as f:

    f.write("=" * 60 + "\n")
    f.write("AIISH v2 Evaluation Summary\n")
    f.write("=" * 60 + "\n\n")

    f.write(f"Model            : {MODEL_PATH}\n")
    f.write(f"Dataset          : {EMBEDDING_PATH}\n")
    f.write(f"Test Samples     : {len(x_test)}\n")
    f.write(f"Number of Classes: {len(class_names)}\n")
    f.write(f"Test Accuracy    : {accuracy:.4f}\n")

# ---------- Classification Report ----------

with open(
    os.path.join(
        RESULTS_DIR,
        "v2_classification_report.txt",
    ),
    "w",
) as f:

    f.write(report)

# ---------- Confusion Matrix CSV ----------

np.savetxt(
    os.path.join(
        RESULTS_DIR,
        "v2_confusion_matrix.csv",
    ),
    cm,
    fmt="%d",
    delimiter=",",
)

# ---------- Confusion Matrix Figure ----------

fig, ax = plt.subplots(figsize=(16, 16))

disp = ConfusionMatrixDisplay(
    confusion_matrix=cm,
    display_labels=class_names,
)

disp.plot(
    cmap="Blues",
    xticks_rotation=90,
    values_format="d",
    ax=ax,
    colorbar=False,
)

plt.title("AIISH v2 Confusion Matrix")

plt.tight_layout()

plt.savefig(
    os.path.join(
        RESULTS_DIR,
        "v2_confusion_matrix.png",
    ),
    dpi=300,
)

plt.close()

# =====================================================
# Print Results
# =====================================================

print("\n" + "=" * 60)
print("Evaluation Complete")
print("=" * 60)

print(f"\nTest Accuracy : {accuracy:.4f}\n")

print(report)

print("\nResults Saved")

print("- v2_evaluation_summary.txt")
print("- v2_classification_report.txt")
print("- v2_confusion_matrix.csv")
print("- v2_confusion_matrix.png")