import os
import numpy as np
import tensorflow as tf
from tqdm import tqdm

from src.data.dataset import UrbanSound8KDataset
from src.data.preproc import load_audio
from src.model.yamnet_loader import load_yamnet

# ======================================================
# Load Dataset
# ======================================================

dataset = UrbanSound8KDataset("data/UrbanSound8K")
df = dataset.add_audio_paths()

# ======================================================
# Load YAMNet
# ======================================================

yamnet = load_yamnet()

embeddings = []
labels = []
folds = []

print("=" * 60)
print("Extracting YAMNet Embeddings...")
print("=" * 60)

for _, sample in tqdm(df.iterrows(), total=len(df)):

    try:

        waveform = load_audio(sample["audio_path"])

        scores, embedding, spectrogram = yamnet(waveform)

        # Average embeddings across frames
        embedding = tf.reduce_mean(embedding, axis=0)

        embeddings.append(embedding.numpy())
        labels.append(sample["classID"])
        folds.append(sample["fold"])

    except Exception as e:

        print(f"Skipping {sample['audio_path']}")
        print(e)

# ======================================================
# Save
# ======================================================

embeddings = np.array(embeddings)
labels = np.array(labels)

os.makedirs("data/embeddings", exist_ok=True)

np.savez(
    "data/embeddings/urbansound8k_embeddings.npz",
    embeddings=np.array(embeddings),
    labels=np.array(labels),
    folds=np.array(folds)
)

print("\nDone!")
print("Embeddings Shape :", embeddings.shape)
print("Labels Shape     :", labels.shape)