# CarbonWise – Deployment Guide

## Architecture

```
Android App → HTTPS → Spring Boot API
                        ├── PostgreSQL DB (Railway)
                        ├── AI Prediction API (Render)
                        └── MQTT Broker (Self-hosted)
                                └── ESP32 / Raspberry Pi
                                        └── Environmental Sensors
```

---

## Prerequisites

- Java 17+
- Flutter 3.x
- Python 3.9+
- PostgreSQL 15+
- Docker (optional)

---

## 1. Backend (Spring Boot) – Render

### Environment Variables
```
JWT_SECRET=your-production-secret-key
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-email-password
AI_SERVER_URL=https://ai.carbonwise.in
MQTT_BROKER=tcp://mqtt.carbonwise.in
```

### Docker Build
```bash
cd carbonwise-backend
docker build -t carbonwise-backend .
docker run -p 8080:8080 carbonwise-backend
```

### Render Deployment
1. Connect GitHub repository
2. Set runtime: Java 17
3. Root directory: `carbonwise-backend`

Build command: `mvn clean package -DskipTests`

Start command: `java -jar target/carbonwise-backend-1.0.0.jar`
4. Set environment variables in Render dashboard
5. Deploy

---

## 2. Database (PostgreSQL) – Railway

1. Create PostgreSQL instance on Railway
2. Set connection string in backend environment:
   ```
   spring.datasource.url=jdbc:postgresql://railway-host:5432/carbonwise
   spring.datasource.username=carbonwise
   spring.datasource.password=<railway-password>
   ```
3. Run schema:
   ```bash
   psql -f carbonwise-backend/sql/schema.sql
   ```

---

## 3. AI Server – Render / Custom

```bash
cd carbonwise-ai
pip install -r requirements.txt
python api/app.py
```

### Docker
```bash
docker build -t carbonwise-ai .
docker run -p 5000:5000 carbonwise-ai
```

---

## 4. Mobile App (Flutter) – Firebase

### Build
```bash
cd carbonwise-mobile
flutter build apk --release
```

### Firebase Setup
1. Create Firebase project
2. Add Android app with package name `com.carbonwise.app`
3. Enable Firebase Cloud Messaging
4. Enable Firebase Storage
5. Download `google-services.json` to `android/app/`

### Play Store Deployment
1. Generate signed APK:
   ```bash
   flutter build appbundle --release
   ```
2. Create Google Play Console account
3. Upload AAB to Play Store
4. Set store listing, screenshots, descriptions

---

## 5. MQTT Broker

### Self-hosted (VPS)
```bash
sudo apt-get install mosquitto mosquitto-clients
# Configure /etc/mosquitto/mosquitto.conf
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
```

### Cloud MQTT
- AWS IoT Core
- HiveMQ Cloud (free tier available)

---

## 6. IoT Devices

### ESP32 Sensor Nodes
1. Install Arduino IDE + ESP32 board support
2. Install libraries: PubSubClient, DHT, ArduinoJson
3. Configure WiFi and MQTT credentials
4. Flash firmware via USB

### Raspberry Pi Gateway
1. Install Raspbian OS
2. Install Python 3 + pip
3. `pip install paho-mqtt`
4. Run gateway script as systemd service

---

## Development Phases

| Phase | Feature | Timeline |
|-------|---------|----------|
| Phase 1 | Auth, Dashboard, Maps | 2 weeks |
| Phase 2 | AI Prediction, Recommendation | 3 weeks |
| Phase 3 | IoT Integration, MQTT | 2 weeks |
| Phase 4 | Scheduling, Notifications, Reports | 2 weeks |
| Phase 5 | Admin, Multi-city, Play Store | 2 weeks |

**Total estimated: 11 weeks**

---

## Monitoring & Maintenance

- **Backend health:** `GET /health` endpoint
- **AI server health:** `GET /health` endpoint
- **Database:** Railway provides built-in monitoring
- **MQTT:** Mosquitto logs
- **Mobile crashes:** Firebase Crashlytics
- **APM:** Consider New Relic or Datadog for production
