import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
import 'package:mqtt_webrtc_example/screens/chat_detailpage.dart';
import 'package:mqtt_webrtc_example/services/signaling.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  const VideoCallScreen({super.key, required this.roomId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late Signaling _signaling;
  bool _isMicMuted = false;
  bool isCameraOff = false;
  bool _isLocalVideoOff = false;
  bool _isRemoteStreamConnected = false;
  Offset _remoteRendererPosition = const Offset(220, 90);

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
        _isRemoteStreamConnected = true;
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

  void _hangUp() {
    _localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    _remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            _isLocalVideoOff
                ? Container(
                    color: Colors.black,
                    height: double.infinity,
                    width: double.infinity,
                    child: const Center(
                      child: Text(
                        "Video is off",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                : SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                  ),
            Positioned(
              left: 30,
              top: 50,
              child: Container(color: Colors.transparent, child: const AppBarUserInfo()),
            ),
            Positioned(
              left: _remoteRendererPosition.dx,
              top: _remoteRendererPosition.dy,
              child: Draggable(
                feedback: RemoteView(remoteRenderer: _remoteRenderer),
                childWhenDragging: const SizedBox.shrink(),
                onDragEnd: (details) {
                  setState(() {
                    _remoteRendererPosition = details.offset;
                  });
                },
                child: RemoteView(remoteRenderer: _remoteRenderer),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isMicMuted ? Icons.mic_off : Icons.mic,
                        color: AppColors.white,
                      ),
                      onPressed: _toggleMic,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.switch_camera,
                        color: AppColors.white,
                      ),
                      onPressed: _toggleCamera,
                    ),
                    IconButton(
                      icon: Icon(
                        _isLocalVideoOff ? Icons.videocam_off : Icons.videocam,
                        color: AppColors.white,
                      ),
                      onPressed: _toggleLocalVideo,
                    ),
                    InkWell(
                      onTap: () {
                        _hangUp();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                    ),
                  ],
                ),
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

class RemoteView extends StatelessWidget {
  const RemoteView({
    super.key,
    required RTCVideoRenderer remoteRenderer,
  }) : _remoteRenderer = remoteRenderer;

  final RTCVideoRenderer _remoteRenderer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.yellowAccent, Colors.greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        placeholderBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
