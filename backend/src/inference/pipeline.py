"""
Reusable AIISH inference pipeline.

Pipeline:
    Audio File → load_audio() → YAMNet → Mean Embedding (1024)
    → AIISH_v2.tflite → Prediction
"""

from __future__ import annotations

import json
import time
from pathlib import Path

import numpy as np
import tensorflow as tf

from src.data.preproc import SAMPLE_RATE, load_audio
from src.model.yamnet_loader import load_yamnet

REPO_ROOT = Path(__file__).resolve().parents[2]

TFLITE_MODEL = REPO_ROOT / "models" / "AIISH_v2.tflite"
LABEL_PATH = REPO_ROOT / "data" / "mappings" / "unified_labels.json"
MODEL_DISPLAY_NAME = TFLITE_MODEL.name

EXPECTED_CLASS_COUNT = 25
TOP_K = 5

_pipeline: "InferencePipeline | None" = None


def load_labels(label_path: Path) -> list[str]:
    """Load index → class name mapping used by AIISH_v2."""
    with open(label_path, "r", encoding="utf-8") as f:
        label_map = json.load(f)
    return [label_map[str(i)] for i in range(len(label_map))]


def load_tflite_interpreter(model_path: Path):
    """Create and allocate a TFLite interpreter for AIISH_v2."""
    interpreter = tf.lite.Interpreter(model_path=str(model_path))
    interpreter.allocate_tensors()
    return interpreter


class InferencePipeline:
    """Holds loaded models and runs file-based classification."""

    def __init__(
        self,
        yamnet_model,
        tflite_interpreter,
        class_names: list[str],
        model_name: str = MODEL_DISPLAY_NAME,
    ):
        self.yamnet_model = yamnet_model
        self.tflite_interpreter = tflite_interpreter
        self.class_names = class_names
        self.model_name = model_name
        self.input_details = tflite_interpreter.get_input_details()
        self.output_details = tflite_interpreter.get_output_details()

    @property
    def yamnet_loaded(self) -> bool:
        return self.yamnet_model is not None

    @property
    def tflite_loaded(self) -> bool:
        return self.tflite_interpreter is not None

    @property
    def class_count_ok(self) -> bool:
        return len(self.class_names) == EXPECTED_CLASS_COUNT

    def predict_audio(self, audio_path: str) -> dict:
        """
        Run the full AIISH inference pipeline on one audio file.

        Reuses:
            - load_audio() for mono 16 kHz preprocessing
            - YAMNet for 1024-d frame embeddings
            - mean pooling (same as training)
            - AIISH_v2.tflite for classification
        """
        start = time.perf_counter()

        waveform = load_audio(audio_path)
        duration_s = float(len(waveform) / float(SAMPLE_RATE))

        _, embedding, _ = self.yamnet_model(waveform)
        embedding = tf.reduce_mean(embedding, axis=0).numpy()
        embedding_shape = tuple(int(dim) for dim in embedding.shape)
        sample = embedding.astype(np.float32).reshape(1, -1)

        self.tflite_interpreter.set_tensor(
            self.input_details[0]["index"],
            sample,
        )
        self.tflite_interpreter.invoke()
        probabilities = self.tflite_interpreter.get_tensor(
            self.output_details[0]["index"]
        )[0]

        elapsed_ms = (time.perf_counter() - start) * 1000.0

        ranked_indices = np.argsort(probabilities)[::-1]
        top_indices = ranked_indices[:TOP_K]
        predicted_idx = int(ranked_indices[0])
        confidence = float(probabilities[predicted_idx])

        top_predictions = [
            {
                "rank": rank,
                "label": self.class_names[int(idx)],
                "probability": float(probabilities[int(idx)]),
                "percent": float(probabilities[int(idx)]) * 100.0,
            }
            for rank, idx in enumerate(top_indices, start=1)
        ]

        return {
            "filename": Path(audio_path).name,
            "predicted_class": self.class_names[predicted_idx],
            "confidence": confidence,
            "confidence_percent": confidence * 100.0,
            "top_predictions": top_predictions,
            "inference_ms": elapsed_ms,
            "duration_s": duration_s,
            "embedding_shape": embedding_shape,
            "model_name": self.model_name,
        }

    def health(self) -> dict:
        return {
            "status": "ok" if self.ready else "degraded",
            "yamnet_loaded": self.yamnet_loaded,
            "tflite_loaded": self.tflite_loaded,
            "class_count": len(self.class_names),
            "expected_class_count": EXPECTED_CLASS_COUNT,
            "class_count_ok": self.class_count_ok,
            "model_name": self.model_name,
            "ready": self.ready,
        }

    @property
    def ready(self) -> bool:
        return (
            self.yamnet_loaded
            and self.tflite_loaded
            and self.class_count_ok
        )


def initialize_pipeline(
    tflite_model: Path = TFLITE_MODEL,
    label_path: Path = LABEL_PATH,
) -> InferencePipeline:
    """Load YAMNet, TFLite classifier, and labels once."""
    global _pipeline

    if not tflite_model.exists():
        raise FileNotFoundError(f"Missing model: {tflite_model}")
    if not label_path.exists():
        raise FileNotFoundError(f"Missing labels: {label_path}")

    class_names = load_labels(label_path)
    if len(class_names) != EXPECTED_CLASS_COUNT:
        raise ValueError(
            f"Expected {EXPECTED_CLASS_COUNT} classes, "
            f"found {len(class_names)} in {label_path}"
        )

    yamnet_model = load_yamnet()
    tflite_interpreter = load_tflite_interpreter(tflite_model)

    _pipeline = InferencePipeline(
        yamnet_model=yamnet_model,
        tflite_interpreter=tflite_interpreter,
        class_names=class_names,
        model_name=tflite_model.name,
    )
    return _pipeline


def get_pipeline() -> InferencePipeline:
    if _pipeline is None:
        raise RuntimeError(
            "Inference pipeline is not initialized. "
            "Call initialize_pipeline() first."
        )
    return _pipeline
