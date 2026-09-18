# CarbonWise – Database Schema

## Overview
PostgreSQL database with 15 tables supporting carbon tracking, IoT sensor data, AI predictions, device scheduling, and reporting.

---

## Entity Relationship

```
Users ──┬── Devices ─── Schedules
        │
        ├── Notifications
        ├── Reports
        ├── CarbonHistory
        └
Cities ─── Sensors ─── SensorData
         
CarbonIntensity (time-series)
EnergySources (time-series)
RenewableData (time-series)
AIModels (model registry)
Logs (audit)
```

---

## Table Definitions

### `users`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(100) | NOT NULL, UNIQUE |
| password | VARCHAR(255) | NOT NULL (bcrypt) |
| role | VARCHAR(20) | NOT NULL, CHECK: CONSUMER/CITY_ADMIN/SYSTEM_ADMIN |
| phone | VARCHAR(20) | |
| city | VARCHAR(50) | |
| profile_image | VARCHAR(255) | |
| is_verified | BOOLEAN | DEFAULT FALSE |
| created_at | TIMESTAMP | DEFAULT NOW() |
| updated_at | TIMESTAMP | |

### `devices`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| user_id | VARCHAR(36) | FK → users.id |
| name | VARCHAR(100) | NOT NULL |
| type | VARCHAR(30) | NOT NULL, CHECK: SMART_PLUG/EV_CHARGER/AIR_CONDITIONER/WASHING_MACHINE/WATER_HEATER |
| power_rating | DOUBLE | NOT NULL |
| is_active | BOOLEAN | DEFAULT FALSE |
| is_scheduled | BOOLEAN | DEFAULT FALSE |
| schedule_id | VARCHAR(36) | |
| mqtt_topic | VARCHAR(100) | |
| created_at | TIMESTAMP | DEFAULT NOW() |

### `schedules`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| device_id | VARCHAR(36) | FK → devices.id |
| user_id | VARCHAR(36) | FK → users.id |
| start_time | TIMESTAMP | NOT NULL |
| end_time | TIMESTAMP | NOT NULL |
| is_ai_recommended | BOOLEAN | DEFAULT FALSE |
| estimated_carbon_saving | DOUBLE | |
| status | VARCHAR(20) | NOT NULL, CHECK: PENDING/RUNNING/COMPLETED/CANCELLED |
| created_at | TIMESTAMP | DEFAULT NOW() |
| updated_at | TIMESTAMP | |

### `carbon_intensity`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| intensity | DOUBLE | NOT NULL (gCO₂/kWh) |
| solar_wind_percent | DOUBLE | NOT NULL |
| hydro_percent | DOUBLE | NOT NULL |
| gas_percent | DOUBLE | NOT NULL |
| coal_percent | DOUBLE | NOT NULL |
| region | VARCHAR(50) | |
| timestamp | TIMESTAMP | NOT NULL |
| status | VARCHAR(20) | CHECK: CLEAN/MODERATE/DIRTY/CRITICAL |

### `sensors`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| city_id | VARCHAR(36) | NOT NULL |
| name | VARCHAR(100) | NOT NULL |
| type | VARCHAR(20) | NOT NULL |
| latitude | DOUBLE | NOT NULL |
| longitude | DOUBLE | NOT NULL |
| is_active | BOOLEAN | DEFAULT TRUE |
| mqtt_topic | VARCHAR(100) | |
| last_reading | TIMESTAMP | |
| created_at | TIMESTAMP | DEFAULT NOW() |

### `sensor_data`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| sensor_id | VARCHAR(36) | FK → sensors.id |
| co2 | DOUBLE | NOT NULL (ppm) |
| pm25 | DOUBLE | NOT NULL (μg/m³) |
| pm10 | DOUBLE | NOT NULL (μg/m³) |
| temperature | DOUBLE | NOT NULL (°C) |
| humidity | DOUBLE | NOT NULL (%) |
| timestamp | TIMESTAMP | NOT NULL |

### `notifications`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| user_id | VARCHAR(36) | FK → users.id |
| type | VARCHAR(30) | NOT NULL, CHECK: GRID_CLEAN/GRID_DIRTY/BEST_CHARGING/DEVICE_COMPLETED/HIGH_POLLUTION/WEATHER_ALERT/DAILY_REPORT |
| title | VARCHAR(100) | NOT NULL |
| message | TEXT | NOT NULL |
| is_read | BOOLEAN | DEFAULT FALSE |
| created_at | TIMESTAMP | DEFAULT NOW() |

### `reports`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| user_id | VARCHAR(36) | FK → users.id |
| type | VARCHAR(10) | NOT NULL, CHECK: DAILY/WEEKLY/MONTHLY |
| start_date | TIMESTAMP | NOT NULL |
| end_date | TIMESTAMP | NOT NULL |
| total_carbon_used | DOUBLE | NOT NULL (kg CO₂) |
| total_carbon_saved | DOUBLE | NOT NULL (kg CO₂) |
| total_electricity_used | DOUBLE | NOT NULL (kWh) |
| renewable_percentage | DOUBLE | NOT NULL (%) |
| device_count | INTEGER | |
| pdf_url | VARCHAR(255) | |
| created_at | TIMESTAMP | DEFAULT NOW() |

### `cities`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| name | VARCHAR(100) | NOT NULL |
| state | VARCHAR(50) | NOT NULL |
| latitude | DOUBLE | NOT NULL |
| longitude | DOUBLE | NOT NULL |
| radius_km | DOUBLE | |
| is_active | BOOLEAN | DEFAULT TRUE |
| created_at | TIMESTAMP | DEFAULT NOW() |

### `energy_sources`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| region | VARCHAR(50) | NOT NULL |
| source_type | VARCHAR(30) | NOT NULL |
| percentage | DOUBLE | NOT NULL |
| timestamp | TIMESTAMP | NOT NULL |

### `renewable_data`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| region | VARCHAR(50) | NOT NULL |
| renewable_percentage | DOUBLE | NOT NULL |
| solar_generation | DOUBLE | |
| wind_generation | DOUBLE | |
| hydro_generation | DOUBLE | |
| timestamp | TIMESTAMP | NOT NULL |

### `carbon_history`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| user_id | VARCHAR(36) | FK → users.id |
| carbon_used | DOUBLE | NOT NULL |
| carbon_saved | DOUBLE | NOT NULL |
| electricity_used | DOUBLE | NOT NULL |
| renewable_percentage | DOUBLE | |
| period | VARCHAR(10) | NOT NULL |
| timestamp | TIMESTAMP | NOT NULL |

### `ai_models`
| Column | Type | Constraints |
|--------|------|-------------|
| id | VARCHAR(36) | PK, UUID |
| name | VARCHAR(100) | NOT NULL |
| type | VARCHAR(20) | NOT NULL, CHECK: KRIGING/LSTM/RANDOM_FOREST |
| version | VARCHAR(20) | NOT NULL |
| accuracy | DOUBLE | |
| description | TEXT | |
| file_path | VARCHAR(255) | |
| is_active | BOOLEAN | DEFAULT TRUE |
| created_at | TIMESTAMP | DEFAULT NOW() |
| updated_at | TIMESTAMP | |

### `logs`
| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| user_id | VARCHAR(36) | |
| action | VARCHAR(50) | NOT NULL |
| entity | VARCHAR(50) | |
| entity_id | VARCHAR(36) | |
| details | TEXT | |
| timestamp | TIMESTAMP | DEFAULT NOW() |

---

## Performance Indexes

```sql
CREATE INDEX idx_devices_user ON devices(user_id);
CREATE INDEX idx_schedules_user ON schedules(user_id);
CREATE INDEX idx_schedules_device ON schedules(device_id);
CREATE INDEX idx_carbon_timestamp ON carbon_intensity(timestamp);
CREATE INDEX idx_sensor_data_sensor ON sensor_data(sensor_id);
CREATE INDEX idx_sensor_data_timestamp ON sensor_data(timestamp);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_reports_user ON reports(user_id);
CREATE INDEX idx_sensors_city ON sensors(city_id);
```
