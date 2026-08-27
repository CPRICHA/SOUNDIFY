import pandas as pd

LABELS_PATH = "https://raw.githubusercontent.com/tensorflow/models/master/research/audioset/yamnet/yamnet_class_map.csv"

labels = pd.read_csv(LABELS_PATH)

CLASS_NAMES = labels["display_name"].tolist()