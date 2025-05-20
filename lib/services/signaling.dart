// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

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
    await _initLocalStream();
    await _createPeerConnection();

    _socket = IO.io('http://192.168.1.75:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.onConnect((_) async {
      log('Connected to signaling server');
      _socket.emit('join', roomId);
    });

    _socket.on('user-joined', (_) {
      _createOffer();
    });

    _socket.on('offer', (data) async {
      try {
        final sdp = data['sdp'];
        if (sdp == null || sdp.isEmpty) {
          log('Received null or empty SDP in offer');
          return;
        }
        await _createAnswer(sdp);
      } catch (e) {
        log('Error handling offer: $e');
      }
    });

    _socket.on('answer', (data) async {
      try {
        if (_peerConnection == null) {
          log('PeerConnection is not initialized');
          return;
        }
        final sdp = data['sdp'];
        if (sdp == null || sdp.isEmpty) {
          log('Received null or empty SDP in answer');
          return;
        }
        await _peerConnection.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer'),
        );
        log('Remote description set from answer');
      } catch (e) {
        log('Error handling answer: $e');
      }
    });

    _socket.on('ice-candidate', (data) async {
      try {
        if (_peerConnection == null) {
          log('PeerConnection is not initialized');
          return;
        }
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        await _peerConnection.addCandidate(candidate);
      } catch (e) {
        log('Error handling ICE candidate: $e');
      }
    });
  }

  Future<void> _initLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });
      log('Local stream initialized');
    } catch (e) {
      log('Error initializing local stream: $e');
    }
  }

  Future<void> _createPeerConnection() async {
    try {
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
        log('Remote stream received: ${stream.id}');
        onRemoteStream?.call(stream);
      };
    } catch (e) {
      log('Error creating peer connection: $e');
    }
  }

  Future<void> _createOffer() async {
    try {
      final offer = await _peerConnection.createOffer();

      await _peerConnection.setLocalDescription(offer);
      _socket.emit('offer', {
        'roomId': roomId,
        'sdp': offer.sdp,
      });
      log('Local description set successfully');
    } catch (e) {
      log('Error setting local description: $e');
    }
  }

  Future<void> _createAnswer(String? sdp) async {
    try {
      if (sdp == null || sdp.isEmpty) {
        log('Error: Received null or empty SDP in offer');
        return;
      }

      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(sdp, 'offer'),
      );

      final answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);

      _socket.emit('answer', {
        'roomId': roomId,
        'sdp': answer.sdp,
      });
      log('Answer created and emitted');
    } catch (e) {
      log('Error creating answer: $e');
    }
  }

  MediaStream getLocalStream() => _localStream;

  void dispose() {
    _localStream.getTracks().forEach((track) => track.stop());
    _localStream.dispose();
    _peerConnection.close();
    _socket.dispose();
  }
}
