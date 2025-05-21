// ignore_for_file: constant_identifier_names

import 'dart:developer';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTServiceEmqx {
  late MqttServerClient client;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

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
      log("❌ Not connected to MQTT!");
      return;
    }

    client.subscribe(topic, MqttQos.atLeastOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final MqttPublishMessage payload = message.payload as MqttPublishMessage;
        final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

        log('📩 Received message: $rawMessage from topic: ${message.topic}');
      }
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

///[MQTT using hivemq]
enum MqttCurrentConnectionState { IDLE, CONNECTING, CONNECTED, DISCONNECTED, ERROR_WHEN_CONNECTING }

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MqttServiceHive {
  late MqttServerClient client;
  bool isConnected = false;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort('538364e425924956abf3da75eaa47735.s1.eu.hivemq.cloud', 'pramod', 8883);
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
  }

  void subscribeToTopic(String topicName) {
    client.subscribe(topicName, MqttQos.atLeastOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final MqttPublishMessage payload = message.payload as MqttPublishMessage;
        final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

        log('📩 Received message: $rawMessage from topic: ${message.topic}');
      }
    });
  }

  Future<void> _connectClient() async {
    try {
      log('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect('hivemq.webclient.1747820407235', "4Cdz2f*19NVHm%Bk&R!o");
    } on Exception catch (e) {
      log('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      log('client connected');
    } else {
      log('ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void publishMessage(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    log('Publishing message "$message" to topic ${'Dart/Mqtt_client/testtopic'}');
    if (builder.payload != null) {
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      log('Error: Payload is null, message not published.');
    }
  }

  void onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void onDisconnected() {
    log('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    log('OnConnected client callback - Client connection was sucessful');
  }

  void disconnect() {
    if (isConnected) {
      client.disconnect();
      isConnected = false;
      log("Disconnected from MQTT broker");
    } else {
      log("Client is not connected, no need to disconnect");
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => client.updates;
}
