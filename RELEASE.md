# CarbonWise — Hackathon Demo Release

## 📱 Android APK

**[Download CarbonWise.apk](./CarbonWise.apk)** (23.8 MB)

> Install directly on your Android phone. No Play Store needed.

---

## 🚀 Installation

1. Copy `CarbonWise.apk` to your Android phone
2. Go to **Settings → Security** → Enable **"Install from Unknown Sources"**
3. Open the APK file and tap **Install**
4. Launch **CarbonWise** from your home screen

---

## 🔐 Demo Login

| Field    | Value                      |
|----------|---------------------------|
| Email    | `user@carbonwise.com`     |
| Password | `user123`                 |

> Or tap **"Demo / Guest Mode"** to skip login entirely (works offline).

---

## ✅ Demo Flow (Recommended Order)

1. **Login Screen** — Pre-filled credentials, one-tap Demo Mode
2. **Dashboard** — Live KPIs, AI Optimization Engine, Carbon Budget
3. **Prediction** — 6h/12h/24h ML forecast, best charging windows
4. **Maps** — OpenStreetMap heatmap, sensor nodes, risk zones (Chennai)
5. **Devices** — Smart appliance management with scheduling
6. **Reports** — BRSR/GHG Protocol audit with PDF export
7. **Profile** — User settings and logout

---

## 🌟 Key Features Demonstrated

- **AI Carbon Budget Optimization** — Multi-factory sustainability planning
- **ML Grid Prediction** — LSTM-based 24h carbon intensity forecast
- **Real-time Sensor Network** — 24 nodes across Chennai (demo data)
- **Carbon GIS Heatmap** — OpenStreetMap with pollution layers
- **ESG Report Generator** — ISO 14064 / GHG Protocol compliant PDF
- **Demo/Offline Mode** — Fully functional without internet or backend

---

## 🏗️ Technology Stack

| Layer     | Technology                        |
|-----------|-----------------------------------|
| Mobile    | Flutter 3.24.5 (Dart 3.5)        |
| Maps      | flutter_map + OpenStreetMap       |
| Backend   | Spring Boot on Render             |
| Database  | Neon PostgreSQL                   |
| AI/ML     | Python FastAPI + LSTM model       |
| IoT       | ESP32 + MQTT                      |

---

## 📦 Build Info

```
Flutter 3.24.5 • channel stable
Dart 3.5.4
Min SDK: Android 5.0 (API 21)
Target SDK: Android 14 (API 34)
APK Size: 23.8 MB
Build: Release (signed with debug keystore)
```

---

*Built for hackathon demonstration. Uses demo data when backend is unavailable.*
