# 🌿 CarbonWise – AI Carbon Intelligence Platform

> **One App, Two Layers** — Empowering consumers and city administrators with real-time carbon intelligence, AI-powered predictions, and smart appliance scheduling.

---

## 📱 Android APK

Download and install the CarbonWise Android application directly on your mobile device:

### 📥 [Download CarbonWise.apk (v1.0.0 Release)](https://github.com/dharan15777/Carbon-Optimizer-Application/releases/download/v1.0.0/CarbonWise.apk)

*Alternative direct download from repository:* [releases/CarbonWise.apk](https://github.com/dharan15777/Carbon-Optimizer-Application/raw/main/releases/CarbonWise.apk)

### 📲 Installation Instructions (Android Sideloading)
1. Tap the **[Download CarbonWise.apk](https://github.com/dharan15777/Carbon-Optimizer-Application/releases/download/v1.0.0/CarbonWise.apk)** link above on your Android phone.
2. Once downloaded, open your phone's **Downloads** folder or tap the download notification.
3. If prompted with *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings** and toggle **Allow from this source**.
4. Tap **Install** and then **Open**.
5. **Minimum Android Version**: Android 5.0 Lollipop (API Level 21) or higher.
6. **Architecture**: Universal APK (ARM64-v8a, ARMeabi-v7a, x86_64).

### 🔑 Demo Credentials
- **Email / Username**: `admin@carbonwise.ai` (or any email)
- **Password**: `admin123`
- **Instant Demo**: Tap **Demo Mode / Login as Demo** on the login screen to enter immediately without typing credentials.

### 🧪 Demo Mode Explanation
CarbonWise includes a full **Offline / Demo Mode Engine**:
- When backend services or physical IoT sensors (ESP32/MQTT) are not connected, the application seamlessly engages **DEMO DATA** mode.
- Clearly displays `DEMO MODE` or `ONLINE (DEMO)` badges on hardware devices so judges and reviewers know simulated telemetry is in effect.
- Zero infinite loaders or freezing: Every screen (Intelligence Center, Predictions, Knapsack Optimizer, Devices, Reports) loads immediately with realistic industrial telemetry.

### 🚀 Features Available in the APK
- **1. Dashboard**: Real-time CO₂ KPI metrics (12,480 kg CO₂), Grid Intensity (320 gCO₂/kWh), 2:00 PM–4:00 PM Clean Energy Window, AI equipment shift recommendations, and carbon trend charts.
- **2. Carbon Intelligence**: Breakdown of 5 core emission categories (Electricity, Fuel, Logistics, Production, Waste) across 7d, 30d, and 90d intervals, emission hotspots, and intensity per production unit.
- **3. Grid Intelligence + Prediction**: Live grid carbon intensity gauge, generation mix (Renewable % vs Thermal %), demand curves, and 6h / 12h / 24h ML forecast models.
- **4. AI Budget Optimization**: Interactive knapsack capital allocation optimizer for sustainability budgets (e.g., ₹10,00,000) selecting optimal interventions (Solar, LED, HVAC, EV) with ROI payback & CO₂ reduction per ₹.
- **5. Action Plan**: Horizon-based decarbonization roadmap organized by NOW (1–2 weeks), NEAR TERM (1–3 months), and LONG TERM (6+ months).
- **6. Smart Scheduling**: Grid-aware appliance scheduler (EV Chargers, HVAC, Heavy Machinery) timed to the lowest grid carbon intensity window.
- **7. Device Management & IoT**: Live telemetry status for ESP32, Smart Meters, and Industrial Motors with instant Add Device dialog (`CONNECTING...` -> `ONLINE (DEMO)`) and toggle switches.
- **8. Reports & PDF Export**: Daily, Weekly, and Monthly BRSR/ESG summaries with instantaneous on-device PDF generation (`CarbonWise_Carbon_Report_YYYY-MM-DD.pdf`).
- **9. Profile**: In-app editable profile (Name, Organization, Target, Budget) with persistent local saving.

---

## 🏗️ Architecture Overview

```
                        CarbonWise
                              │
      ┌───────────────────────┼────────────────────────┐
      │                       │                        │
 Android Mobile App      Spring Boot API         AI/ML Server
      │                       │                        │
      └───────────────┬───────┴───────────────┬────────┘
                      │                       │
                 PostgreSQL             MQTT Broker
                      │                       │
             Firebase Cloud          ESP32 / Raspberry Pi
                      │
                Google Maps API
```

---

## 📦 Project Structure

```
CarbonWise/
│
├── 📱 carbonwise-mobile/
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── services/
│   ├── widgets/
│   ├── screens/
│   ├── routes/
│   ├── assets/
│   └── main.dart
│
├── 🖥️ carbonwise-backend/
│   ├── config/
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   ├── dto/
│   ├── mapper/
│   ├── security/
│   ├── mqtt/
│   ├── ai/
│   ├── scheduler/
│   ├── notification/
│   ├── websocket/
│   ├── validation/
│   ├── utils/
│   ├── exception/
│   └── pom.xml
│
├── 🤖 carbonwise-ai/
│   ├── api/
│   ├── datasets/
│   ├── preprocessing/
│   ├── training/
│   ├── prediction/
│   ├── recommendation/
│   ├── models/
│   ├── saved_models/
│   ├── evaluation/
│   └── utils/
│
├── 🔌 carbonwise-iot/
│   ├── esp32/
│   ├── gateway/
│   ├── firmware/
│   ├── mqtt/
│   └── documentation/
│
├── 📄 README.md
├── 📄 ARCHITECTURE.md
├── 📄 API_DOCUMENTATION.md
├── 📄 DATABASE_SCHEMA.md
├── 📄 DEPLOYMENT.md
├── 📄 LICENSE
└── 📄 .gitignore
```

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter |
| Backend | Spring Boot |
| Database | PostgreSQL |
| Authentication | JWT + Spring Security |
| AI/ML | Python, Scikit-learn, TensorFlow |
| IoT | ESP32, Raspberry Pi |
| Communication | MQTT |
| Maps | Google Maps SDK |
| Notifications | Firebase Cloud Messaging |
| Cloud Storage | Firebase Storage |
| Deployment | Render (Backend), Railway (Database), Firebase |

---

## 📋 Complete System Modules

1. **Authentication Module** – Login, Register, OTP, JWT, User Roles
2. **Consumer Module** – Dashboard, Live Carbon Score, Carbon Forecast, Tips
3. **Smart Appliance Module** – Add Device, Schedule, AI Scheduling, Device Status
4. **Carbon Prediction Module** – Live Intensity, 6/12/24h Forecasts, Best Time
5. **City Monitoring Module** – Sensor Monitoring, CO₂, PM2.5, PM10, Weather
6. **GIS Module** – Google Maps, Carbon Heatmap, Pollution Heatmap, Route Analysis
7. **AI Module** – Data Collection, Training, Prediction, Recommendation Engine
8. **IoT Module** – ESP32, Raspberry Pi, Sensors, MQTT, Device Controller
9. **Notification Module** – Grid Alerts, Best Charging Time, Weather Alerts
10. **Reports Module** – Daily/Weekly/Monthly Reports, Carbon Saved, PDF Download
11. **Admin Module** – User/City/Sensor/Device Management, AI Training, Monitoring

---

## 🔐 User Roles

| Role | Access |
|------|--------|
| Consumer | Dashboard, Appliances, Predictions, Reports, Notifications |
| City Admin | City Monitoring, GIS, Sensor Management, City Reports |
| System Admin | Full System Access, User Management, AI Training |

---

## 🚀 Development Phases

### Phase 1 – Core Mobile App
- User authentication (JWT + OTP)
- Dashboard with live carbon intensity
- Google Maps integration
- Basic consumer profile

### Phase 2 – AI
- Carbon prediction (6–24 hours)
- Best time recommendation engine
- Carbon analytics and gap filling

### Phase 3 – IoT
- ESP32 sensor integration
- MQTT communication protocol
- Smart appliance control via MQTT

### Phase 4 – Smart Features
- Automatic AI scheduling
- Push notifications (FCM)
- Reports and analytics (PDF)

### Phase 5 – Production
- Admin panel (full)
- Multi-city support
- Performance optimization
- Play Store deployment

---

## 🚀 Quick Start

### Mobile App
```bash
cd carbonwise-mobile
flutter pub get
flutter run
```

### Backend
The `pom.xml` and Spring Boot Maven plugin are inside `carbonwise-backend`. Always change into that directory before invoking Maven (or use the helper below); running `mvn spring-boot:run` from the repository root causes Maven's `No plugin found for prefix 'spring-boot'` error.

```bash
cd carbonwise-backend
mvn spring-boot:run
# Backend: http://localhost:8080
```

To start the backend and Flutter frontend together, from the repository root run:

```bash
./scripts/start-dev.sh
```
The helper verifies that port 8080 is listening before starting Flutter. Stop both processes with `Ctrl+C`.

### AI Server
```bash
cd carbonwise-ai
pip install -r requirements.txt
python api/app.py
```

### IoT Devices
```bash
cd carbonwise-iot
# Flash ESP32 via Arduino IDE or PlatformIO
# Run Raspberry Pi gateway
python gateway/mqtt_gateway.py
```

---

## 📄 Documentation

- [API Documentation](API_DOCUMENTATION.md) – Complete REST API reference
- [Database Schema](DATABASE_SCHEMA.md) – PostgreSQL table definitions
- [Deployment Guide](DEPLOYMENT.md) – Production deployment instructions
- [Architecture](ARCHITECTURE.md) – System architecture overview

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

> Built with "Muhil" for a greener Tamil Nadu
