import 'dart:developer';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  bool _isConnected = false;

  Future<void> connect() async {
    client = MqttServerClient('wef828f9.ala.eu-central-1.emqxsl.com', 'flutter_client');
    client.port = 8883;
    client.secure = true;
    client.autoReconnect = true;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 5000;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs('pramod', 'ztGV4r4ssVj5EZT')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
      _isConnected = true;
      log("Connected to EMQX with username and password");
    } catch (e) {
      log("MQTT Error: $e");
      _isConnected = false;
      client.disconnect();
    }
  }

  void publish(String topic, String message) {
    if (!_isConnected) {
      log("Not connected to MQTT!");
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: true); // Retain flag
  }

  void subscribe(String topic) {
    if (!_isConnected) {
      log("Not connected to MQTT!");
      return;
    }
    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage payload = messages[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(payload.payload.message);
      log('Received message: $message from topic: ${messages[0].topic}');
    });
  }

  void disconnect() {
    if (_isConnected) {
      client.disconnect();
      _isConnected = false;
      log("Disconnected from MQTT broker");
    } else {
      log("Client is not connected, no need to disconnect");
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => client.updates;
}
