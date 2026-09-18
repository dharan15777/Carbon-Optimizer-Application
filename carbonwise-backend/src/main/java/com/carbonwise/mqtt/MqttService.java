package com.carbonwise.mqtt;
import org.eclipse.paho.client.mqttv3.*; import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service;

@Service
public class MqttService {
    @Value("${mqtt.broker}") private String broker;
    @Value("${mqtt.client-id}") private String clientId;
    @Value("${mqtt.topic-prefix}") private String topicPrefix;
    private MqttClient mqttClient;
    public void connect() throws MqttException { MqttConnectOptions options = new MqttConnectOptions(); options.setCleanSession(true); options.setAutomaticReconnect(true); mqttClient = new MqttClient(broker, clientId, new MemoryPersistence()); mqttClient.connect(options); }
    public void publish(String topic, String payload) throws MqttException { if (mqttClient == null || !mqttClient.isConnected()) connect(); MqttMessage message = new MqttMessage(payload.getBytes()); message.setQos(1); mqttClient.publish(topicPrefix + topic, message); }
    public void subscribe(String topic, MqttCallback callback) throws MqttException { if (mqttClient == null || !mqttClient.isConnected()) connect(); mqttClient.setCallback(callback); mqttClient.subscribe(topicPrefix + topic); }
    public void disconnect() throws MqttException { if (mqttClient != null && mqttClient.isConnected()) mqttClient.disconnect(); }
}
