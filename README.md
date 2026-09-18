# 🌿 Carbon-Optimizer-Application

> **AI Carbon Intelligence & Optimization Platform**  
> Real-time carbon tracking, IoT telemetry ingestion, predictive forecasting, and intelligent appliance load-shifting.

---

## 🌳 Project Structure & Architecture

The complete directory hierarchy, module breakdown, and inter-service communication protocols are documented in:

📄 **[STRUCTURE.md](STRUCTURE.md)**

### Quick Architecture Overview

```
                          ┌───────────────────────────┐
                          │ Carbon Optimizer System   │
                          └─────────────┬─────────────┘
                                        │
      ┌─────────────────────────┼─────────────────────────┐
      ▼                         ▼                         ▼
┌──────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Mobile App   │       │ Spring Boot API │       │ AI / ML Engine  │
│ (Flutter/Dart│◄─────►│ (Java 17/REST)  │◄─────►│ (Python/FastAPI)│
└──────────────┘       └────────┬────────┘       └─────────────────┘
                                │
                 ┌──────────────┴──────────────┐
                 ▼                             ▼
       ┌──────────────────┐          ┌───────────────────┐
       │ PostgreSQL (RDBMS│          │ MQTT Broker       │
       │ & TimescaleDB)   │          │ (EMQX / Mosquitto)│
       └──────────────────┘          └─────────▲─────────┘
                                               │
                                     ┌─────────┴─────────┐
                                     │ IoT Devices       │
                                     │ (ESP32 Sensors)   │
                                     └───────────────────┘
```

---

## 🖥️ Backend Service (`carbonwise-backend/`)

The core backend service is built with **Java 17** and **Spring Boot 3**.

- **API Documentation**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Database Schema**: [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) & [sql/schema.sql](carbonwise-backend/sql/schema.sql)
- **Configuration**: [application.yml](carbonwise-backend/src/main/resources/application.yml)

### Running the Backend
```bash
cd carbonwise-backend
mvn clean spring-boot:run
```
Service runs on port `8080` by default.

---

## 🌐 Web Frontend Dashboard (`frontend/`)

Interactive web monitoring dashboard for live carbon intensity tracking, GIS maps, appliance control, and analytics.

- **Layout & Structure**: [index.html](frontend/index.html)
- **Styles & Themes**: [styles.css](frontend/styles.css)
- **Application Logic & API Client**: [app.js](frontend/app.js)

### Running the Frontend
Simply open `frontend/index.html` in any modern web browser or serve it using a local HTTP server:
```bash
npx serve frontend
# or
python -m http.server 5500 --directory frontend
```
Accessible at `http://localhost:5500`.

---

## 🤖 AI / ML Microservice (`carbonwise-ai/`)

FastAPI microservice delivering 24-hour predictive carbon forecasting and smart appliance load-shifting recommendations.

- **API Entrypoint**: [api/app.py](carbonwise-ai/api/app.py)
- **Prediction Engine**: [prediction/predictor.py](carbonwise-ai/prediction/predictor.py)
- **Smart Recommender**: [recommendation/recommender.py](carbonwise-ai/recommendation/recommender.py)
- **Model Training**: [training/train.py](carbonwise-ai/training/train.py)

### Running the AI Service
```bash
cd carbonwise-ai
pip install -r requirements.txt
uvicorn api.app:app --host 0.0.0.0 --port 8000 --reload
```
API runs on `http://localhost:8000` with Swagger docs available at `http://localhost:8000/docs`.

---

## 🔌 IoT Sensors & Firmware (`carbonwise-iot/`)

Hardware sensor nodes, telemetry gateway, and smart actuator controllers.

- **ESP32 Sensor Node**: [esp32/sensor_node.cpp](carbonwise-iot/esp32/sensor_node.cpp) (Current & voltage sampling over MQTT)
- **Smart Plug Controller**: [firmware/smart_plug_controller.cpp](carbonwise-iot/firmware/smart_plug_controller.cpp)
- **EV Charger Controller**: [firmware/ev_charger_controller.cpp](carbonwise-iot/firmware/ev_charger_controller.cpp)
- **Edge Gateway**: [gateway/mqtt_gateway.py](carbonwise-iot/gateway/mqtt_gateway.py)
- **Broker & Sensor Documentation**: [documentation/](carbonwise-iot/documentation/) & [mqtt/mqtt_broker_config.md](carbonwise-iot/mqtt/mqtt_broker_config.md)

### Running the MQTT Gateway
```bash
cd carbonwise-iot/gateway
python mqtt_gateway.py
```
Telemetry published to MQTT broker topics: `carbonwise/sensors/+`.

---

## 📱 Mobile Client (`carbonwise-mobile/`)

Cross-platform Flutter application providing real-time consumer dashboards, appliance controls, and municipal grid oversight.

- **Main Entrypoint**: [lib/main.dart](carbonwise-mobile/lib/main.dart)
- **Screens**: [lib/screens/](carbonwise-mobile/lib/screens/) (Dashboard, Appliances, Maps, Scheduler, Admin, Notifications, Reports)
- **State Management**: [lib/providers/](carbonwise-mobile/lib/providers/)
- **Build Guide**: [BUILD.md](carbonwise-mobile/BUILD.md)

### Running the Mobile App
```bash
cd carbonwise-mobile
flutter pub get
flutter run
```

---

## ⚙️ Scripts & Automation (`scripts/`, `.github/`)

- **Developer Setup Script**: [scripts/start-dev.sh](scripts/start-dev.sh) (Automated local environment startup)
- **CI/CD Workflows**: `.github/workflows/build_apk.yml` (Automated Android APK build and test pipeline)
- **Mobile CI Config**: `carbonwise-mobile/ci/build-apk.yml`
