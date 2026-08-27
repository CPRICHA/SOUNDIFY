"""
AIISH Model Tester
------------------
Internal Flask utility for evaluating AIISH_v2.tflite on audio recordings.

Pipeline:
    Audio File → load_audio() → YAMNet → Mean Embedding (1024)
    → AIISH_v2.tflite → Prediction

Run:
    python src/tester/app.py

Then open:
    http://127.0.0.1:5000

Author: Pramathi Sujay
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

from flask import Flask, flash, redirect, render_template, request, url_for
from werkzeug.utils import secure_filename

# Ensure repository root is on the path when running this file directly.
REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from src.inference.pipeline import get_pipeline, initialize_pipeline


# ==========================================================
# Paths / constants
# ==========================================================

ALLOWED_EXTENSIONS = {".wav", ".mp3", ".flac", ".ogg", ".m4a", ".aac"}

TESTER_DIR = Path(__file__).resolve().parent

app = Flask(
    __name__,
    template_folder=str(TESTER_DIR / "templates"),
    static_folder=str(TESTER_DIR / "static"),
)
app.secret_key = "aiish-internal-tester"


def allowed_file(filename: str) -> bool:
    return Path(filename).suffix.lower() in ALLOWED_EXTENSIONS


# ==========================================================
# Routes
# ==========================================================

@app.route("/", methods=["GET"])
def index():
    return render_template("index.html", result=None)


@app.route("/predict", methods=["POST"])
def predict():
    uploaded = request.files.get("audio_file")

    if uploaded is None or uploaded.filename is None or uploaded.filename.strip() == "":
        flash("No audio file selected. Please choose a file and try again.")
        return redirect(url_for("index"))

    filename = secure_filename(uploaded.filename)
    if not allowed_file(filename):
        flash(
            "Unsupported audio format. "
            "Please upload wav, mp3, flac, ogg, m4a, or aac."
        )
        return redirect(url_for("index"))

    suffix = Path(filename).suffix.lower()
    temp_path = None

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            temp_path = Path(tmp.name)
            uploaded.save(temp_path)

        pipeline = get_pipeline()
        result = pipeline.predict_audio(str(temp_path))
        result["filename"] = filename
        return render_template("index.html", result=result)

    except Exception as exc:
        flash(f"Inference failed: {exc}")
        return redirect(url_for("index"))

    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink(missing_ok=True)


# ==========================================================
# Entry point
# ==========================================================

def main():
    print("=" * 60)
    print("AIISH Model Tester")
    print("=" * 60)

    try:
        pipeline = initialize_pipeline()
    except Exception as exc:
        print(f"\nStartup failed: {exc}")
        print("Fix the missing asset / dependency and try again.")
        sys.exit(1)

    print(f"\nModel : {pipeline.model_name}")
    print(f"Classes: {len(pipeline.class_names)}")
    print("\nOpen in browser: http://127.0.0.1:5000")
    print("=" * 60)

    app.run(host="127.0.0.1", port=5000, debug=False)


if __name__ == "__main__":
    main()
