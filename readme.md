# AIISH — Quick Team Setup

## 1. Clone

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd AIISH
```

---

## 2. Start Backend (ML)

Open **Terminal 1**:

```powershell
cd backend
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m src.api.app
```

Backend runs at:

```text
http://127.0.0.1:8000
```

Check:

```text
http://127.0.0.1:8000/health
```

You should see:

```text
ready: true
yamnet_loaded: true
tflite_loaded: true
```

---

## 3. Start Frontend

Open **Terminal 2**:

```powershell
cd frontend
npm install
npm run dev
```

Open:

```text
http://127.0.0.1:3000
```

Allow microphone permission.

Play a **doorbell / dog bark / siren** near the microphone and wait a few seconds for the visual alert.

---

# What was integrated?

### Frontend → Backend

```text
Microphone
   ↓
React
   ↓
Express `/api/detect/classify`
   ↓
Python ML `/api/v1/classify`
```

### ML

```text
Audio
 ↓
YAMNet
 ↓
AIISH_v2.tflite
 ↓
Sound + confidence
```

### Alert

```text
ML prediction
 ↓
modelLabelMap.ts
 ↓
existing handleSoundTrigger()
 ↓
Visual Alert
```

---

# Important files

### Frontend

```text
frontend/src/App.tsx
```

Connects listening/mic detection to the app.

```text
frontend/src/services/micCapture.ts
```

Captures microphone audio.

```text
frontend/src/services/detectClient.ts
```

Sends audio to the backend.

```text
frontend/src/data/modelLabelMap.ts
```

Maps ML sounds → AIISH visual alerts.

```text
frontend/server.ts
```

Connects frontend → Python ML API.

### Backend

```text
backend/src/api/app.py
```

ML API.

```text
backend/src/inference/pipeline.py
```

YAMNet → AIISH model inference.

```text
backend/models/AIISH_v2.tflite
```

Current trained model.

---

# Current status

✅ Frontend working
✅ Backend working
✅ Real microphone working
✅ ML prediction working
✅ Visual alerts connected

⚠️ Accuracy still needs improvement
⚠️ Inference is currently ~3–4 seconds
⚠️ Real-time optimization comes later

**For now, don't change the ML pipeline or architecture. This version is our working baseline.**
