-- CarbonWise Database Schema - PostgreSQL

CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, role VARCHAR(20) NOT NULL CHECK (role IN ('CONSUMER', 'CITY_ADMIN', 'SYSTEM_ADMIN')),
    phone VARCHAR(20), city VARCHAR(50), profile_image VARCHAR(255), is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP
);

CREATE TABLE devices (
    id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    name VARCHAR(100) NOT NULL, type VARCHAR(30) NOT NULL CHECK (type IN ('SMART_PLUG', 'EV_CHARGER', 'AIR_CONDITIONER', 'WASHING_MACHINE', 'WATER_HEATER')),
    power_rating DOUBLE PRECISION NOT NULL, is_active BOOLEAN DEFAULT FALSE, is_scheduled BOOLEAN DEFAULT FALSE,
    schedule_id VARCHAR(36), mqtt_topic VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE schedules (
    id VARCHAR(36) PRIMARY KEY, device_id VARCHAR(36) NOT NULL REFERENCES devices(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id), start_time TIMESTAMP NOT NULL, end_time TIMESTAMP NOT NULL,
    is_ai_recommended BOOLEAN DEFAULT FALSE, estimated_carbon_saving DOUBLE PRECISION,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'RUNNING', 'COMPLETED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP
);

CREATE TABLE carbon_intensity (
    id SERIAL PRIMARY KEY, intensity DOUBLE PRECISION NOT NULL, solar_wind_percent DOUBLE PRECISION NOT NULL,
    hydro_percent DOUBLE PRECISION NOT NULL, gas_percent DOUBLE PRECISION NOT NULL, coal_percent DOUBLE PRECISION NOT NULL,
    region VARCHAR(50), timestamp TIMESTAMP NOT NULL,
    status VARCHAR(20) CHECK (status IN ('CLEAN', 'MODERATE', 'DIRTY', 'CRITICAL'))
);

CREATE TABLE sensors (
    id VARCHAR(36) PRIMARY KEY, city_id VARCHAR(36) NOT NULL, name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL, latitude DOUBLE PRECISION NOT NULL, longitude DOUBLE PRECISION NOT NULL,
    is_active BOOLEAN DEFAULT TRUE, mqtt_topic VARCHAR(100), last_reading TIMESTAMP, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sensor_data (
    id SERIAL PRIMARY KEY, sensor_id VARCHAR(36) NOT NULL REFERENCES sensors(id),
    co2 DOUBLE PRECISION NOT NULL, pm25 DOUBLE PRECISION NOT NULL, pm10 DOUBLE PRECISION NOT NULL,
    temperature DOUBLE PRECISION NOT NULL, humidity DOUBLE PRECISION NOT NULL, timestamp TIMESTAMP NOT NULL
);

CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    type VARCHAR(30) NOT NULL CHECK (type IN ('GRID_CLEAN', 'GRID_DIRTY', 'BEST_CHARGING', 'DEVICE_COMPLETED', 'HIGH_POLLUTION', 'WEATHER_ALERT', 'DAILY_REPORT')),
    title VARCHAR(100) NOT NULL, message TEXT NOT NULL, is_read BOOLEAN DEFAULT FALSE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reports (
    id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    type VARCHAR(10) NOT NULL CHECK (type IN ('DAILY', 'WEEKLY', 'MONTHLY')),
    start_date TIMESTAMP NOT NULL, end_date TIMESTAMP NOT NULL, total_carbon_used DOUBLE PRECISION NOT NULL,
    total_carbon_saved DOUBLE PRECISION NOT NULL, total_electricity_used DOUBLE PRECISION NOT NULL,
    renewable_percentage DOUBLE PRECISION NOT NULL, device_count INTEGER, pdf_url VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities (
    id VARCHAR(36) PRIMARY KEY, name VARCHAR(100) NOT NULL, state VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL, longitude DOUBLE PRECISION NOT NULL, radius_km DOUBLE PRECISION,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE energy_sources (
    id SERIAL PRIMARY KEY, region VARCHAR(50) NOT NULL, source_type VARCHAR(30) NOT NULL, percentage DOUBLE PRECISION NOT NULL, timestamp TIMESTAMP NOT NULL
);

CREATE TABLE renewable_data (
    id SERIAL PRIMARY KEY, region VARCHAR(50) NOT NULL, renewable_percentage DOUBLE PRECISION NOT NULL,
    solar_generation DOUBLE PRECISION, wind_generation DOUBLE PRECISION, hydro_generation DOUBLE PRECISION, timestamp TIMESTAMP NOT NULL
);

CREATE TABLE carbon_history (
    id SERIAL PRIMARY KEY, user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    carbon_used DOUBLE PRECISION NOT NULL, carbon_saved DOUBLE PRECISION NOT NULL,
    electricity_used DOUBLE PRECISION NOT NULL, renewable_percentage DOUBLE PRECISION, period VARCHAR(10) NOT NULL, timestamp TIMESTAMP NOT NULL
);

CREATE TABLE ai_models (
    id VARCHAR(36) PRIMARY KEY, name VARCHAR(100) NOT NULL, type VARCHAR(20) NOT NULL CHECK (type IN ('KRIGING', 'LSTM', 'RANDOM_FOREST')),
    version VARCHAR(20) NOT NULL, accuracy DOUBLE PRECISION, description TEXT, file_path VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP
);

CREATE TABLE logs (
    id SERIAL PRIMARY KEY, user_id VARCHAR(36), action VARCHAR(50) NOT NULL, entity VARCHAR(50),
    entity_id VARCHAR(36), details TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_devices_user ON devices(user_id);
CREATE INDEX idx_schedules_user ON schedules(user_id);
CREATE INDEX idx_schedules_device ON schedules(device_id);
CREATE INDEX idx_carbon_timestamp ON carbon_intensity(timestamp);
CREATE INDEX idx_sensor_data_sensor ON sensor_data(sensor_id);
CREATE INDEX idx_sensor_data_timestamp ON sensor_data(timestamp);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_reports_user ON reports(user_id);
CREATE INDEX idx_sensors_city ON sensors(city_id);
