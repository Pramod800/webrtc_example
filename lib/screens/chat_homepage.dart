import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
import 'package:mqtt_webrtc_example/core/componsnts/custom_textstyle.dart';
import 'package:mqtt_webrtc_example/core/router/router.gr.dart';
import 'package:mqtt_webrtc_example/screens/chatdetail.dart';

@RoutePage()
class ChatHomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stories = [
    {'name': 'Terry', 'image': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Craig', 'image': 'https://i.pravatar.cc/150?img=2'},
    {'name': 'Roger', 'image': 'https://i.pravatar.cc/150?img=3'},
    {'name': 'Nolan', 'image': 'https://i.pravatar.cc/150?img=4'},
    {'name': 'Jocelyn', 'image': 'https://i.pravatar.cc/150?img=6'},
    {'name': 'Taylor', 'image': 'https://i.pravatar.cc/150?img=12'},
  ];

  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Angel Curtis',
      'message': 'Please help me find a good monitor for t...',
      'time': '02:11',
      'unread': 2,
      'image': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Zaire Dorwart',
      'message': 'Gacor pisan kang',
      'time': '02:11',
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=6',
    },
    {
      'name': 'Kelas Malam',
      'message': 'Bima : No one can come today?',
      'time': '02:11',
      'unread': 2,
      'image': 'https://i.pravatar.cc/150?img=7',
    },
    {
      'name': 'Jocelyn Gouse',
      'message': "You're now an admin",
      'time': '02:11',
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=8',
    },
    {
      'name': 'Jaylon Dias',
      'message': 'Buy back 10k gallons, top up credit, b...',
      'time': '02:11',
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=9',
    },
    {
      'name': 'Chance Rhiel Madsen',
      'message': 'Thank you mate!',
      'time': '02:11',
      'unread': 1,
      'image': 'https://i.pravatar.cc/150?img=10',
    },
    {
      'name': 'Jaylon Dias',
      'message': 'Hello, how are you?',
      'time': '03:11',
      'unread': 6,
      'image': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Theresa',
      'message': 'Online, please help me find a good monitor for the design',
      'time': '02:28',
      'unread': 3,
      'image': 'https://i.pravatar.cc/150?img=12',
    },
  ];

  ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const CustomText(text: 'Chat App', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Image.asset(
            'assets/images/Search.png',
            height: 30,
          ),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, color: Color.fromARGB(255, 192, 185, 185)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [_buildStoryItem(Icons.add, 'Add story'), ...stories.map((story) => _buildStoryAvatar(story))],
            ),
          ),
          // const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return InkWell(
                  onTap: () {
                    context.router.push(ChatDetailRoute(currentUserId: '122', chatWithUserId: '123'));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(chat['image']),
                    ),
                    title: CustomText(text: chat['name'], fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    subtitle: CustomText(
                      text: chat['message'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: chat['time'],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        ),
                        if (chat['unread'] > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat['unread']}',
                              style: getCustomTextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade300,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 6),
          CustomText(text: label, fontSize: 12, lineHeight: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(Map<String, dynamic> story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(story['image']),
          ),
          const SizedBox(height: 6),
          CustomText(text: story['name'], fontSize: 11, lineHeight: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ],
      ),
    );
  }
}
