// Future<void> _createOffer(Session session, String media) async {
//   try {
//     RTCSessionDescription s = await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
//     await session.pc!.setLocalDescription(_fixSdp(s));
//     _send('offer', {
//       'to': session.pid,
//       'from': _selfId,
//       'description': {'sdp': s.sdp, 'type': s.type},
//       'session_id': session.sid,
//       'media': media,
//     });
//   } catch (e) {
//     print(e.toString());
//   }
// }
// void onMessage(message) async {
//   Map<String, dynamic> mapData = message;
//   var data = mapData['data'];

//   switch (mapData['type']) {
//     case 'peers':
//       {
//         List<dynamic> peers = data;
//         if (onPeersUpdate != null) {
//           Map<String, dynamic> event = <String, dynamic>{};
//           event['self'] = _selfId;
//           event['peers'] = peers;
//           onPeersUpdate?.call(event);
//         }
//       }
//       break;
//     case 'offer':
//       {
//         var peerId = data['from'];
//         var description = data['description'];
//         var media = data['media'];
//         var sessionId = data['session_id'];
//         var session = _sessions[sessionId];
//         var newSession = await _createSession(session, peerId: peerId, sessionId: sessionId, media: media, screenSharing: false);
//         _sessions[sessionId] = newSession;
//         await newSession.pc?.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));

//         if (newSession.remoteCandidates.isNotEmpty) {
//           newSession.remoteCandidates.forEach((candidate) async {
//             await newSession.pc?.addCandidate(candidate);
//           });
//           newSession.remoteCandidates.clear();
//         }
//         onCallStateChange?.call(newSession, CallState.callStateNew);
//         onCallStateChange?.call(newSession, CallState.callStateRinging);
//       }
//       break;
//     case 'answer':
//       {
//         var description = data['description'];
//         var sessionId = data['session_id'];
//         var session = _sessions[sessionId];
//         session?.pc?.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
//         onCallStateChange?.call(session!, CallState.callStateConnected);
//       }
//       break;
//     case 'candidate':
//       {
//         var peerId = data['from'];
//         var candidateMap = data['candidate'];
//         var sessionId = data['session_id'];
//         var session = _sessions[sessionId];
//         RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

//         if (session != null) {
//           if (session.pc != null) {
//             await session.pc?.addCandidate(candidate);
//           } else {
//             session.remoteCandidates.add(candidate);
//           }
//         } else {
//           _sessions[sessionId] = Session(pid: peerId, sid: sessionId)..remoteCandidates.add(candidate);
//         }
//       }
//       break;
//     case 'leave':
//       {
//         var peerId = data as String;
//         _closeSessionByPeerId(peerId);
//       }
//       break;
//     case 'bye':
//       {
//         var sessionId = data['session_id'];
//         print('bye: ' + sessionId);
//         var session = _sessions.remove(sessionId);
//         if (session != null) {
//           onCallStateChange?.call(session, CallState.callStateBye);
//           _closeSession(session);
//         }
//       }
//       break;
//     case 'keepalive':
//       {
//         print('keepalive response!');
//       }
//       break;
//     default:
//       break;
//   }
// }


// void switchCamera() {
//   if (_localStream != null) {
//     Helper.switchCamera(_localStream!.getVideoTracks()[0]);
//   }
// }

// void muteMic() {
//   if (_localStream != null) {
//     bool enabled = _localStream!.getAudioTracks()[0].enabled;
//     _localStream!.getAudioTracks()[0].enabled = !enabled;
//   }
// }
// static Future<void> selectAudioOutput(String deviceId) async {
//     await navigator.mediaDevices
//         .selectAudioOutput(AudioOutputOptions(deviceId: deviceId));
//   }

// static Future<void> selectAudioInput(String deviceId) =>
//       NativeAudioManagement.selectAudioInput(deviceId);

// static Future<void> setSpeakerphoneOn(bool enable) =>
//       NativeAudioManagement.setSpeakerphoneOn(enable);