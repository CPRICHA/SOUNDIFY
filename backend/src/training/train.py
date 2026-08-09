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
# Load Embeddings
# =====================================================

print("=" * 60)
print("Loading Embeddings...")
print("=" * 60)

data = np.load("data/embeddings/urbansound8k_embeddings.npz")

embeddings = data["embeddings"]
labels = data["labels"]
folds = data["folds"]

print("Embeddings :", embeddings.shape)
print("Labels     :", labels.shape)
print("Folds      :", folds.shape)

# =====================================================
# Official UrbanSound8K Split
# =====================================================

train_mask = folds <= 8
val_mask = folds == 9
test_mask = folds == 10

x_train = embeddings[train_mask]
y_train = labels[train_mask]

x_val = embeddings[val_mask]
y_val = labels[val_mask]

x_test = embeddings[test_mask]
y_test = labels[test_mask]

print("\nTraining Samples   :", len(x_train))
print("Validation Samples :", len(x_val))
print("Testing Samples    :", len(x_test))

# =====================================================
# Build Model
# =====================================================

model = build_aiish_model()

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
        "checkpoints/AIISH_v1.keras",
        monitor="val_accuracy",
        save_best_only=True,
    ),

    ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=3,
        verbose=1,
    ),
]

# =====================================================
# Train
# =====================================================

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
# Save Final Model
# =====================================================

os.makedirs("models", exist_ok=True)

model.save("models/AIISH_v1_Final.keras")

print("\nModel Saved Successfully!")