import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
  bool _isMicMuted = true;
  bool isCameraOff = false;
  bool _isLocalVideoOff = false;
  bool _isRemoteStreamConnected = false;
  Offset _remoteRendererPosition = const Offset(0, 0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: SafeArea(
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
                    child: RTCVideoView(_localRenderer, mirror: true),
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
                top: 20,
                right: 20,
                child: Text(
                  _isRemoteStreamConnected ? 'Connected' : 'Connecting....',
                  style: TextStyle(color: _isLocalVideoOff ? Colors.white : Colors.black),
                )),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
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

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
