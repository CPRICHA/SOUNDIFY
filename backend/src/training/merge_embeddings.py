import json
import numpy as np

# ==========================================================
# Paths
# ==========================================================

URBAN_PATH = "data/embeddings/urbansound8k_embeddings.npz"
AIISH_PATH = "data/embeddings/aiish_embeddings_v2.npz"

MAPPING_PATH = "data/mappings/unified_label_mapping.json"

OUTPUT_PATH = "data/embeddings/combined_embeddings.npz"
LABEL_OUTPUT_PATH = "data/mappings/unified_labels.json"

# ==========================================================
# UrbanSound8K Label Dictionary
# ==========================================================

URBAN_LABELS = {
    0: "Air Conditioner",
    1: "Car Horn",
    2: "Children Playing",
    3: "Dog Bark",
    4: "Drilling",
    5: "Engine Idling",
    6: "Gun Shot",
    7: "Jackhammer",
    8: "Siren",
    9: "Street Music"
}

# ==========================================================
# Load Mapping
# ==========================================================

with open(MAPPING_PATH, "r") as f:
    label_mapping = json.load(f)

# ==========================================================
# Load UrbanSound8K
# ==========================================================

urban = np.load(URBAN_PATH, allow_pickle=True)

urban_embeddings = urban["embeddings"]
urban_labels = urban["labels"]
urban_folds = urban["folds"]

urban_splits = np.array([
    "train" if fold <= 8 else
    "val" if fold == 9 else
    "test"
    for fold in urban_folds
])

assert len(urban_embeddings) == len(urban_labels)
assert len(urban_embeddings) == len(urban_splits)

urban_label_names = np.array([
    URBAN_LABELS[int(label)]
    for label in urban_labels
])

urban_final_labels = np.array([
    label_mapping.get(label, label)
    for label in urban_label_names
])

urban_sources = np.array(
    ["UrbanSound8K"] * len(urban_embeddings)
)

# ==========================================================
# Load AIISH
# ==========================================================

aiish = np.load(AIISH_PATH, allow_pickle=True)

aiish_embeddings = aiish["embeddings"]
aiish_labels = aiish["labels"]
aiish_splits = aiish["splits"]

old_index_to_label = aiish["index_to_label"].item()

assert len(aiish_embeddings) == len(aiish_labels)
assert len(aiish_embeddings) == len(aiish_splits)

aiish_label_names = np.array([
    old_index_to_label[int(label)]
    for label in aiish_labels
])

aiish_final_labels = np.array([
    label_mapping.get(label, label)
    for label in aiish_label_names
])

aiish_sources = np.array(
    ["AIISH"] * len(aiish_embeddings)
)

# ==========================================================
# Merge Everything
# ==========================================================

combined_embeddings = np.concatenate(
    [urban_embeddings, aiish_embeddings],
    axis=0
)

combined_label_names = np.concatenate(
    [urban_final_labels, aiish_final_labels],
    axis=0
)

combined_splits = np.concatenate(
    [urban_splits, aiish_splits],
    axis=0
)

combined_sources = np.concatenate(
    [urban_sources, aiish_sources],
    axis=0
)

# ==========================================================
# Create Unified Label Mapping
# ==========================================================

unique_labels = sorted(np.unique(combined_label_names))

label_to_index = {
    label: idx
    for idx, label in enumerate(unique_labels)
}

index_to_label = {
    idx: label
    for label, idx in label_to_index.items()
}

combined_labels = np.array([
    label_to_index[label]
    for label in combined_label_names
])

# ==========================================================
# Save Combined Dataset
# ==========================================================

np.savez_compressed(
    OUTPUT_PATH,
    embeddings=combined_embeddings,
    labels=combined_labels,
    splits=combined_splits,
    sources=combined_sources,
    label_to_index=label_to_index,
    index_to_label=index_to_label
)

# ==========================================================
# Save Unified Labels
# ==========================================================

with open(LABEL_OUTPUT_PATH, "w") as f:
    json.dump(index_to_label, f, indent=4)

# ==========================================================
# Summary
# ==========================================================

print("=" * 60)
print("Embedding Merge Complete")
print("=" * 60)

print(f"UrbanSound8K Samples : {len(urban_embeddings)}")
print(f"AIISH Samples        : {len(aiish_embeddings)}")
print(f"Total Samples        : {len(combined_embeddings)}")

print()

print(f"Total Classes        : {len(unique_labels)}")

print()

print("Dataset Sources")
print("-" * 40)

unique_sources, source_counts = np.unique(
    combined_sources,
    return_counts=True
)

for source, count in zip(unique_sources, source_counts):
    print(f"{source:15s}: {count}")

print()

print("Split Distribution")
print("-" * 40)

for split in ["train", "val", "test"]:
    count = np.sum(combined_splits == split)
    print(f"{split:5s}: {count}")

print()

print("Class Distribution")
print("-" * 40)

unique, counts = np.unique(
    combined_labels,
    return_counts=True
)

for idx, count in zip(unique, counts):
    print(f"{index_to_label[idx]:30s}: {count}")

print()

print("Unified Labels")
print("-" * 40)

for idx, label in index_to_label.items():
    print(f"{idx:2d} -> {label}")

print()

print("Saved Files")
print("-" * 40)
print(OUTPUT_PATH)
print(LABEL_OUTPUT_PATH)

print("=" * 60)