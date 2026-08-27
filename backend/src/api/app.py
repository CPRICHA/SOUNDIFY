"""
AIISH JSON Inference API

Endpoints:
    GET  /health
    POST /api/v1/classify   (multipart field name: audio)

Run:
    python -m src.api.app
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

from flask import Flask, jsonify, request
from werkzeug.utils import secure_filename

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from src.inference.pipeline import initialize_pipeline, get_pipeline

ALLOWED_EXTENSIONS = {".wav", ".mp3", ".flac", ".ogg", ".m4a", ".aac"}

app = Flask(__name__)


def allowed_file(filename: str) -> bool:
    return Path(filename).suffix.lower() in ALLOWED_EXTENSIONS


def classify_response(result: dict) -> dict:
    """Public JSON shape for classify responses."""
    return {
        "predicted_class": result["predicted_class"],
        "confidence": result["confidence"],
        "confidence_percent": result["confidence_percent"],
        "top_predictions": [
            {
                "rank": item["rank"],
                "label": item["label"],
                "probability": item["probability"],
            }
            for item in result["top_predictions"]
        ],
        "inference_ms": result["inference_ms"],
        "duration_s": result["duration_s"],
        "model_name": result["model_name"],
    }


@app.get("/health")
def health():
    try:
        pipeline = get_pipeline()
    except RuntimeError as exc:
        return jsonify(
            {
                "status": "error",
                "yamnet_loaded": False,
                "tflite_loaded": False,
                "class_count_ok": False,
                "ready": False,
                "error": str(exc),
            }
        ), 503

    payload = pipeline.health()
    status_code = 200 if pipeline.ready else 503
    return jsonify(payload), status_code


@app.post("/api/v1/classify")
def classify():
    try:
        pipeline = get_pipeline()
    except RuntimeError as exc:
        return jsonify({"error": str(exc)}), 503

    if not pipeline.ready:
        return jsonify(
            {
                "error": "Inference pipeline is not ready",
                "health": pipeline.health(),
            }
        ), 503

    uploaded = request.files.get("audio")
    if uploaded is None or not uploaded.filename:
        return jsonify(
            {
                "error": "Missing multipart file field 'audio'.",
            }
        ), 400

    filename = secure_filename(uploaded.filename)
    if not allowed_file(filename):
        return jsonify(
            {
                "error": (
                    "Unsupported audio format. "
                    "Allowed: wav, mp3, flac, ogg, m4a, aac."
                ),
            }
        ), 400

    suffix = Path(filename).suffix.lower()
    temp_path = None

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            temp_path = Path(tmp.name)
            uploaded.save(temp_path)

        result = pipeline.predict_audio(str(temp_path))
        result["filename"] = filename
        return jsonify(classify_response(result))

    except Exception as exc:
        return jsonify({"error": f"Inference failed: {exc}"}), 500

    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink(missing_ok=True)


def main():
    print("=" * 60)
    print("AIISH JSON Inference API")
    print("=" * 60)

    try:
        pipeline = initialize_pipeline()
    except Exception as exc:
        print(f"\nStartup failed: {exc}")
        print("Fix the missing asset / dependency and try again.")
        sys.exit(1)

    print(f"\nModel   : {pipeline.model_name}")
    print(f"Classes : {len(pipeline.class_names)}")
    print("\nEndpoints:")
    print("  GET  http://127.0.0.1:8000/health")
    print("  POST http://127.0.0.1:8000/api/v1/classify")
    print("=" * 60)

    app.run(host="0.0.0.0", port=8000, debug=False)


if __name__ == "__main__":
    main()
