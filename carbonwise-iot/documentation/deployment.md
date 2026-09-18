# IoT Deployment Guide

## ESP32 Sensor Nodes
1. Flash firmware via Arduino IDE or PlatformIO
2. Configure WiFi credentials and MQTT broker
3. Deploy at monitoring locations (traffic intersections, industrial zones)

## Raspberry Pi Gateway
1. Install Python 3.9+ and pip
2. `pip install paho-mqtt`
3. Run `python gateway/mqtt_gateway.py`
4. Connect GPIO relays for smart appliance control

## MQTT Broker
1. Install Mosquitto on server
2. Create user accounts for each device
3. Configure TLS for production
