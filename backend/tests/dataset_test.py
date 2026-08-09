from src.data.dataset import UrbanSound8KDataset

dataset = UrbanSound8KDataset("data/UrbanSound8K")

print("=" * 60)
print("Dataset Loaded Successfully!")
print("=" * 60)

print(f"Total Samples : {len(dataset.get_dataframe())}")
print(f"Total Classes : {dataset.get_num_classes()}")

print("\nClasses:")
print(dataset.get_class_names())

print("\nClass Distribution:")
print(dataset.get_class_distribution())

print("\nFirst Five Samples:")
print(dataset.add_audio_paths().head())