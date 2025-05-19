// lib/screens/call_screen.dart
import 'package:flutter/material.dart';
import 'package:mqtt_webrtc_example/services/signaling.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  const VideoCallScreen({required this.roomId});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late MediaStream _localStream;
  late Signaling _signaling;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    startCall();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    setState(() {
      _localRenderer.srcObject = stream;
    });

    _localStream = stream;
  }

  void toggleCamnera() async {
    if (_localStream.getVideoTracks().isNotEmpty) {
      final videoTrack = _localStream.getVideoTracks()[0];
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  Future<void> startCall() async {
    _signaling = Signaling(roomId: widget.roomId);
    await _signaling.connect();
    _localRenderer.srcObject = _signaling.getLocalStream();
    _signaling.onRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: SafeArea(
        child: Stack(
          children: [
            InkWell(
                onTap: () {
                  toggleCamnera();
                },
                child: SizedBox(height: MediaQuery.of(context).size.height, child: RTCVideoView(_localRenderer, mirror: true))),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 180,
                  width: 120,
                  child: RTCVideoView(_remoteRenderer)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.dispose();
    super.dispose();
  }
}
