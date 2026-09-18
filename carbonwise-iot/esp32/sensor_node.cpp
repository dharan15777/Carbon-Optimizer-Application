/*
 * CarbonWise ESP32 Sensor Node
 * Reads: CO2 (MH-Z19B), PM2.5 (PMS5003), Temp/Humidity (DHT22)
 * Sends data via MQTT to backend
 */
#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
const char* MQTT_BROKER = "mqtt.carbonwise.in";
const int MQTT_PORT = 1883;
const char* MQTT_CLIENT_ID = "esp32_sensor_01";
const char* MQTT_TOPIC = "carbonwise/sensor/data";

#define DHT_PIN 23
#define DHT_TYPE DHT22
#define CO2_RX_PIN 16
#define CO2_TX_PIN 17
#define SENSOR_READ_INTERVAL 30000

WiFiClient espClient;
PubSubClient mqtt(espClient);
DHT dht(DHT_PIN, DHT_TYPE);

void setup() {
    Serial.begin(115200);
    dht.begin();
    Serial2.begin(9600, SERIAL_8N1, CO2_RX_PIN, CO2_TX_PIN);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
    Serial.println("WiFi Connected");
    mqtt.setServer(MQTT_BROKER, MQTT_PORT);
}

void reconnect_mqtt() {
    while (!mqtt.connected()) {
        if (mqtt.connect(MQTT_CLIENT_ID)) { Serial.println("MQTT Connected"); mqtt.subscribe("carbonwise/device/control"); }
        else { delay(5000); }
    }
}

float read_co2() {
    byte cmd[9] = {0xFF, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79};
    byte response[9];
    Serial2.write(cmd, 9);
    Serial2.readBytes(response, 9);
    if (response[0] == 0xFF && response[1] == 0x86) return (float)((response[2] << 8) + response[3]);
    return -1;
}

void publish_sensor_data(float co2, float pm25, float pm10, float temp, float humidity) {
    StaticJsonDocument<256> doc;
    doc["sensorId"] = MQTT_CLIENT_ID;
    doc["co2"] = co2; doc["pm25"] = pm25; doc["pm10"] = pm10;
    doc["temperature"] = temp; doc["humidity"] = humidity;
    char buffer[256]; serializeJson(doc, buffer);
    mqtt.publish(MQTT_TOPIC, buffer);
}

void loop() {
    if (!mqtt.connected()) reconnect_mqtt();
    mqtt.loop();
    static unsigned long lastRead = 0;
    if (millis() - lastRead > SENSOR_READ_INTERVAL) {
        lastRead = millis();
        float co2 = read_co2();
        float temp = dht.readTemperature();
        float humidity = dht.readHumidity();
        if (temp != NAN && humidity != NAN) publish_sensor_data(co2, 0.0, 0.0, temp, humidity);
    }
}
