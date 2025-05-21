import 'dart:convert';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
import 'package:mqtt_webrtc_example/core/componsnts/custom_textstyle.dart';
import 'package:mqtt_webrtc_example/screens/video_call_screen.dart';
import 'package:mqtt_webrtc_example/services/mqtt_service.dart';

@RoutePage()
class ChatDetailScreen extends StatefulWidget {
  final String currentUserId;
  final String chatWithUserId;

  const ChatDetailScreen({super.key, required this.currentUserId, required this.chatWithUserId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final MQTTServiceEmqx _mqtt = MQTTServiceEmqx();
  final TextEditingController _msgController = TextEditingController();
  List<Map<String, String>> _messages = [];
  late Stream<List<MqttReceivedMessage<MqttMessage>>>? _mqttStream;
  bool isMqttInitialized = false;
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initMQTT();
  }

  Future<void> _loadMessages() async {
    final box = Hive.box('chat_messages');
    final List<Map<String, String>> storedMessages = List<Map<String, String>>.from(
      box.get(widget.currentUserId) ?? [],
    );
    setState(() {
      _messages = storedMessages;
    });
  }

  Future<void> _saveMessage(Map<String, String> message) async {
    final box = Hive.box('chat_messages');
    _messages.add(message);
    await box.put(widget.currentUserId, _messages);
  }

  Future<void> _initMQTT() async {
    if (isMqttInitialized) return;
    isMqttInitialized = true;

    await _mqtt.connect();

    _mqtt.subscribe('chat/${widget.currentUserId}');

    _mqttStream = _mqtt.updates;
    _mqttStream?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final MqttPublishMessage payload = message.payload as MqttPublishMessage;
        final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

        try {
          final data = jsonDecode(rawMessage);

          if (!data.containsKey('message')) {
            log('Invalid message format: Missing "message" field');
            continue;
          }

          // Use a default value for the sender if it's missing
          final String sender = data.containsKey('sender') ? data['sender'] : 'Unknown';
          final String messageText = data['message'];

          // Avoid adding duplicate messages
          if (!_messages.any((msg) => msg['message'] == messageText && msg['sender'] == sender)) {
            setState(() {
              _messages.add({'sender': sender, 'message': messageText});
            });

            _saveMessage({'sender': sender, 'message': messageText});
          }
        } catch (e) {
          log('Invalid message format: $rawMessage');
        }
      }
    });
  }

  void sendMessage(String senderId, String receiverId, String message) {}

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      final String messageText = _msgController.text;

      final jsonString = jsonEncode({
        'sender': widget.currentUserId,
        'message': messageText,
      });

      _mqtt.publish('chat/${widget.chatWithUserId}', jsonString);

      setState(() {
        _messages.add({'sender': 'You', 'message': messageText});
      });

      _saveMessage({'sender': 'You', 'message': messageText});
      _msgController.clear();
    }
  }

  @override
  void dispose() {
    _mqtt.disconnect();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppBarUserInfo(),
        actions: [
          const Icon(Icons.call, color: Colors.black),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoCallScreen(roomId: 'my_room'),
                ),
              );
            },
            icon: const Icon(Icons.videocam, color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_messages.isEmpty)
              const Center(
                child: Text('No messages yet'),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isFromMe = message['sender'] == 'You';

                  if (isFromMe) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: message['message'] ?? '',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white,
                            ),
                            if (index == _messages.length - 1)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CustomText(
                                  text: 'Delivered',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.white,
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: CustomText(
                          text: message['message'] ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const Divider(height: 1),
            _buildInputBar(_msgController),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(TextEditingController msgController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.black),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: msgController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
                style: getCustomTextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  height: 16,
                  fontWeight: FontWeight.w400,
                ),
                onSubmitted: (value) {
                  _sendMessage();
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarUserInfo extends StatelessWidget {
  const AppBarUserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zaire Dorwart', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        )
      ],
    );
  }
}
