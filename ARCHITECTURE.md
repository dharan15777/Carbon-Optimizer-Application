# CarbonWise – System Architecture

## Architecture

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

## Final Deployment Architecture

```
                    Android Application
                           │
                     Internet (HTTPS)
                           │
                  Spring Boot REST API
                           │
        ┌──────────────────┼───────────────────┐
        │                  │                   │
 PostgreSQL DB      AI Prediction API     MQTT Broker
        │                  │                   │
        └──────────────────┼───────────────────┘
                           │
                  ESP32 / Raspberry Pi
                           │
                  Environmental Sensors
```

## Technology Stack

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

## Mobile App Architecture (Flutter)

```
lib/
├── main.dart                (App entry point)
├── core/
│   ├── constants/           (AppConstants)
│   ├── theme/               (AppTheme, colors)
│   └── utils/               (Helpers)
├── models/                  (9 data models)
├── repositories/            (8 data repositories)
├── services/                (API, Auth, Notification)
├── widgets/                 (Shared UI components)
├── providers/               (9 state providers)
├── screens/                 (10 screens)
├── routes/                  (GoRouter configuration)
└── assets/                  (Images, icons, animations)
```

## Backend Architecture (Spring Boot)

```
src/main/java/com/carbonwise/
├── CarbonWiseApplication.java
├── config/                  (Cors, MQTT configuration)
├── controller/              (8 REST controllers)
├── service/                 (Auth, Prediction, Report)
├── repository/              (9 JPA repositories)
├── entity/                  (10 JPA entities)
├── dto/                     (9 request/response DTOs)
├── mapper/                  (Entity → DTO mappers)
├── security/                (JWT, AuthFilter, SecurityConfig)
├── mqtt/                    (MQTT service)
├── ai/                      (AI client service)
├── scheduler/               (Scheduled tasks)
├── notification/            (Push notification service)
├── websocket/               (Live data WebSocket)
├── validation/              (Input validation)
├── utils/                   (Carbon calculator)
└── exception/               (Global error handler)
```

## AI/ML Architecture (Python)

```
carbonwise-ai/
├── api/                     (Flask REST API)
├── datasets/                (Training data CSVs)
├── preprocessing/           (Data cleaning, feature engineering)
├── training/                (Random Forest, LSTM training)
├── prediction/              (Carbon predictor)
├── recommendation/          (Device-specific recommender)
├── models/                  (Model architecture definitions)
├── saved_models/            (Trained model files)
├── evaluation/              (Model evaluation metrics)
├── utils/                   (Config, data loader)
├── notebooks/               (Jupyter notebooks)
└── requirements.txt
```

## IoT Architecture

```
carbonwise-iot/
├── esp32/                   (ESP32 sensor node firmware)
├── gateway/                 (Raspberry Pi MQTT gateway)
├── firmware/                (Smart plug, EV charger controllers)
├── mqtt/                    (Broker configuration)
└── documentation/           (Sensors, deployment docs)
```

## Modules

1. Authentication Module (JWT + OTP + 3 Roles)
2. Consumer Module (Dashboard, Live Carbon, Tips)
3. Smart Appliance Module (CRUD, Scheduling)
4. Carbon Prediction Module (6/12/24h Forecasts)
5. City Monitoring Module (Sensors, Pollution)
6. GIS Module (Maps, Heatmaps, Risk Zones)
7. AI Module (Prediction, Recommendation)
8. IoT Module (ESP32, RPi, MQTT)
9. Notification Module (7 notification types)
10. Reports Module (Daily/Weekly/Monthly + PDF)
11. Admin Module (Full system management)

## Development Phases

- **Phase 1** – Core Mobile App (Auth, Dashboard, Maps)
- **Phase 2** – AI (Carbon Prediction, Recommendations)
- **Phase 3** – IoT (ESP32, MQTT, Smart Appliance Control)
- **Phase 4** – Smart Features (Auto Scheduling, Notifications, Reports)
- **Phase 5** – Production (Admin Panel, Multi-city, Play Store)
