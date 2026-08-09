import tensorflow_hub as hub

print("Loading YAMNet...")

model = hub.load("https://tfhub.dev/google/yamnet/1")

print("YAMNet loaded successfully!")

print(model)