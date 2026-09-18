/*
 * CarbonWise Smart Plug Controller
 * ESP32-based relay controller for smart appliance scheduling
 * Receives ON/OFF commands via MQTT
 */
#include <WiFi.h>
#include <PubSubClient.h>

const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
const char* MQTT_BROKER = "mqtt.carbonwise.in";
const int MQTT_PORT = 1883;
const char* DEVICE_ID = "smart_plug_01";
const char* CONTROL_TOPIC = "carbonwise/device/control";
const char* STATUS_TOPIC = "carbonwise/device/status";

#define RELAY_PIN 26

WiFiClient espClient;
PubSubClient mqtt(espClient);

void setup() {
    Serial.begin(115200);
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, LOW);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) { delay(500); }
    mqtt.setServer(MQTT_BROKER, MQTT_PORT);
    mqtt.setCallback(callback);
}

void callback(char* topic, byte* payload, unsigned int length) {
    String msg;
    for (int i = 0; i < length; i++) msg += (char)payload[i];
    if (msg.indexOf("\"ON\"") >= 0) { digitalWrite(RELAY_PIN, HIGH); Serial.println("Device ON"); }
    else if (msg.indexOf("\"OFF\"") >= 0) { digitalWrite(RELAY_PIN, LOW); Serial.println("Device OFF"); }
    // Publish status
    String status = "{\"deviceId\":\"" + String(DEVICE_ID) + "\",\"status\":\"" + (digitalRead(RELAY_PIN) ? "ON" : "OFF") + "\"}";
    mqtt.publish(STATUS_TOPIC, status.c_str());
}

void reconnect() {
    while (!mqtt.connected()) {
        if (mqtt.connect(DEVICE_ID)) { mqtt.subscribe(CONTROL_TOPIC); Serial.println("MQTT Connected"); }
        else delay(5000);
    }
}

void loop() {
    if (!mqtt.connected()) reconnect();
    mqtt.loop();
}
