/*
 * CarbonWise EV Charger Controller
 * ESP32-based EV charger scheduling via MQTT
 * Auto-schedules charging during clean energy windows
 */
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

const char* DEVICE_ID = "ev_charger_01";
const char* CONTROL_TOPIC = "carbonwise/device/control";
const char* STATUS_TOPIC = "carbonwise/device/status";
#define CHARGER_RELAY_PIN 27

WiFiClient espClient;
PubSubClient mqtt(espClient);

void setup() {
    Serial.begin(115200);
    pinMode(CHARGER_RELAY_PIN, OUTPUT);
    digitalWrite(CHARGER_RELAY_PIN, LOW);
    // WiFi + MQTT setup (same as smart_plug_controller)
}

void loop() {
    // Same MQTT loop, parse schedule commands with startTime/endTime
    // Auto-start charging when AI recommends clean window
}
