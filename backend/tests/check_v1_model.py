import tensorflow as tf

model = tf.keras.models.load_model("models/AIISH_v1_Final.keras")

model.summary()

print("\nInput Shape :", model.input_shape)
print("Output Shape:", model.output_shape)