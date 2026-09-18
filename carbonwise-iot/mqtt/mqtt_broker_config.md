# CarbonWise MQTT Broker Configuration

## Mosquitto Setup
```bash
sudo apt-get install mosquitto mosquitto-clients
```

## Configuration (`/etc/mosquitto/mosquitto.conf`)
```
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
listener 9001
protocol websockets
```

## Topic Structure
```
carbonwise/
├── sensor/data          (ESP32 → Backend)
├── device/control       (Backend → Smart Plug)
├── device/status        (Smart Plug → Backend)
├── prediction/live      (AI → App)
└── notification/alert   (Backend → App)
```

## QoS Levels
| Topic | QoS | Reason |
|-------|-----|--------|
| sensor/data | 1 | At least once |
| device/control | 2 | Exactly once - critical |
| device/status | 0 | Fast delivery |
| prediction/live | 0 | Real-time |
