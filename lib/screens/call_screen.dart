import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt_webrtc_example/services/signaling.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  const VideoCallScreen({super.key, required this.roomId});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late Signaling _signaling;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isLocalVideoOff = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _startSignaling();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startSignaling() async {
    _signaling = Signaling(roomId: widget.roomId);
    await _signaling.connect();

    setState(() {
      _localRenderer.srcObject = _signaling.getLocalStream();
    });

    _signaling.onRemoteStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };
  }

  void _toggleMic() {
    final audioTrack = _localRenderer.srcObject?.getAudioTracks().firstWhere((track) => track.kind == 'audio');
    if (audioTrack != null) {
      setState(() {
        _isMicMuted = !_isMicMuted;
        audioTrack.enabled = !_isMicMuted;
      });
    }
  }

  void _toggleCamera() {
    final videoTrack = _localRenderer.srcObject?.getVideoTracks().firstWhere((track) => track.kind == 'video');
    if (videoTrack != null) {
      Helper.switchCamera(videoTrack);
    }
  }

  void _toggleLocalVideo() {
    final videoTrack = _localRenderer.srcObject?.getVideoTracks().firstWhere((track) => track.kind == 'video');
    if (videoTrack != null) {
      setState(() {
        _isLocalVideoOff = !_isLocalVideoOff;
        videoTrack.enabled = !_isLocalVideoOff;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
            if (_remoteRenderer.srcObject != null)
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  height: 180,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RTCVideoView(_remoteRenderer),
                ),
              ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMicMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleMic,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.switch_camera,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleCamera,
                  ),
                  IconButton(
                    icon: Icon(
                      _isLocalVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleLocalVideo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    _remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.dispose();
    super.dispose();
  }
}
