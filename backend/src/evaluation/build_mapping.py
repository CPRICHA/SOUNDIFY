from src.model.yamnet_labels import CLASS_NAMES

with open("audioset_labels.txt", "w") as f:

    for i, label in enumerate(CLASS_NAMES):
        f.write(f"{i:3d} : {label}\n")

print("Saved successfully!")