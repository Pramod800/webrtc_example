import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late MediaStream _localStream;

  Function(RTCSessionDescription)? onLocalDescription;
  Function(RTCIceCandidate)? onIceCandidate;

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"}
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        onIceCandidate?.call(candidate);
      }
    };
  }

  Future<void> startLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream.getTracks()) {
      _peerConnection!.addTrack(track, _localStream);
    }
  }

  Future<void> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    onLocalDescription?.call(offer);
  }

  Future<void> createAnswer(String remoteSdp) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(remoteSdp, 'offer'),
    );

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    onLocalDescription?.call(answer);
  }

  Future<void> handleAnswer(String sdp) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
  }

  Future<void> addIceCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  void dispose() {
    _localStream.getTracks().forEach((t) => t.stop());
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
  }
}
