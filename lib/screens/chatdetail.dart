// import 'dart:convert';
// import 'dart:developer';

// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
// import 'package:mqtt_webrtc_example/core/componsnts/custom_textstyle.dart';
// import 'package:mqtt_webrtc_example/screens/video_call_screen.dart';
// import 'package:mqtt_webrtc_example/services/mqtt_service.dart';

// @RoutePage()
// class ChatDetail extends StatefulWidget {
//   const ChatDetail({super.key});

//   @override
//   State<ChatDetail> createState() => _ChatDetailState();
// }

// class _ChatDetailState extends State<ChatDetail> {
//   final MqttServiceHive _mqttEmqxHive = MqttServiceHive();

//   final TextEditingController _msgController = TextEditingController();
//   List<Map<String, String>> _messages = [];
//   late Stream<List<MqttReceivedMessage<MqttMessage>>>? _mqttEmqxStream;
//   @override
//   void initState() {
//     super.initState();
//     _mqttEmqxHive.prepareMqttClient();
//     subscribeToTopic('Dart/Mqtt_client/testtopic');
//   }

//   void subscribeToTopic(String topicName) {
//     _mqttEmqxHive.subscribeToTopic(topicName);
//     _mqttEmqxStream = _mqttEmqxHive.updates;
//     _mqttEmqxStream?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
//       for (final message in messages) {
//         final MqttPublishMessage payload = message.payload as MqttPublishMessage;
//         final String rawMessage = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

//         try {
//           final data = jsonDecode(rawMessage);
//           final String sender = data['sender'];
//           final String messageText = data['message'];
//           if (!_messages.any((msg) => msg['message'] == messageText && msg['sender'] == sender)) {
//             setState(() {
//               _messages.add({'sender': sender, 'message': messageText});
//             });

//             // _saveMessage({'sender': sender, 'message': messageText});
//           }
//           if (!_messages.any((msg) => msg['message'] == messageText && msg['sender'] == sender)) {}
//         } catch (e) {
//           print('Invalid message format: $rawMessage');
//         }
//       }
//     });
//   }

//   void sendMessageHveMq() {
//     if (_msgController.text.isNotEmpty) {
//       final String messageText = _msgController.text;

//       // final jsonString = jsonEncode({
//       //   'message': messageText,
//       // });
//       _mqttEmqxHive.publishMessage('Dart/Mqtt_client/testtopic', messageText);

//       setState(() {
//         _messages.add({'sender': 'You', 'message': messageText});
//       });

//       _msgController.clear();
//     }
//   }

//   @override
//   void dispose() {
//     _mqttEmqxHive.disconnect();
//     _msgController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(1.0),
//           child: Divider(height: 1.0, thickness: 1.0),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const AppBarUserInfo(),
//         actions: [
//           const Icon(Icons.call, color: Colors.black),
//           const SizedBox(width: 16),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const VideoCallScreen(roomId: 'my_room'),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.videocam, color: Colors.black),
//           ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             if (_messages.isEmpty)
//               const Center(
//                 child: Text('No messages yet'),
//               ),
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: _messages.length,
//                 itemBuilder: (context, index) {
//                   final message = _messages[index];
//                   final isFromMe = message['sender'] == 'You';

//                   if (isFromMe) {
//                     return Align(
//                       alignment: Alignment.centerRight,
//                       child: Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomText(
//                               text: message['message'] ?? '',
//                               fontSize: 12,
//                               fontWeight: FontWeight.w400,
//                               color: AppColors.white,
//                             ),
//                             if (index == _messages.length - 1)
//                               Align(
//                                 alignment: Alignment.bottomRight,
//                                 child: CustomText(
//                                   text: 'Delivered',
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.white,
//                                 ),
//                               )
//                           ],
//                         ),
//                       ),
//                     );
//                   } else {
//                     return Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
//                         child: CustomText(
//                           text: message['message'] ?? '',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                           color: AppColors.black,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//             const Divider(height: 1),
//             _buildInputBar(_msgController),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInputBar(TextEditingController msgController) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       color: Colors.white,
//       child: Row(
//         children: [
//           const Icon(Icons.add, color: Colors.black),
//           const SizedBox(width: 8),
//           const Icon(Icons.mic, color: Colors.black),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               height: 45,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               alignment: Alignment.centerLeft,
//               child: TextField(
//                 controller: msgController,
//                 decoration: const InputDecoration(
//                   hintText: 'Type a message',
//                   border: InputBorder.none,
//                 ),
//                 style: getCustomTextStyle(
//                   fontSize: 13,
//                   color: Colors.black,
//                   height: 16,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 onSubmitted: (value) {
//                   sendMessageHveMq();
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           InkWell(
//             onTap: () {
//               sendMessageHveMq();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryColor,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: const Icon(Icons.send, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AppBarUserInfo extends StatelessWidget {
//   const AppBarUserInfo({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return const Row(
//       children: [
//         CircleAvatar(
//           backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
//         ),
//         SizedBox(width: 10),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Zaire Dorwart', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
//             Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
//           ],
//         )
//       ],
//     );
//   }
// }
