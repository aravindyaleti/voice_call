// import 'dart:async';
// import 'dart:core';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_webrtc/media_stream.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class LoopBackSample extends StatefulWidget {
//   static String tag = 'loopback_sample';
//   final String doc;
//   final String uid;
//
//   LoopBackSample(this.doc,this.uid);
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<LoopBackSample> {
//
//   MediaStream _localStream;
//   RTCPeerConnection _peerConnection;
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();
//   bool _inCalling = false;
//   DocumentReference _targetRef;
//   FirebaseUser user;
//   String get sdpSemantics => WebRTC.platformIsMobile? 'plan-b' : 'unified-plan';
//   StreamSubscription fSubs;
//   List ice=[];
//
//
//   @override
//   void initState() {
//     super.initState();
//     firebaseInit();
//     initRenderers();
//   }
//
//   @override
//   void deactivate() {
//     super.deactivate();
//     if (_inCalling) {
//       _hangUp();
//     }
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//   }
//
//   void initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }
//
//   void firebaseInit()async{
//     user =await FirebaseAuth.instance.currentUser();
//     _targetRef=await Firestore.instance.collection('Room').document(widget.doc);
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   void _makeCall() async {
//     print('Dinesh');
//     final mediaConstraints = <String, dynamic>{
//       'audio': true,
//       'video': false
//     };
//
//     var configuration = <String, dynamic>{
//       'iceServers': [
//         {'url': 'stun:stun.l.google.com:19302'},
//       ],
//       'sdpSemantics': sdpSemantics
//     };
//
//     final offerSdpConstraints = <String, dynamic>{
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//     };
//
//     final loopbackConstraints = <String, dynamic>{
//       'mandatory': {},
//       'optional': [
//         {'DtlsSrtpKeyAgreement': false},
//       ],
//     };
//
//     if (_peerConnection != null) return;
//
//     try {
//       _peerConnection = await createPeerConnection(configuration, loopbackConstraints);
//       _peerConnection.onSignalingState = _onSignalingState;
//       _peerConnection.onIceGatheringState = _onIceGatheringState;
//       _peerConnection.onIceConnectionState = _onIceConnectionState;
//       _peerConnection.onIceConnectionState = _onPeerConnectionState;
//       _peerConnection.onIceCandidate = _onCandidate;
//       _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;
//       _localStream = await navigator.getUserMedia(mediaConstraints);
//       _localRenderer.srcObject = _localStream;
//
//       switch (sdpSemantics) {
//         case 'plan-b':
//           _peerConnection.onAddStream = _onAddStream;
//           _peerConnection.onRemoveStream = _onRemoveStream;
//           await _peerConnection.addStream(_localStream);
//           break;
//         case 'unified-plan':
//           _peerConnection.onAddStream = _onTrack;
//           _peerConnection.onAddTrack = _onAddTrack;
//           _peerConnection.onRemoveTrack = _onRemoveTrack;
//           break;
//       }
//       var description = await _peerConnection.createOffer(offerSdpConstraints);
//       await _peerConnection.setLocalDescription(description);
//       await _targetRef.setData({
//         "target": widget.uid,
//         "caller": user.uid,
//         "active": true,
//         "offer": (await _peerConnection.getLocalDescription()).toMap()
//       });
//
//       fSubs=_targetRef.snapshots().listen((event)async{
//         if(event.exists) {
//           if (event['active']) {
//             print('Dinesh Reddy');
//           }
//           if (event['answer'] != null) {
//             RTCSessionDescription _answer = RTCSessionDescription(
//                 event['answer']['sdp'], event['answer']['type']);
//             await _peerConnection.setRemoteDescription(_answer);
//             await _targetRef.setData({"caller_candidate": ice}, merge: true);
//           }
//           if (event['receiver_candidate'] != null) {
//             List cds = List.of(event['receiver_candidate'] ?? []);
//             for (Map cd in cds) {
//               RTCIceCandidate candid = RTCIceCandidate(
//                   cd['candidate'], cd['sdpMid'], cd['spdMineIndex']);
//               await _peerConnection.addCandidate(candid);
//             }
//           }
//         }
//         else {
//           Navigator.popUntil(context, (route) => route.isFirst);
//         }
//       });
//       //change for loopback.
//       description.type = 'answer';
//       await _peerConnection.setRemoteDescription(description);
//     } catch (e) {
//       print(e.toString());
//     }
//     if (!mounted) return;
//
//     setState(() {
//       _inCalling = true;
//     });
//   }
//
//
//   void _onSignalingState(RTCSignalingState state) {
//     print(state);
//   }
//
//   void _onIceGatheringState(RTCIceGatheringState state) {
//     print(state);
//   }
//
//   void _onIceConnectionState(RTCIceConnectionState state) {
//     if(state==RTCIceConnectionState.RTCIceConnectionStateCompleted){
//
//     }
//   }
//
//   void _onPeerConnectionState(state) {
//     print(state);
//   }
//
//   void _onAddStream(MediaStream stream) {
//     _remoteRenderer.srcObject = stream;
//   }
//
//   void _onRemoveStream(MediaStream stream) {
//     _remoteRenderer.srcObject = null;
//   }
//
//   void _onCandidate(RTCIceCandidate candidate) {
//     print('onCandidate: ${candidate.candidate}');
//     ice.add(candidate);
//     _peerConnection.addCandidate(candidate);
//   }
//
//   void _onTrack(event) {
//     print('onTrack');
//     if (event.track.kind == 'video') {
//       _remoteRenderer.srcObject = event.streams[0];
//     }
//   }
//
//   void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
//     if (track.kind == 'video') {
//       _remoteRenderer.srcObject = stream;
//     }
//   }
//
//   void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
//     if (track.kind == 'video') {
//       _remoteRenderer.srcObject = null;
//     }
//   }
//
//   void _onRenegotiationNeeded() {
//     print('RenegotiationNeeded');
//   }
//
//
//   void _hangUp() async {
//     try {
//       await _localStream?.dispose();
//       await _peerConnection?.close();
//       _peerConnection = null;
//       _localRenderer.srcObject = null;
//       _remoteRenderer.srcObject = null;
//     } catch (e) {
//       print(e.toString());
//     }
//     setState(() {
//       _inCalling = false;
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     var widgets = <Widget>[
//       Expanded(
//         child: Container(),
//         // child: RTCVideoView(_localRenderer,),
//       ),
//       Expanded(
//         child: Container(),
//         // child: RTCVideoView(_remoteRenderer),
//       )
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('LoopBack example'),
//         actions: _inCalling
//             ? <Widget>[
//           IconButton(
//             icon: Icon(Icons.keyboard),
//             onPressed: (){
//
//             },
//           ),
//         ]
//             : null,
//       ),
//       body: OrientationBuilder(
//         builder: (context, orientation) {
//           return Center(
//             child: Container(
//               decoration: BoxDecoration(color: Colors.black54),
//               child: orientation == Orientation.portrait
//                   ? Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: widgets)
//                   : Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: widgets),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _inCalling ? _hangUp : _makeCall,
//         tooltip: _inCalling ? 'Hangup' : 'Call',
//         child: Icon(_inCalling ? Icons.call_end : Icons.phone),
//       ),
//     );
//   }
// }