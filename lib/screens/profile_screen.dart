import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
import 'package:mqtt_webrtc_example/core/componsnts/custom_textstyle.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, dynamic> profileData = {
    'name': 'Pramod Timilsina',
    'status': 'Online',
    'bio': 'Mobile developer & coffee enthusiast. Building cool apps for fun!',
    'phone': '9845345378',
    'email': 'pramod@gmail.com',
    'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    'lastSeen': 'Today, 10:30 AM',
    'joinedDate': 'January 2025',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoCard(),
            // _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(profileData['avatar']),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 16),
        CustomText(
          text: profileData['name'],
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        const SizedBox(height: 4),
        CustomText(
          text: profileData['status'],
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomText(
              text: profileData['bio'],
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Phone', profileData['phone']),
            _buildInfoRow('Email', profileData['email']),
            _buildInfoRow('Last Seen', profileData['lastSeen']),
            _buildInfoRow('Joined', profileData['joinedDate']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Colors.blue),
              ),
              onPressed: () {},
              child: const Text(
                'Share Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Example of adding icons to info rows
}
