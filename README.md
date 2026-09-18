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

For the exhaustive file tree and module documentation, view **[STRUCTURE.md](STRUCTURE.md)**.
