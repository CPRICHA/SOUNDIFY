import tensorflow as tf

print("=" * 50)
print("TensorFlow Version :", tf.__version__)
print("=" * 50)

gpus = tf.config.list_physical_devices("GPU")

if gpus:
    print(f"GPU Found: {gpus[0].name}")
else:
    print("No GPU Found")

print("=" * 50)