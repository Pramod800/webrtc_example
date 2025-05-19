// // lib/services/webrtc_service.dart
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// class WebRTCService {
// RTCPeerConnection? _peerConnection;
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//   // Add public getters
//   RTCVideoRenderer get localRenderer => _localRenderer;
//   RTCVideoRenderer get remoteRenderer => _remoteRenderer;

//   Future<void> init() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//     _peerConnection = await createPeerConnection({
//       "iceServers": [
//         {"urls": "stun:stun.l.google.com:19302"}
//       ]
//     });
//     _peerConnection!.onTrack = (event) {
//       _remoteRenderer.srcObject = event.streams[0];
//     };
//   }

//   Future<void> startCall() async {
//     final stream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': {'facingMode': 'user'}
//     });
//     _localRenderer.srcObject = stream;
//     _peerConnection!.addStream(stream);
//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);
//     // Send offer via Socket.io
//   }
// }
