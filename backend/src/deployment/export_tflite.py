"""
AIISH Sound Detection Model
---------------------------
TensorFlow Lite Export Utility

Converts a trained Keras model into TensorFlow Lite format
for deployment on Android devices.

Author: Pramathi Sujay
"""

from pathlib import Path
import tensorflow as tf


# ==========================================================
# Paths
# ==========================================================

MODEL_PATH = Path("models/AIISH_v2.keras")
OUTPUT_PATH = Path("models/AIISH_v2.tflite")


# ==========================================================
# Export Function
# ==========================================================

def export_to_tflite(model_path: Path, output_path: Path):
    """Convert a Keras model to TensorFlow Lite."""

    print("=" * 50)
    print(" AIISH TensorFlow Lite Export")
    print("=" * 50)

    # Load model
    print("\nLoading Keras model...")
    model = tf.keras.models.load_model(model_path)
    print(f"✓ Loaded: {model_path.name}")

    # Convert
    print("\nConverting to TensorFlow Lite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    print("✓ Conversion successful")

    # Save
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "wb") as f:
        f.write(tflite_model)

    print(f"\n✓ Saved: {output_path}")

    # File sizes
    keras_size = model_path.stat().st_size / (1024 * 1024)
    tflite_size = output_path.stat().st_size / (1024 * 1024)

    print("\nModel Sizes")
    print("-" * 50)
    print(f"Keras   : {keras_size:.2f} MB")
    print(f"TFLite  : {tflite_size:.2f} MB")

    # Model information
    print("\nModel Information")
    print("-" * 50)
    print(f"Input Shape : {model.input_shape}")
    print(f"Output Shape: {model.output_shape}")

    print("\n✅ Export completed successfully!")


# ==========================================================
# Main
# ==========================================================

if __name__ == "__main__":
    export_to_tflite(MODEL_PATH, OUTPUT_PATH)