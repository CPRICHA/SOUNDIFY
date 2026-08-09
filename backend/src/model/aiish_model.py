import tensorflow as tf
from tensorflow.keras import layers, models


def build_aiish_model(input_dim=1024, num_classes=10):
    """
    AIISH Classifier
    Input  : YAMNet Embeddings (1024)
    Output : UrbanSound8K Classes (10)
    """

    model = models.Sequential(
        [
            layers.Input(shape=(input_dim,)),

            # Hidden Layer 1
            layers.Dense(512),
            layers.BatchNormalization(),
            layers.ReLU(),
            layers.Dropout(0.30),

            # Hidden Layer 2
            layers.Dense(128),
            layers.BatchNormalization(),
            layers.ReLU(),
            layers.Dropout(0.20),

            # Output Layer
            layers.Dense(num_classes, activation="softmax"),
        ],
        name="AIISH_v1"
    )

    return model