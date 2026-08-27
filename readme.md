# AIISH — Quick Team Setup

## 1. Clone

```bash
git clone https://github.com/CPRICHA/SOUNDIFY.git
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

## Running the Flutter Frontend

From the root directory of the SOUNDIFY project:

```bash
cd frontend/flutter
```

Install the required dependencies:

```bash
flutter pub get
```

---

## 1. Run Using Chrome

Check whether Chrome is available:

```bash
flutter devices
```

Run the Flutter application in Chrome:

```bash
flutter run -d chrome
```

To stop the application, press:

```text
q
```

---

## 2. Run on Android Using USB Debugging

### Enable USB Debugging

On the Android phone:

1. Open **Settings → About Phone**.
2. Tap **Build Number** 7 times to enable Developer Options.
3. Open **Developer Options**.
4. Enable **USB Debugging**.
5. Connect the phone to the computer using a USB cable.
6. Accept **Allow USB debugging** on the phone.

### Check the Connected Device

```bash
flutter devices
```

Your Android phone should appear in the device list.

### Run SOUNDIFY on the Phone

If only one Android device is connected:

```bash
flutter run
```

If multiple devices are shown, copy the Android device ID from:

```bash
flutter devices
```

Then run:

```bash
flutter run -d <device-id>
```

For example:

```bash
flutter run -d RZ8N123456
```

### Stop the Application

In the terminal running Flutter, press:

```text
q
```

---

## Quick Commands

**Chrome:**

```bash
cd frontend/flutter
flutter pub get
flutter run -d chrome
```

**Android via USB Debugging:**

```bash
cd frontend/flutter
flutter pub get
flutter devices
flutter run
```

