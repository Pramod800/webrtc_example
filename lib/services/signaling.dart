import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Signaling {
  final _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  late IO.Socket _socket;

  Function(MediaStream stream)? onRemoteStream;
  final String roomId;

  Signaling({required this.roomId});

  Future<void> connect() async {
    _socket = IO.io('http://192.168.1.75:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.onConnect((_) async {
      print('Connected to signaling server');
      _socket.emit('join', roomId);
    });

    _socket.on('user-joined', (_) {
      _createOffer();
    });

    _socket.on('offer', (data) async {
      await _createAnswer(data['sdp']);
    });

    _socket.on('answer', (data) async {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(data['sdp'], 'answer'),
      );
    });

    _socket.on('ice-candidate', (data) async {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await _peerConnection.addCandidate(candidate);
    });

    await _initLocalStream();
    await _createPeerConnection();
  }

  Future<void> _initLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);
    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });

    _peerConnection.onIceCandidate = (candidate) {
      _socket.emit('ice-candidate', {
        'roomId': roomId,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection.onAddStream = (stream) {
      onRemoteStream?.call(stream);
    };
  }

  Future<void> _createOffer() async {
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    _socket.emit('offer', {'roomId': roomId, 'sdp': offer.sdp});
  }

  Future<void> _createAnswer(String sdp) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );
    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);
    _socket.emit('answer', {'roomId': roomId, 'sdp': answer.sdp});
  }

  MediaStream getLocalStream() => _localStream;

  void dispose() {
    _localStream.dispose();
    _peerConnection.close();
    _socket.dispose();
  }
}
