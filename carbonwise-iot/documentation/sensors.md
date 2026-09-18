# Supported Sensors

| Sensor | Type | Interface | Range | Accuracy |
|--------|------|-----------|-------|----------|
| MH-Z19B | CO₂ | UART | 0-5000 ppm | ±50 ppm |
| PMS5003 | PM2.5/PM10 | UART | 0-1000 μg/m³ | ±10% |
| DHT22 | Temp/Humidity | GPIO | -40~80°C / 0-100% RH | ±0.5°C / ±2% |
| SCD30 | CO₂ | I²C | 0-40000 ppm | ±30 ppm |

## ESP32 Pin Mapping
- DHT22 → GPIO 23
- MH-Z19B → UART2 (RX: GPIO 16, TX: GPIO 17)
- PMS5003 → UART1 (RX: GPIO 18, TX: GPIO 19)
- SCD30 → I²C (SDA: GPIO 21, SCL: GPIO 22)
- Relay (Smart Plug) → GPIO 26
- Relay (EV Charger) → GPIO 27
