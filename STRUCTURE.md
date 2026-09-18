# 🌿 CarbonWise – Project Structure & Tree

> Comprehensive directory layout, module breakdown, and architecture hierarchy for the CarbonWise AI Carbon Intelligence Platform.

---

## 📑 Table of Contents
1. [Architecture Overview](#-architecture-overview)
2. [Complete Project Tree](#-complete-project-tree)
3. [Module & Directory Breakdown](#-module--directory-breakdown)
   - [📱 carbonwise-mobile (Flutter App)](#-carbonwise-mobile-flutter-app)
   - [🖥️ carbonwise-backend (Spring Boot API)](#️-carbonwise-backend-spring-boot-api)
   - [🤖 carbonwise-ai (AI/ML Microservice)](#-carbonwise-ai-aiml-microservice)
   - [🔌 carbonwise-iot (IoT Sensors & Firmware)](#-carbonwise-iot-iot-sensors--firmware)
   - [🌐 frontend (Web Dashboard)](#-frontend-web-dashboard)
   - [📦 Root Files & Scripts](#-root-files--scripts)
4. [Component Interaction & Communication Matrix](#-component-interaction--communication-matrix)
5. [Summary Quick Reference](#-summary-quick-reference)

---

## 🏗️ Architecture Overview

```
                          ┌───────────────────────────┐
                          │   CarbonWise Ecosystem    │
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

## 🌳 Complete Project Tree

```
Carbonwise-Application/
├── .github/
│   └── workflows/
│       └── build_apk.yml                         # Automated Android APK CI workflow
├── archive/
│   └── web-prototype/
│       ├── index.html                            # Prototype user interface
│       ├── script.js                             # Prototype interactive logic
│       └── styles.css                            # Prototype styling rules
├── carbonwise-ai/
│   ├── api/
│   │   └── app.py                                # FastAPI REST service endpoints
│   ├── datasets/
│   │   └── README.md                             # Dataset catalog and sourcing instructions
│   ├── evaluation/
│   │   └── evaluate.py                           # Model evaluation and metrics scripts
│   ├── notebooks/
│   │   └── README.md                             # Research and exploration Jupyter notebooks
│   ├── prediction/
│   │   └── predictor.py                          # Carbon intensity inference engine
│   ├── preprocessing/
│   │   └── data_cleaner.py                       # Data pipeline, normalization, and cleansing
│   ├── recommendation/
│   │   └── recommender.py                        # Smart appliance scheduling & shifting recommendations
│   ├── saved_models/
│   │   └── README.md                             # Serialized models registry (.pkl / .onnx / .h5)
│   ├── training/
│   │   └── train.py                              # ML model training workflows
│   ├── utils/
│   │   ├── config.py                             # ML engine configuration & hyperparams
│   │   └── data_loader.py                        # Dataset parsers and batch loaders
│   └── requirements.txt                          # Python dependencies (FastAPI, Scikit-learn, etc.)
├── carbonwise-backend/
│   ├── sql/
│   │   └── schema.sql                            # Relational database schema definitions
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/
│   │       │       └── carbonwise/
│   │       │           ├── ai/
│   │       │           │   └── AiServiceClient.java          # HTTP client communicating with AI microservice
│   │       │           ├── config/
│   │       │           │   ├── CorsConfig.java               # Cross-Origin Resource Sharing settings
│   │       │           │   └── MqttConfig.java               # Spring MQTT integration & client configuration
│   │       │           ├── controller/
│   │       │           │   ├── AdminController.java          # Administrative endpoints
│   │       │           │   ├── AuthController.java           # Authentication (Register, Login, Token)
│   │       │           │   ├── ConsumerController.java       # Consumer metrics & consumption endpoints
│   │       │           │   ├── DeviceController.java         # Smart device & appliance management
│   │       │           │   ├── GisController.java            # Geographic Information System & grid mapping
│   │       │           │   ├── NotificationController.java   # User alerts & notification management
│   │       │           │   ├── PredictionController.java     # Grid carbon forecast endpoints
│   │       │           │   ├── ReportController.java         # Carbon footprint and emissions reports
│   │       │           │   ├── ScheduleController.java       # Automated device scheduling endpoints
│   │       │           │   └── SensorController.java         # IoT sensor registration & telemetry
│   │       │           ├── dto/
│   │       │           │   ├── AuthDTO.java                  # Auth request/response data transfers
│   │       │           │   ├── CarbonDTO.java                # Carbon intensity metrics DTO
│   │       │           │   ├── DashboardDTO.java             # Aggregated dashboard data transfers
│   │       │           │   ├── DeviceDTO.java                # IoT device payload representations
│   │       │           │   ├── PredictionDTO.java            # Prediction response transfers
│   │       │           │   ├── ReportDTO.java                # Carbon accounting report transfers
│   │       │           │   ├── ScheduleDTO.java              # Appliance scheduling transfers
│   │       │           │   ├── SensorDTO.java                # Sensor telemetry transfers
│   │       │           │   └── UserDTO.java                  # User profile and role transfers
│   │       │           ├── entity/
│   │       │           │   ├── AIModel.java                  # Registered ML model metadata
│   │       │           │   ├── CarbonIntensity.java          # Historical and current grid carbon intensity
│   │       │           │   ├── City.java                     # Urban zones and municipal boundaries
│   │       │           │   ├── Device.java                   # Consumer IoT appliances and actuators
│   │       │           │   ├── Notification.java             # Broadcast and targeted notifications
│   │       │           │   ├── Report.java                   # Historical footprint calculation records
│   │       │           │   ├── Schedule.java                 # Shiftable appliance run schedules
│   │       │           │   ├── Sensor.java                   # Physical IoT sensor devices
│   │       │           │   ├── SensorData.java               # Time-series telemetry readings
│   │       │           │   └── User.java                     # Application users (Admin & Consumer)
│   │       │           ├── exception/
│   │       │           │   ├── GlobalExceptionHandler.java   # Centralized HTTP error handling
│   │       │           │   ├── ResourceNotFoundException.java# 404 Entity missing exception
│   │       │           │   ├── UnauthorizedException.java    # 401/403 Security violation exception
│   │       │           │   └── UserAlreadyExistsException.java# 409 Conflict exception
│   │       │           ├── mapper/
│   │       │           │   ├── CarbonMapper.java             # Entity-DTO mapping for carbon data
│   │       │           │   ├── DeviceMapper.java             # Entity-DTO mapping for devices
│   │       │           │   └── UserMapper.java               # Entity-DTO mapping for users
│   │       │           ├── mqtt/
│   │       │           │   └── MqttService.java              # Pub/Sub handling for IoT sensor feeds
│   │       │           ├── notification/
│   │       │           │   └── NotificationService.java      # Dispatcher for alerts & push notifications
│   │       │           ├── repository/
│   │       │           │   ├── CarbonIntensityRepository.java# Data access for carbon intensity values
│   │       │           │   ├── CityRepository.java           # Data access for regional zones
│   │       │           │   ├── DeviceRepository.java         # Data access for smart appliances
│   │       │           │   ├── NotificationRepository.java   # Data access for alert history
│   │       │           │   ├── ReportRepository.java         # Data access for emissions reports
│   │       │           │   ├── ScheduleRepository.java       # Data access for appliance schedules
│   │       │           │   ├── SensorDataRepository.java     # Data access for sensor telemetry
│   │       │           │   ├── SensorRepository.java         # Data access for registered hardware
│   │       │           │   └── UserRepository.java           # Data access for user accounts
│   │       │           ├── scheduler/
│   │       │           │   └── ScheduleChecker.java          # Cron job to trigger scheduled appliances
│   │       │           ├── security/
│   │       │           │   ├── JwtAuthFilter.java            # Stateless JWT authorization filter
│   │       │           │   ├── JwtUtil.java                  # Token generation, signing & validation
│   │       │           │   └── SecurityConfig.java           # Spring Security filter chain configuration
│   │       │           ├── service/
│   │       │           │   ├── AuthService.java              # Authentication and credentials validation
│   │       │           │   ├── PredictionService.java        # Interface for forecast generation
│   │       │           │   └── ReportService.java            # Footprint aggregation and report creation
│   │       │           ├── utils/
│   │       │           │   └── CarbonCalculator.java         # Mathematical conversion and emission formulas
│   │       │           ├── validation/
│   │       │           │   ├── AuthValidation.java           # Validation logic for user requests
│   │       │           │   └── DeviceValidation.java         # Validation rules for IoT operations
│   │       │           ├── websocket/
│   │       │           │   └── CarbonWebSocketHandler.java   # Real-time WebSocket streaming
│   │       │           └── CarbonWiseApplication.java        # Spring Boot entry point (`main()`)
│   │       └── resources/
│   │           └── application.yml                       # Backend configuration (DB, JWT, Ports, MQTT)
│   ├── Dockerfile                                        # Container image build specification
│   └── pom.xml                                           # Maven build descriptor & dependencies
├── carbonwise-iot/
│   ├── documentation/
│   │   ├── deployment.md                                 # Hardware installation & circuit diagram guide
│   │   └── sensors.md                                    # Sensor specs (SCT-013, ACS712, MQ-135)
│   ├── esp32/
│   │   └── sensor_node.cpp                               # ESP32 C++ firmware for telemetry collection
│   ├── firmware/
│   │   ├── ev_charger_controller.cpp                     # Relay & duty-cycle controller for EV charging
│   │   └── smart_plug_controller.cpp                     # Controllable smart relay firmware
│   ├── gateway/
│   │   └── mqtt_gateway.py                               # Edge translation gateway (Serial/Zigbee -> MQTT)
│   └── mqtt/
│       └── mqtt_broker_config.md                         # Topics, ACLs, and broker architecture setup
├── carbonwise-mobile/
│   ├── android/                                          # Native Android runner & Gradle build files
│   ├── assets/
│   │   ├── animations/                                   # Lottie animation assets
│   │   ├── icons/                                        # App iconography
│   │   └── images/                                       # Raster & vector graphics
│   ├── ci/
│   │   └── build-apk.yml                                 # Local/CI script for APK compilation
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   └── app_constants.dart                    # App-wide global constants and keys
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart                        # Eco-friendly colors, typography, theme data
│   │   │   └── utils/
│   │   │       └── helpers.dart                          # Date formatters, math utilities, validators
│   │   ├── models/
│   │   │   ├── carbon_intensity_model.dart               # Carbon measurement data model
│   │   │   ├── device_model.dart                         # Connected appliance representation
│   │   │   ├── notification_model.dart                   # Alert item model
│   │   │   ├── prediction_model.dart                     # Forecast time series model
│   │   │   ├── report_model.dart                         # Emissions report model
│   │   │   ├── schedule_model.dart                       # Automated appliance schedule model
│   │   │   ├── sensor_model.dart                         # Hardware sensor model
│   │   │   └── user_model.dart                           # Logged-in user and session model
│   │   ├── providers/
│   │   │   ├── auth_provider.dart                        # Authentication state management
│   │   │   ├── carbon_provider.dart                      # Live carbon intensity state
│   │   │   ├── device_provider.dart                      # Smart appliance management state
│   │   │   ├── map_provider.dart                         # Grid GIS & heat map state
│   │   │   ├── notification_provider.dart                # Notification inbox state
│   │   │   ├── prediction_provider.dart                  # Forecast & peak demand state
│   │   │   ├── report_provider.dart                      # Consumption reports state
│   │   │   └── sensor_provider.dart                      # Live hardware sensor telemetry state
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart                      # Auth repository communicating with backend
│   │   │   ├── carbon_repository.dart                    # Carbon data repository
│   │   │   ├── device_repository.dart                    # Device state repository
│   │   │   ├── map_repository.dart                       # GIS zones repository
│   │   │   ├── notification_repository.dart              # Notification history repository
│   │   │   ├── prediction_repository.dart                # Predictions repository
│   │   │   ├── report_repository.dart                    # Reports repository
│   │   │   └── sensor_repository.dart                    # Sensors repository
│   │   ├── routes/
│   │   │   └── app_router.dart                           # Route definitions and navigation guard
│   │   ├── screens/
│   │   │   ├── admin/
│   │   │   │   └── admin_screen.dart                     # Grid administrator & municipal oversight screen
│   │   │   ├── appliances/
│   │   │   │   └── appliances_screen.dart               # Smart appliances list & control toggles
│   │   │   ├── authentication/
│   │   │   │   ├── login_screen.dart                     # User sign-in interface
│   │   │   │   └── register_screen.dart                  # New user registration interface
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_screen.dart                 # Primary consumer carbon dashboard
│   │   │   ├── maps/
│   │   │   │   └── maps_screen.dart                      # Regional carbon intensity map
│   │   │   ├── notifications/
│   │   │   │   └── notifications_screen.dart             # Alert feed and grid warnings
│   │   │   ├── prediction/
│   │   │   │   └── prediction_screen.dart                # 24-hour predictive emission charts
│   │   │   ├── profile/
│   │   │   │   └── profile_screen.dart                   # User account & preferences screen
│   │   │   ├── reports/
│   │   │   │   └── reports_screen.dart                   # Periodic emissions analytics & exports
│   │   │   └── scheduler/
│   │   │       └── scheduler_screen.dart                 # Smart load-shifting & timer configuration
│   │   ├── services/
│   │   │   ├── api_service.dart                          # Centralized HTTP/REST client (Dio/Http)
│   │   │   ├── auth_service.dart                         # Token storage & session persistence
│   │   │   └── notification_service.dart                 # Push notification handler (FCM)
│   │   ├── widgets/
│   │   │   ├── carbon_gauge.dart                         # Real-time circular carbon intensity gauge
│   │   │   ├── grid_mix_card.dart                        # Clean energy vs fossil fuel mix breakdown
│   │   │   └── main_shell.dart                           # Bottom navigation scaffold and layout wrapper
│   │   └── main.dart                                     # Flutter mobile entry point (`runApp()`)
│   ├── test/
│   │   └── widget_test.dart                              # Flutter unit & widget tests
│   ├── BUILD.md                                          # Android/iOS compilation and release guide
│   ├── README.md                                         # Mobile application documentation
│   ├── analysis_options.yaml                             # Dart linter & code quality rules
│   └── pubspec.yaml                                      # Flutter project dependencies & asset manifest
├── frontend/
│   ├── app.js                                            # Web dashboard JavaScript logic
│   ├── index.html                                        # Web dashboard layout
│   └── styles.css                                        # Web dashboard CSS styles
├── scripts/
│   └── start-dev.sh                                      # Developer setup script to launch all microservices
├── .gitignore                                            # Git version control exclusions
├── API_DOCUMENTATION.md                                  # Comprehensive REST & WebSocket API specification
├── ARCHITECTURE.md                                       # High-level system architecture and design principles
├── DATABASE_SCHEMA.md                                    # PostgreSQL database entities, tables, and relationships
├── DEPLOYMENT.md                                          # Docker, Kubernetes, and Cloud deployment instructions
├── LICENSE                                               # MIT Open Source License
├── README.md                                             # Main project introduction, features & setup guide
└── STRUCTURE.md                                          # Complete directory layout and file tree (this file)
```

---

## 🔍 Module & Directory Breakdown

### 📱 carbonwise-mobile (Flutter App)
Cross-platform consumer and administrator mobile client built with Flutter.
- **`lib/main.dart`**: Application startup, theme registration, and root provider configuration.
- **`lib/core/`**: Shared theme styling, eco-palette definitions, constants, and helper functions.
- **`lib/models/`**: Strongly typed data models representing backend entities and API responses.
- **`lib/providers/`**: Reactive state management handling real-time data binding to the UI.
- **`lib/repositories/`**: Clean architecture abstraction layer between data sources and state providers.
- **`lib/screens/`**: UI screens divided into consumer views (Dashboard, Appliances, Maps, Scheduler) and municipal view (Admin).
- **`lib/services/`**: Network abstraction, secure token persistence, and notification dispatchers.
- **`lib/widgets/`**: Reusable custom widgets including the dynamic Carbon Gauge and Grid Mix cards.

---

### 🖥️ carbonwise-backend (Spring Boot API)
Central business logic and orchestration engine powered by Java 17 and Spring Boot 3.
- **`src/main/java/com/carbonwise/CarbonWiseApplication.java`**: Spring Boot application entry point.
- **`controller/`**: Exposes REST endpoints for auth, carbon data, smart devices, GIS zones, and admin tasks.
- **`service/`**: Implements core business logic, report generation, and scheduling triggers.
- **`entity/` & `repository/`**: JPA entity definitions and Spring Data repositories interfacing with PostgreSQL.
- **`dto/` & `mapper/`**: Data Transfer Objects and converters to maintain contract separation.
- **`security/`**: JWT filter chain ensuring stateless authorization and role-based access control.
- **`mqtt/`**: MQTT client listener ingesting continuous time-series telemetry from edge IoT nodes.
- **`websocket/`**: Low-latency WebSocket handler streaming live emissions metrics directly to connected clients.
- **`scheduler/`**: Automated background cron tasks executing scheduled appliance runs during low-carbon windows.
- **`ai/`**: Feign/WebClient integration with the Python AI microservice for forecast generation.

---

### 🤖 carbonwise-ai (AI/ML Microservice)
Python microservice delivering predictive carbon modeling and smart appliance recommendations.
- **`api/app.py`**: FastAPI microservice serving real-time prediction and scheduling endpoints.
- **`prediction/predictor.py`**: Time-series forecast model predicting 24-hour grid carbon intensity.
- **`recommendation/recommender.py`**: Smart optimization engine calculating green energy windows for heavy appliance loads.
- **`preprocessing/data_cleaner.py`**: Ingestion normalization and feature engineering pipeline.
- **`training/train.py`**: Model training and validation scripts.
- **`evaluation/evaluate.py`**: Performance evaluation calculating MAE, RMSE, and forecasting accuracy.

---

### 🔌 carbonwise-iot (IoT Sensors & Firmware)
Hardware-level telemetry capture and actuator control.
- **`esp32/sensor_node.cpp`**: C++ firmware reading current (SCT-013) and voltage sensors, publishing over MQTT.
- **`firmware/`**: Actuator controllers for smart plugs and EV chargers with remote relay switching.
- **`gateway/mqtt_gateway.py`**: Edge gateway bridging local serial/RF telemetry into the central MQTT broker.
- **`documentation/`**: Circuit wiring diagrams, sensor calibrations, and deployment manual.

---

### 🌐 frontend (Web Dashboard)
Lightweight web dashboard providing an instant web interface for desktop monitoring.
- **`index.html`**: Semantic HTML5 dashboard layout.
- **`styles.css`**: Responsive styling with dark mode and eco-themed accents.
- **`app.js`**: REST API client fetching live grid metrics and rendering charts.

---

### 📦 Root Files & Scripts
- **`scripts/start-dev.sh`**: Single command automation to boot backend, AI service, and database locally.
- **`API_DOCUMENTATION.md`**: Complete REST, MQTT, and WebSocket interface contracts.
- **`ARCHITECTURE.md`**: Design patterns, layers, and infrastructure blueprints.
- **`DATABASE_SCHEMA.md`**: PostgreSQL tables, indexes, and relationship constraints.
- **`DEPLOYMENT.md`**: Production deployment protocols for cloud infrastructure.
- **`STRUCTURE.md`**: Comprehensive architectural tree map and file reference.

---

## 🔄 Component Interaction & Communication Matrix

| Source Component | Target Component | Protocol / Channel | Purpose |
| :--- | :--- | :--- | :--- |
| **carbonwise-mobile** | **carbonwise-backend** | HTTPS / REST | User authentication, device scheduling, reports |
| **carbonwise-mobile** | **carbonwise-backend** | WSS / WebSocket | Real-time carbon intensity ticker & alerts |
| **carbonwise-backend** | **carbonwise-ai** | HTTP / REST | Request 24-hr emission forecasts & green schedules |
| **carbonwise-iot** | **MQTT Broker** | MQTT (TCP 1883/8883) | Publish live power consumption & sensor readings |
| **MQTT Broker** | **carbonwise-backend** | MQTT Inbound Channel | Ingest sensor data into PostgreSQL |
| **carbonwise-backend** | **PostgreSQL** | JDBC (Port 5432) | Persistent entity and time-series data storage |

---

## ⚡ Summary Quick Reference

| Module | Primary Technology | Primary Entry Point | Port / Default Channel |
| :--- | :--- | :--- | :--- |
| **Mobile App** | Flutter 3.x / Dart | `carbonwise-mobile/lib/main.dart` | Mobile Client (Android / iOS) |
| **Backend API** | Spring Boot 3 / Java 17 | `com.carbonwise.CarbonWiseApplication` | `http://localhost:8080` |
| **AI Microservice** | FastAPI / Python 3.12 | `carbonwise-ai/api/app.py` | `http://localhost:8000` |
| **IoT Node** | C++ / Arduino / ESP-IDF | `carbonwise-iot/esp32/sensor_node.cpp` | MQTT Topic: `carbonwise/sensors/+` |
| **Web Frontend** | Vanilla HTML5 / CSS3 / JS | `frontend/index.html` | `http://localhost:5500` |
| **Database** | PostgreSQL 15+ | `carbonwise-backend/sql/schema.sql` | `localhost:5432` |
