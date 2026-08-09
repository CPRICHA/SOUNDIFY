import tensorflow_hub as hub


YAMNET_URL = "https://tfhub.dev/google/yamnet/1"


def load_yamnet():
    """
    Load the pretrained YAMNet model.
    """

    print("Loading YAMNet...")

    model = hub.load(YAMNET_URL)

    print("YAMNet loaded successfully!")

    return model