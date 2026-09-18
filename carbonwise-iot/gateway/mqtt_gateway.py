"""
CarbonWise MQTT Gateway for Raspberry Pi
Bridge between MQTT broker and backend, plus device controller
"""
import paho.mqtt.client as mqtt
import json
import logging
from datetime import datetime

MQTT_BROKER = "mqtt.carbonwise.in"
MQTT_PORT = 1883
MQTT_CLIENT_ID = "rpi_gateway_01"
SENSOR_DATA_TOPIC = "carbonwise/sensor/data"
DEVICE_CONTROL_TOPIC = "carbonwise/device/control"
DEVICE_STATUS_TOPIC = "carbonwise/device/status"

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("CarbonWise-Gateway")

class MQTTGateway:
    def __init__(self):
        self.client = mqtt.Client(MQTT_CLIENT_ID)
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message

    def connect(self):
        self.client.connect(MQTT_BROKER, MQTT_PORT, 60)
        self.client.loop_start()
        logger.info("MQTT Gateway connected")

    def _on_connect(self, client, userdata, flags, rc):
        logger.info(f"Connected with code {rc}")
        client.subscribe(SENSOR_DATA_TOPIC)
        client.subscribe(DEVICE_CONTROL_TOPIC)

    def _on_message(self, client, userdata, msg):
        try:
            payload = json.loads(msg.payload.decode())
            if msg.topic == SENSOR_DATA_TOPIC: self._handle_sensor_data(payload)
            elif msg.topic == DEVICE_CONTROL_TOPIC: self._handle_device_control(payload)
        except json.JSONDecodeError: logger.error(f"Invalid JSON on {msg.topic}")

    def _handle_sensor_data(self, data):
        logger.info(f"Sensor data: {data['sensorId']}")
        # Forward to Spring Boot API

    def _handle_device_control(self, data):
        device_id, action = data.get('deviceId'), data.get('action')
        logger.info(f"Device: {device_id} -> {action}")
        status = {'deviceId': device_id, 'status': action, 'timestamp': datetime.now().isoformat()}
        self.client.publish(DEVICE_STATUS_TOPIC, json.dumps(status))

    def disconnect(self):
        self.client.loop_stop()
        self.client.disconnect()

if __name__ == "__main__":
    gateway = MQTTGateway()
    gateway.connect()
    try: while True: pass
    except KeyboardInterrupt: gateway.disconnect()
