"""
Audio preprocessing for AIISH / YAMNet pipelines.

Matches the training notebook contract:
    librosa.load(..., sr=16000, mono=True) → float32 waveform tensor
"""

from __future__ import annotations

import librosa
import tensorflow as tf


SAMPLE_RATE = 16000


def load_audio(filename: str) -> tf.Tensor:
    """
    Load an audio file as a mono waveform sampled at 16 kHz.

    Returns a 1-D float32 TensorFlow tensor suitable for YAMNet.
    """
    audio, _ = librosa.load(
        filename,
        sr=SAMPLE_RATE,
        mono=True,
    )
    return tf.convert_to_tensor(audio, dtype=tf.float32)
