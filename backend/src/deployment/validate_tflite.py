"""
AIISH Sound Detection Model
---------------------------
TensorFlow Lite Validation Utility

Compares predictions from the original Keras model and the
exported TensorFlow Lite model using random samples from
the test dataset.

Author: Pramathi Sujay
"""

from pathlib import Path
import numpy as np
import tensorflow as tf


# ==========================================================
# Paths
# ==========================================================

KERAS_MODEL = Path("models/AIISH_v2.keras")
TFLITE_MODEL = Path("models/AIISH_v2.tflite")
EMBEDDINGS = Path("data/embeddings/combined_embeddings.npz")

NUM_SAMPLES = 20
SEED = 42


# ==========================================================
# Load Dataset
# ==========================================================

print("=" * 60)
print("AIISH TensorFlow Lite Validation")
print("=" * 60)

print("\nLoading embeddings...")

data = np.load(EMBEDDINGS, allow_pickle=True)

X = data["embeddings"]
y = data["labels"]
splits = data["splits"]

test_indices = np.where(splits == "test")[0]

X_test = X[test_indices]
y_test = y[test_indices]

print(f"✓ Test Samples : {len(X_test)}")


# ==========================================================
# Load Models
# ==========================================================

print("\nLoading Keras model...")
keras_model = tf.keras.models.load_model(KERAS_MODEL)
print("✓ Keras model loaded")

print("\nLoading TensorFlow Lite model...")

interpreter = tf.lite.Interpreter(model_path=str(TFLITE_MODEL))
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("✓ TFLite model loaded")


# ==========================================================
# Validation
# ==========================================================

rng = np.random.default_rng(SEED)

sample_indices = rng.choice(
    len(X_test),
    size=min(NUM_SAMPLES, len(X_test)),
    replace=False
)

correct = 0
max_difference = 0.0

print("\n" + "=" * 60)

for i, idx in enumerate(sample_indices, start=1):

    sample = X_test[idx].astype(np.float32).reshape(1, -1)

    # -----------------------------
    # Keras prediction
    # -----------------------------
    keras_pred = keras_model.predict(sample, verbose=0)[0]

    # -----------------------------
    # TFLite prediction
    # -----------------------------
    interpreter.set_tensor(
        input_details[0]["index"],
        sample
    )

    interpreter.invoke()

    tflite_pred = interpreter.get_tensor(
        output_details[0]["index"]
    )[0]

    keras_class = np.argmax(keras_pred)
    tflite_class = np.argmax(tflite_pred)

    difference = np.max(np.abs(keras_pred - tflite_pred))
    max_difference = max(max_difference, difference)

    match = keras_class == tflite_class

    if match:
        correct += 1

    print(f"\nSample {i}")
    print("-" * 40)
    print(f"Keras Class   : {keras_class}")
    print(f"TFLite Class  : {tflite_class}")
    print(f"Match         : {'✓' if match else '✗'}")
    print(f"Max Difference: {difference:.8f}")


# ==========================================================
# Summary
# ==========================================================

print("\n" + "=" * 60)
print("Validation Summary")
print("=" * 60)

print(f"Samples Tested       : {len(sample_indices)}")
print(f"Prediction Matches   : {correct}/{len(sample_indices)}")
print(f"Agreement            : {(correct/len(sample_indices))*100:.2f}%")
print(f"Maximum Difference   : {max_difference:.10f}")

if correct == len(sample_indices):
    print("\n✅ TensorFlow Lite validation PASSED")
else:
    print("\n⚠ TensorFlow Lite validation completed with mismatches")