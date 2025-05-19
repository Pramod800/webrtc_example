import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_webrtc_example/services/mqtt_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MQTTService _mqtt = MQTTService();
  final TextEditingController _msgController = TextEditingController();
  final String _clientId = "client123";
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initMQTT();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _messages = [];
    });
  }

  Future<void> _saveMessage(Map<String, String> message) async {
    // Save the message to local storage (e.g., Hive, SharedPreferences, or SQLite)
    // For now, this is just a placeholder
    _messages.add(message);
  }

  Future<void> _initMQTT() async {
    await _mqtt.connect();
    _mqtt.subscribe("chat/room1");

    _mqtt.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage payload = messages[0].payload as MqttPublishMessage;
      final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      try {
        final data = jsonDecode(rawMessage);
        final String sender = data.containsKey("sender") ? data["sender"] : "other";
        final String message = data["message"];

        if (sender != _clientId) {
          final newMessage = {"sender": "other", "message": message};
          setState(() => _messages.add(newMessage));
          _saveMessage(newMessage); // Save to local storage
        }
      } catch (e) {
        print("Invalid message format: $rawMessage");
      }
    });
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      final String messageText = _msgController.text;
      final jsonString = jsonEncode({"sender": _clientId, "message": messageText});

      _mqtt.publish("chat/room1", jsonString);
      final newMessage = {"sender": "you", "message": messageText};
      setState(() => _messages.add(newMessage));
      _saveMessage(newMessage); // Save to local storage
      _msgController.clear();
    }
  }

  @override
  void dispose() {
    _mqtt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Room"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSentByMe = message["sender"] == "you";

                  return Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message["message"]!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: "Enter your message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
