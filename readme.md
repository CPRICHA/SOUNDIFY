# AIISH — Quick Team Setup

## 1. Clone

```bash
git clone https://github.com/CPRICHA/SOUNDIFY.git
cd AIISH
```

---

2. Start Backend (ML)

Open Terminal 1:

cd backend
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m src.api.app

Backend runs at:

http://127.0.0.1:8000

Check:

http://127.0.0.1:8000/health

You should see:

ready: true
yamnet_loaded: true
tflite_loaded: true
3. Start Frontend

Open Terminal 2:

cd frontend
npm install
npm run dev

Open:

http://127.0.0.1:3000

Allow microphone permission.

Play a doorbell / dog bark / siren / vehicle horn / baby crying near the microphone and wait for the visual alert.

What is Integrated?
Frontend → Backend
Microphone
   ↓
1.5-second audio chunk
   ↓
16 kHz mono WAV
   ↓
React
   ↓
Express `/api/detect/classify`
   ↓
Python ML `/api/v1/classify`
ML Pipeline
Audio
 ↓
YAMNet
 ↓
AIISH_v2.tflite
 ↓
Sound + confidence
 ↓
Frontend model-label mapping
Alert Pipeline
ML prediction
 ↓
modelLabelMap.ts
 ↓
Sound Taxonomy
 ↓
Indoor / Outdoor priority
 ↓
Severity
 ↓
Visual Alert
Implemented Features
🎙️ Live Microphone Detection
Real browser microphone capture.
Audio is processed in 1.5-second chunks.
Audio is converted to mono 16 kHz WAV.
Audio chunks are sent sequentially to the ML backend.
No audio is written to disk during live detection.
🏷️ Unified Sound Mapping

The frontend maps ML model classes to the application's sound taxonomy.

Currently supported mappings include:

Alarm
Approaching Vehicles
Baby Crying
Cat Meowing
Construction Sound
Cow Mooing
Dog Bark
Door Knock
Doorbell
Engine Idling
Firecrackers
Glass Breaking
Microwave Oven Beep
Mixer Grinder
Pressure Cooker Whistle
Siren
Temple Bell
Train Horn
Utensils
Vehicle Horn
Water Running
🏠 Indoor / Outdoor Context

Alert priority can change depending on the selected environment.

Indoor
   ↓
Contextual Priority

Outdoor
   ↓
Contextual Priority

This allows the same sound to have different importance depending on whether the user is indoors or outdoors.

🚨 Four-Level Severity System

The application currently supports four severity levels:

Critical
High
Medium
Low

Internally:

critical  → Critical
attention → High
medium    → Medium
low       → Low
🎨 Severity Colors
🔴 Critical → Red
🟠 High     → Orange
🟡 Medium   → Yellow
🟢 Low      → Green
🔷 Severity Shapes

The frontend uses distinct shapes for each severity:

🔴 Critical → Hexagon + !
🟠 High     → Triangle
🟡 Medium   → Square
🟢 Low      → Circle

These indicators are used across the live alert and history UI.

📳 Haptic Alerts

The frontend supports different vibration patterns for different alert severities.

Important Files
Frontend
frontend/src/App.tsx

Connects the live detection flow and application state.

frontend/src/services/micCapture.ts

Captures microphone audio, creates 1.5-second chunks, resamples to 16 kHz, and creates WAV data.

frontend/src/services/detectClient.ts

Sends recorded audio to the Express ML proxy and receives the model prediction.

frontend/src/data/modelLabelMap.ts

Maps ML model class names to frontend taxonomy IDs.

frontend/src/data/soundTaxonomy.ts

Contains the application's sound categories and their metadata.

frontend/src/data/priorityMatrix.ts

Contains contextual Indoor / Outdoor priority rules.

frontend/src/components/DeviceSimulator.tsx

Displays the device simulation, live alerts, severity indicators, history, and related UI.

frontend/src/types.ts

Contains the shared TypeScript types, including the four severity levels.

frontend/server.ts

Connects the frontend/Express layer to the Python ML API.

Backend
backend/src/api/app.py

Python ML API.

backend/src/inference/pipeline.py

Handles YAMNet → AIISH model inference.

backend/models/AIISH_v2.tflite

Current trained AIISH model.

Dataset / Embeddings
data/embeddings/

Contains the generated model embeddings.

The current combined embedding dataset contains samples from:

AIISH
UrbanSound8K

with unified labels and dataset split information.

Current Status

✅ Frontend working

✅ Backend working

✅ Real microphone capture working

✅ Live ML prediction working

✅ AIISH model integrated

✅ UrbanSound8K + AIISH embeddings combined

✅ Unified sound-label mapping

✅ Engine Idling supported in frontend

✅ Indoor / Outdoor contextual priorities implemented

✅ Four-level severity system implemented

✅ Critical / High / Medium / Low colors implemented

✅ Critical / High / Medium / Low shapes implemented

✅ Visual alerts connected

✅ Alert history connected

✅ Haptic severity support implemented

⚠️ Model accuracy still needs improvement

⚠️ Live inference currently takes approximately 3–4 seconds

⚠️ Real-time inference optimization will be handled later

Current Working Baseline

This version represents the current working baseline of the AIISH/SOUNDIFY system.

The complete flow is currently:

Microphone
    ↓
Audio Capture
    ↓
1.5s WAV Chunk
    ↓
Express Proxy
    ↓
Python ML API
    ↓
YAMNet
    ↓
AIISH_v2 Model
    ↓
Sound Prediction
    ↓
Frontend Label Mapping
    ↓
Indoor / Outdoor Context
    ↓
Priority
    ↓
Visual + Haptic Alert