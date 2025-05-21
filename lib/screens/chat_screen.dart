// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_webrtc_example/services/mqtt_service.dart';

// class ChatScreen extends StatefulWidget {
//   final String currentUserId;
//   final String chatWithUserId;

//   const ChatScreen({super.key, required this.currentUserId, required this.chatWithUserId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final MQTTService _mqtt = MQTTService();
//   final TextEditingController _msgController = TextEditingController();
//   List<Map<String, String>> _messages = [];
//   late Stream<List<MqttReceivedMessage<MqttMessage>>>? _mqttStream;

//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//     _initMQTT();
//   }

//   Future<void> _loadMessages() async {
//     final box = Hive.box('chat_messages');
//     final List<Map<String, String>> storedMessages = List<Map<String, String>>.from(box.get(widget.currentUserId) ?? []);
//     setState(() {
//       _messages = storedMessages;
//     });
//   }

//   Future<void> _saveMessage(Map<String, String> message) async {
//     final box = Hive.box('chat_messages');
//     _messages.add(message);
//     await box.put(widget.currentUserId, _messages);
//   }

//   Future<void> _initMQTT() async {
//     await _mqtt.connect();

//     // Subscribe to the current user's topic only once
//     _mqtt.subscribe('chat/${widget.currentUserId}');

//     // Listen for incoming messages
//     _mqttStream = _mqtt.updates;
//     _mqttStream?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
//       final MqttPublishMessage payload = messages[0].payload as MqttPublishMessage;
//       final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

//       try {
//         final data = jsonDecode(rawMessage);
//         final String sender = data['sender'];
//         final String message = data['message'];

//         // Avoid adding duplicate messages
//         if (!_messages.any((msg) => msg['message'] == message && msg['sender'] == sender)) {
//           setState(() {
//             _messages.add({'sender': sender, 'message': message});
//           });

//           _saveMessage({'sender': sender, 'message': message});
//         }
//       } catch (e) {
//         print('Invalid message format: $rawMessage');
//       }
//     });
//   }

//   void _sendMessage() {
//     if (_msgController.text.isNotEmpty) {
//       final String messageText = _msgController.text;

//       // Create a JSON payload
//       final jsonString = jsonEncode({
//         'sender': widget.currentUserId,
//         'message': messageText,
//       });

//       // Publish the message to the recipient's topic
//       _mqtt.publish('chat/${widget.chatWithUserId}', jsonString);

//       setState(() {
//         _messages.add({'sender': 'You', 'message': messageText});
//       });

//       _saveMessage({'sender': 'You', 'message': messageText});
//       _msgController.clear();
//     }
//   }

//   @override
//   void dispose() {
//     // Disconnect MQTT listener when the screen is disposed
//     _mqtt.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Chat with ${widget.chatWithUserId}')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isSentByMe = message['sender'] == 'You';

//                 return Align(
//                   alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: InkWell(
//                       onTap: () {
//                         // final box = Hive.box('chat_messages');
//                         // box.clear();
//                       },
//                       child: Text(
//                         message['message']!,
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _msgController,
//                     decoration: InputDecoration(hintText: 'Enter your message'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
