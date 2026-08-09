import os
import numpy as np
import pandas as pd
import tensorflow as tf
from tqdm import tqdm

from src.data.preproc import load_audio
from src.model.yamnet_loader import load_yamnet

# ======================================================
# Configuration
# ======================================================

DATASET_ROOT = "data/custom"
METADATA_PATH = "data/custom/metadata/metadata.csv"
OUTPUT_PATH = "data/embeddings/aiish_embeddings_v2.npz"

# ======================================================
# Load Metadata
# ======================================================

df = pd.read_csv(METADATA_PATH)

# Create full audio paths
df["audio_path"] = df["filepath"].apply(
    lambda x: os.path.join(DATASET_ROOT, x)
)

# ======================================================
# Encode Labels
# ======================================================

unique_labels = sorted(df["label"].unique())

label_to_index = {
    label: idx
    for idx, label in enumerate(unique_labels)
}

index_to_label = {
    idx: label
    for label, idx in label_to_index.items()
}

# ======================================================
# Load YAMNet
# ======================================================

yamnet = load_yamnet()

embeddings = []
labels = []
splits = []

print("=" * 60)
print("Extracting AIISH V2 Embeddings...")
print("=" * 60)

for _, sample in tqdm(df.iterrows(), total=len(df)):

    try:

        waveform = load_audio(sample["audio_path"])

        scores, embedding, spectrogram = yamnet(waveform)

        # Average embeddings across all frames
        embedding = tf.reduce_mean(embedding, axis=0)

        embeddings.append(embedding.numpy())
        labels.append(label_to_index[sample["label"]])
        splits.append(sample["split"])

    except Exception as e:

        print(f"\nSkipping : {sample['audio_path']}")
        print(e)

# ======================================================
# Convert to NumPy
# ======================================================

embeddings = np.array(embeddings)
labels = np.array(labels)
splits = np.array(splits)

# ======================================================
# Save Embeddings
# ======================================================

os.makedirs("data/embeddings", exist_ok=True)

np.savez(
    OUTPUT_PATH,
    embeddings=embeddings,
    labels=labels,
    splits=splits,
    label_to_index=label_to_index,
    index_to_label=index_to_label
)

print("\n" + "=" * 60)
print("Embedding Extraction Complete!")
print("=" * 60)
print(f"Embeddings Shape : {embeddings.shape}")
print(f"Labels Shape     : {labels.shape}")
print(f"Total Classes    : {len(unique_labels)}")
print(f"Saved To         : {OUTPUT_PATH}")