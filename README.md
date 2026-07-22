# 🌾 FAW Detect — AI Crop Analysis App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Material_3-Design-6750A4?style=for-the-badge&logo=materialdesign&logoColor=white" />
  <img src="https://img.shields.io/badge/Localizations-EN_|_HI-FF6F00?style=for-the-badge&logo=googletranslate&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android_|_iOS-43A047?style=for-the-badge&logo=android&logoColor=white" />
</p>

> An AI-powered mobile application that helps smallholder farmers detect **Fall Armyworm (FAW)** infestations and diagnose crop health by simply photographing their plants. Built with Flutter and backed by a production FastAPI + ONNX inference server.

---

## 📋 Table of Contents

- [App Overview](#-app-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Screens & Navigation](#-screens--navigation)
- [Project Structure](#-project-structure)
- [Localization](#-localization)
- [Installation](#-installation)
- [Backend Integration](#-backend-integration)

---

## 🧠 App Overview

### The Problem

Fall Armyworm (*Spodoptera frugiperda*) is one of the most destructive agricultural pests in Sub-Saharan Africa and South Asia. A single larval infestation can destroy an entire maize field within days. Smallholder farmers — who produce the majority of staple crops in affected regions — often lack access to trained agronomists or rapid diagnostic tools. By the time damage is visibly apparent, it is frequently too late for effective intervention.

Misidentification compounds the problem. Farmers routinely confuse FAW damage with drought stress, fungal disease, or other insect feeding patterns. Incorrect diagnosis leads to ineffective or unnecessarily chemical-heavy responses, increasing both crop loss and input cost.

### Why This App Exists

FAW Detect puts a reliable, expert-level crop diagnostic in any farmer's hands using only a smartphone camera. Rather than asking a farmer to interpret scientific literature or navigate complex interfaces, the app reduces the entire diagnostic process to a single action: **photograph your crop, get a result**.

The app is built for real field conditions — mid-range Android devices, variable lighting, offline-first data storage, and a user base that may prefer Hindi over English.

### The Complete System

This app is one component of a three-repository ecosystem:

| Repository | Role |
|---|---|
| **FAW ML** | Research, training, and ONNX export pipeline — produces the three AI models |
| **faw-backend** | Production FastAPI inference server — loads the models and serves predictions |
| **BIPM FOR FAW** *(this repo)* | Flutter mobile app — the farmer-facing interface that captures images and displays results |

### How the System Works

A farmer opens the app and photographs a crop leaf or insect. The image is compressed on-device and sent to the backend over HTTPS. The backend runs it through a **sequential three-stage AI pipeline** and returns a structured response that the app renders as a diagnosis, confidence score, and treatment plan:

```
Farmer takes photo
       │
       ▼
  Flutter App (this repo)
  ─ compresses image (flutter_image_compress)
  ─ queues if offline (PendingPredictionQueue)
  ─ sends POST /predict with X-API-Key
       │
       ▼
  faw-backend
       │
       ├─ [1] Router Model (MobileNetV3 · FP32)
       │       "Is this a leaf, an insect, or an unusable image?"
       │       Also checks image quality (blur, exposure, distance)
       │       ├─ Invalid scene → action: reject  → Flutter shows guidance
       │       └─ Low quality  → action: retake  → Flutter shows retake tips
       │
       ├─ [2a] Leaf Model (EfficientNet-B0 · FP32)  — if scene = leaf
       │        Returns: healthy · damaged
       │
       ├─ [2b] FAW Model (ConvNeXt-Tiny · INT8)  — if scene = insect
       │        Returns: faw · not_faw
       │
       └─ [3] Treatment Service
               Returns structured guidance steps and recommendations
       │
       ▼
  Flutter App receives response (action: result)
  ─ PredictionPage renders diagnosis + confidence tier badge
  ─ treatment steps displayed to farmer
  ─ result saved to local ScanHistoryService
  ─ appears in Scan Hub history carousel
```

### Response States

The backend response always carries an `action` field that drives the Flutter UI:

| Response `action` | What the farmer sees |
|---|---|
| `result` | Diagnosis screen with confidence score, label, and treatment guidance |
| `retake` | Prompt explaining why the image was rejected (blur, too dark, too far, glare) |
| `reject` | Notice that the image was not recognisable as a crop leaf or insect |

This design ensures the farmer always receives a clear, actionable instruction — never a silent failure or a result that cannot be trusted.



---

## ✨ Features

### 🔍 AI Scanning
- **Camera capture** — native camera integration via `image_picker`
- **Gallery upload** — select existing photos from device storage
- **Image compression** — automatic pre-upload compression via `flutter_image_compress`
- **Pending queue** — scans queued locally if network is unavailable and retried automatically

### 📊 Results & Analysis
- **Confidence display** — tiered label system (Low / Moderate / High / Very High) with colour coding
- **Treatment guidance** — structured actionable steps returned from the AI backend
- **Router debug info** — scene class, quality probability visible for power users
- **Result caching** — last prediction cached locally per image for instant re-view

### 🗂 Scan Hub
- **Floating scan button** with pulse animation — central entry point for all scanning actions
- **Visual scan history** — horizontal carousel of past scans with thumbnail, confidence badge, diagnosis icon, and relative timestamp
- **AI Tips banner** — rotating agricultural tips, isolated from page state for performance
- **Weather & Farm Status card** — dummy environmental indicators (future-ready for live data)
- **Farmer Education Guide** — grid of articles on crop care, pest prevention, and photo technique
- **Ask Krishi AI** — built-in chat assistant with contextual agricultural Q&A

### 💾 Local Storage
- **Scan history** — stored with `SharedPreferences`, showing last 10 scans
- **Image thumbnails** — memory-capped at 200×200px for smooth scrolling on low-RAM devices
- **Result cache** — prediction results cached against image path for offline access

### 🌐 Localization
- Full **English** and **Hindi** support via Flutter's `gen-l10n` pipeline
- Dynamic locale switching — inline Hindi fallbacks where ARB pipeline is unavailable

### 🎨 UI & UX
- **Material 3** design system throughout
- **Google Fonts (Poppins)** for consistent, modern typography
- **Micro-animations** — scale-on-tap buttons, spring-on-press cards, staggered history entrance
- **Fade + slide page transitions** on all navigation routes
- **Native splash screen** with `flutter_native_splash`
- **Adaptive app icon** via `flutter_launcher_icons`

---

## 📸 Screenshots

> **Note:** Place screenshot images at the paths below to display them here.

<p align="center">
  <img src="assets/github/home.png" width="30%" alt="Home Screen" />
  &nbsp;&nbsp;
  <img src="assets/github/scanhub.png" width="30%" alt="Scan Hub" />
  &nbsp;&nbsp;
  <img src="assets/github/results.png" width="30%" alt="Results Page" />
</p>

<p align="center">
  <sub>Home &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Scan Hub &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; AI Results</sub>
</p>

---

## 📱 Screens & Navigation

```
App Launch
    │
    └── Home (main.dart — GNav bottom navigation)
          │
          ├── Tab 0: Home Dashboard
          │     ├── Quick action cards
          │     └── Recent activity
          │
          ├── Tab 1: Scan Hub  (scan_hub.dart)
          │     ├── Floating Scan Button
          │     │     └── Bottom Sheet → Camera | Gallery
          │     ├── Visual Scan History Carousel
          │     ├── AI Tips Banner (rotating, isolated)
          │     ├── Weather & Farm Status Card
          │     ├── Farmer Education Guide Grid
          │     └── Ask Krishi AI Card
          │
          ├── Tab 2: Labs / Identify  (labs.dart)
          │     ├── Biology page
          │     ├── Identification page
          │     ├── Damage Symptoms page
          │     ├── Control page
          │     ├── Management page
          │     └── Sub-pages (lifecycle, larval stages, monitoring, etc.)
          │
          └── Tab 3: Contact  (contact.dart)
                └── Support + feedback links

Scan Flow:
    Camera / Gallery
        │
        └── Preview Page  (image_picker result)
              │
              └── POST /predict → AI Analysis Animation
                    │
                    └── Results Page  (prediction_page.dart)
                          ├── Diagnosis badge + confidence meter
                          ├── Treatment guidance steps
                          ├── Router debug panel
                          └── Save to scan history
```

### Screen Descriptions

| Screen | File | Purpose |
|---|---|---|
| **Home** | `lib/main.dart` | Bottom navigation shell, app entry point |
| **Scan Hub** | `lib/pages/scan_hub.dart` | Primary scanning dashboard |
| **Prediction / Results** | `lib/features/prediction/prediction_page.dart` | AI result display and treatment guidance |
| **Labs** | `lib/pages/labs.dart` | Educational FAW knowledge base |
| **Biology** | `lib/pages/biology.dart` | FAW biology and lifecycle |
| **Identification** | `lib/pages/identifcation.dart` | Visual identification guide |
| **Damage Symptoms** | `lib/pages/damagesymptoms.dart` | Crop damage symptom reference |
| **Control** | `lib/pages/control.dart` | Control methods and pesticides |
| **Management** | `lib/pages/management.dart` | Integrated pest management |
| **Contact** | `lib/pages/contact.dart` | Support and feedback |

---

## 📁 Project Structure

```
fawproto/
│
├── lib/
│   │
│   ├── main.dart                        # App root, MaterialApp, GNav, theme
│   │
│   ├── config/                          # App-wide configuration constants
│   │
│   ├── features/
│   │   ├── camera/
│   │   │   └── camera_service.dart      # Camera permission + image_picker wrapper
│   │   └── prediction/
│   │       ├── prediction_page.dart     # Full results UI — diagnosis, confidence, treatment
│   │       └── prediction_service.dart  # HTTP client for POST /predict
│   │
│   ├── pages/
│   │   ├── scan_hub.dart                # Scan Hub — primary scanning dashboard (1800+ lines)
│   │   ├── labs.dart                    # Educational knowledge base
│   │   ├── biology.dart                 # FAW biology reference
│   │   ├── identifcation.dart           # Identification guide
│   │   ├── damagesymptoms.dart          # Damage symptoms reference
│   │   ├── control.dart                 # Control methods
│   │   ├── management.dart              # IPM strategies
│   │   └── contact.dart                 # Support page
│   │
│   ├── services/
│   │   ├── api_service.dart             # Base HTTP client (base URL, API key header injection)
│   │   ├── image_service.dart           # Image compression pipeline (flutter_image_compress)
│   │   ├── scan_history_service.dart    # SharedPreferences scan history read/write
│   │   ├── result_cache_service.dart    # Per-image prediction result caching
│   │   └── pending_prediction_queue.dart # Offline-first retry queue
│   │
│   ├── models/                          # Dart data models (PredictResponse, ScanRecord, etc.)
│   │
│   ├── widgets/                         # Shared reusable widget components
│   │
│   ├── subpages/                        # Sub-pages for Labs section
│   │   ├── lifecycle.dart
│   │   ├── larva1-3.dart
│   │   ├── larva4-6.dart
│   │   ├── monitoring.dart
│   │   ├── pheromone.dart
│   │   ├── preventivemeasure.dart
│   │   ├── restrictions.dart
│   │   ├── biologycontrol.dart
│   │   └── checmicalcontrol.dart
│   │
│   ├── l10n/                            # Localization
│   │   ├── app_en.arb                   # English strings
│   │   ├── app_hi.arb                   # Hindi strings
│   │   ├── app_localizations.dart       # Generated base class
│   │   ├── app_localizations_en.dart    # Generated English delegate
│   │   └── app_localizations_hi.dart    # Generated Hindi delegate
│   │
│   └── images/                          # App icon and static image assets
│
├── assets/
│   └── github/                          # Screenshots for this README
│       ├── home.png
│       ├── scanhub.png
│       └── results.png
│
├── pubspec.yaml                         # Dependencies and asset declarations
└── README.md
```

---

## 🌐 Localization

The app supports **English** and **Hindi** via Flutter's official `gen-l10n` pipeline.

### Supported Locales

| Locale | Language | ARB File       |
|--------|----------|----------------|
| `en`   | English  | `app_en.arb`   |
| `hi`   | Hindi    | `app_hi.arb`   |

### How It Works

String definitions live in `.arb` files under `lib/l10n/`. The Flutter build system auto-generates typed accessor classes via:

```yaml
# pubspec.yaml
flutter:
  generate: true
```

Strings are accessed in widgets like:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
Text(l10n.scanYourCrop)
```

### Adding a New String

1. Add the key-value pair to `lib/l10n/app_en.arb`:
   ```json
   "myNewKey": "My English string"
   ```
2. Add the Hindi translation to `lib/l10n/app_hi.arb`:
   ```json
   "myNewKey": "मेरी हिंदी स्ट्रिंग"
   ```
3. Run `flutter gen-l10n` or `flutter pub get` to regenerate.

### Inline Locale Fallback

For strings added dynamically (without modifying ARB files), the app uses an inline locale check pattern:

```dart
final isHindi = Localizations.localeOf(context).languageCode == 'hi';
final label = isHindi ? 'हिंदी पाठ' : 'English text';
```

---

## 🛠 Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.x** (Dart SDK `^3.10.7`)
- Android Studio / Xcode for device/emulator setup
- A physical or emulated Android/iOS device

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/faw-detect-app.git
cd faw-detect-app/fawproto
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure the API Key

The app sends an `X-API-Key` header with every prediction request. Set your key in `lib/config/` or via a `.env` mechanism before running.

```dart
// lib/config/api_config.dart
const String apiKey = 'YOUR_API_KEY_HERE';
const String baseUrl = 'https://faw-backend.onrender.com';
```

### 4. Run on Device

```bash
flutter run
```

For a specific device:

```bash
flutter devices                     # list connected devices
flutter run -d <device-id>
```

### 5. Build Release APK

```bash
flutter build apk --release
```

> The output APK is at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔌 Backend Integration

The Flutter app communicates with the **FAW AI Backend** hosted on Render.

**Base URL:** `https://faw-backend.onrender.com`

### Endpoints Used

| Method | Endpoint    | Purpose                                      |
|--------|-------------|----------------------------------------------|
| `GET`  | `/health`   | Server + model registry health check         |
| `POST` | `/predict`  | Submit a crop image for AI analysis          |
| `POST` | `/feedback` | Submit user correction on a prediction result|

### Request Format

All prediction requests use `multipart/form-data`:

```dart
// lib/services/api_service.dart
final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'))
  ..headers['X-API-Key'] = apiKey
  ..files.add(await http.MultipartFile.fromPath('file', imagePath));

final response = await request.send();
```

### Response Actions

The backend returns an `action` field that drives UI state:

| `action`  | Flutter UI Behaviour                              |
|-----------|---------------------------------------------------|
| `result`  | Show `PredictionPage` with diagnosis + treatment  |
| `retake`  | Show retake dialog with user-friendly instruction |
| `reject`  | Show rejection snackbar with reason               |

### Offline Handling

If the device is offline when a scan is submitted, the `PendingPredictionQueue` service stores the image path locally and retries automatically when connectivity is restored (`connectivity_plus`).

### Cold Start Note

The Render backend may take **5–15 seconds** to respond on the first request after a period of inactivity. The app shows an animated loading screen during this time — no fake results are displayed.

---

## 📄 License

MIT — see [`LICENSE`](LICENSE) for details.

---

<p align="center">
  Built for farmers. Powered by AI. 🌱<br/>
  <sub>Fall Armyworm Detection · Crop Health Analysis · Farmer-First Design</sub>
</p>
