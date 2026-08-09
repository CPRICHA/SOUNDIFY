import os
import numpy as np
import tensorflow as tf

from tensorflow.keras.callbacks import (
    EarlyStopping,
    ModelCheckpoint,
    ReduceLROnPlateau,
)

from src.model.aiish_model import build_aiish_model

# =====================================================
# Paths
# =====================================================

EMBEDDING_PATH = "data/embeddings/combined_embeddings.npz"
V1_MODEL_PATH = "models/AIISH_v1_Final.keras"
MODEL_SAVE_PATH = "models/AIISH_v2.keras"
CHECKPOINT_PATH = "checkpoints/AIISH_v2.keras"

# =====================================================
# Load Embeddings
# =====================================================

print("=" * 60)
print("Loading Combined Embeddings...")
print("=" * 60)

data = np.load(EMBEDDING_PATH, allow_pickle=True)

embeddings = data["embeddings"]
labels = data["labels"]
splits = data["splits"]

print(f"Embeddings : {embeddings.shape}")
print(f"Labels     : {labels.shape}")
print(f"Splits     : {splits.shape}")

num_classes = len(np.unique(labels))

print(f"\nNumber of Classes : {num_classes}")

# =====================================================
# Train / Validation / Test Split
# =====================================================

train_mask = splits == "train"
val_mask = splits == "val"
test_mask = splits == "test"

x_train = embeddings[train_mask]
y_train = labels[train_mask]

x_val = embeddings[val_mask]
y_val = labels[val_mask]

x_test = embeddings[test_mask]
y_test = labels[test_mask]

print("\nDataset Split")
print("-" * 40)
print(f"Training   : {len(x_train)}")
print(f"Validation : {len(x_val)}")
print(f"Testing    : {len(x_test)}")

# =====================================================
# Build AIISH v2 Model
# =====================================================

print("\n" + "=" * 60)
print("Building AIISH_v2...")
print("=" * 60)

model = build_aiish_model(
    input_dim=embeddings.shape[1],
    num_classes=num_classes,
)

# =====================================================
# Load AIISH v1
# =====================================================

print("\nLoading AIISH_v1 weights...")

old_model = tf.keras.models.load_model(V1_MODEL_PATH)

print("Weights loaded successfully.")

# =====================================================
# Transfer Learning
# Copy every layer except final Dense layer
# =====================================================

print("\nTransferring learned weights...")

layers_copied = 0

for new_layer, old_layer in zip(model.layers[:-1], old_model.layers[:-1]):

    if len(old_layer.get_weights()) > 0:
        new_layer.set_weights(old_layer.get_weights())

    layers_copied += 1

print(f"{layers_copied} layers initialized from AIISH_v1")

# =====================================================
# Compile
# =====================================================

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)

# =====================================================
# Callbacks
# =====================================================

os.makedirs("checkpoints", exist_ok=True)

callbacks = [

    EarlyStopping(
        monitor="val_loss",
        patience=8,
        restore_best_weights=True,
    ),

    ModelCheckpoint(
        CHECKPOINT_PATH,
        monitor="val_accuracy",
        save_best_only=True,
        verbose=1,
    ),

    ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=3,
        verbose=1,
    ),
]

# =====================================================
# Model Summary
# =====================================================

print("\n")
model.summary()

# =====================================================
# Train
# =====================================================

print("\n" + "=" * 60)
print("Training AIISH_v2...")
print("=" * 60)

history = model.fit(

    x_train,
    y_train,

    validation_data=(x_val, y_val),

    epochs=50,

    batch_size=32,

    callbacks=callbacks,

    verbose=1,
)

# =====================================================
# Evaluate
# =====================================================

print("\n" + "=" * 60)
print("Final Evaluation")
print("=" * 60)

loss, accuracy = model.evaluate(
    x_test,
    y_test,
    verbose=0,
)

print(f"Test Loss     : {loss:.4f}")
print(f"Test Accuracy : {accuracy:.4f}")

# =====================================================
# Save Model
# =====================================================

os.makedirs("models", exist_ok=True)

model.save(MODEL_SAVE_PATH)

print("\n" + "=" * 60)
print("Training Complete!")
print("=" * 60)

print(f"Model saved to : {MODEL_SAVE_PATH}")