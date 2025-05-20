import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt_webrtc_example/services/web_socket.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CallScreen extends StatefulWidget {
  final String roomId;

  const CallScreen({super.key, required this.roomId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final WebRTCService _rtcService = WebRTCService();
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    await _rtcService.init();
    await _rtcService.startLocalStream();

    _rtcService.onLocalDescription = (sdp) {
      if (sdp.type != null && sdp.sdp != null) {
        _socket.emit(sdp.type!, {'roomId': widget.roomId, 'sdp': sdp.sdp});
      } else {
        print('Warning: SDP or type is null');
      }
    };

    _rtcService.onIceCandidate = (candidate) {
      _socket.emit('ice-candidate', {
        'roomId': widget.roomId,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _socket = IO.io('http://192.168.1.75:3000', <String, dynamic>{
      'transports': ['websocket']
    });

    _socket.onConnect((_) {
      print('Connected to signaling server');
      _socket.emit('join', widget.roomId);
    });

    _socket.on('user-joined', (_) {
      _rtcService.createOffer();
    });

    _socket.on('offer', (data) {
      _rtcService.createAnswer(data['sdp']);
    });

    _socket.on('answer', (data) {
      _rtcService.handleAnswer(data['sdp']);
    });

    _socket.on('ice-candidate', (data) {
      _rtcService.addIceCandidate(data);
    });
  }

  @override
  void dispose() {
    _rtcService.dispose();
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Stack(
        children: [
          RTCVideoView(_rtcService.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
          Positioned(
            top: 20,
            right: 20,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RTCVideoView(_rtcService.localRenderer, mirror: true),
            ),
          ),
        ],
      ),
    );
  }
}
