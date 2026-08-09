import numpy as np

data = np.load("data/embeddings/urbansound8k_embeddings.npz")

print("=" * 60)
print("Keys:")
print(data.files)

print("\nShapes:")
for key in data.files:
    print(f"{key}: {data[key].shape}")

print("\nData Types:")
for key in data.files:
    print(f"{key}: {data[key].dtype}")

print("\nFirst Embedding (first 10 values):")
print(data["embeddings"][0][:10])

print("\nFirst Label:")
print(data["labels"][0])

if "folds" in data.files:
    print("\nFirst Fold:")
    print(data["folds"][0])

print("\nUnique Labels:")
print(np.unique(data["labels"]))

print("\nNumber of Classes:")
print(len(np.unique(data["labels"])))

print("=" * 60)
print("Everything Loaded Successfully!")
print("=" * 60)