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
