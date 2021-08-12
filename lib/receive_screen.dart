import 'dart:async';
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/media_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';import 'package:flutter/material.dart';


class Receiver extends StatefulWidget {

  final DocumentSnapshot doc;

  Receiver(this.doc);

  @override
  _ReceiverState createState() => _ReceiverState();
}

class _ReceiverState extends State<Receiver> {

  MediaStream _localStream;
  RTCPeerConnection _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  DocumentReference callRef;
  FirebaseUser user;
  String get sdpSemantics => WebRTC.platformIsMobile? 'plan-b' : 'unified-plan';
  StreamSubscription fSubs;
  List ice=[];


  @override
  void initState() {
    super.initState();
    firebaseInit();
    initRenderers();
    _makeCall();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    callRef.delete();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void firebaseInit()async{
    user =await FirebaseAuth.instance.currentUser();
    callRef= Firestore.instance.document("Room/${widget.doc.documentID}");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': false
    };

    var configuration = <String, dynamic>{
      'iceServers': [
        {
          'urls': 'turn:numb.viagenie.ca',
          'credential': '123456',
          'username': 'lokesh.verma25n@gmail.com'
        },
        {'url': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun.l.test.com:19000'},
        {'urls': 'stun:stun.services.mozilla.com'},
        {'url': 'stun:stun1.l.google.com:19302'},
        {'url': 'stun:stun2.l.google.com:19302'},
        {'urls': 'stun:stun.2.google.com:19302'},
        {'url': 'stun:stun3.l.google.com:19302'},
        {'url': 'stun:stun4.l.google.com:19302'},
        {'url': 'stun:stunserver.org'},
        {'url': 'stun:stun.softjoys.com'},
        {'url': 'stun:stun.voiparound.com'},
        {'url': 'stun:stun.voipbuster.com'},
      ],
    };

    final answerSdpConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    final loopbackConstraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': false},
      ],
    };

    if (_peerConnection != null) return;

    try {
      _peerConnection = await createPeerConnection(configuration, loopbackConstraints);
      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onIceConnectionState = _onPeerConnectionState;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;
      _localStream = await navigator.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;


      switch (sdpSemantics) {
        case 'plan-b':
          _peerConnection.onAddStream = _onAddStream;
          _peerConnection.onRemoveStream = _onRemoveStream;
          await _peerConnection.addStream(_localStream);
          break;
        case 'unified-plan':
          _peerConnection.onAddStream = _onTrack;
          _peerConnection.onAddTrack = _onAddTrack;
          _peerConnection.onRemoveTrack = _onRemoveTrack;
          break;
      }
      RTCSessionDescription description = RTCSessionDescription(
          widget.doc['offer']['sdp'], widget.doc['offer']['type']);
      await _peerConnection.setRemoteDescription(description);
      await _peerConnection.addStream(_localStream);
      final answer = await _peerConnection.createAnswer(answerSdpConstraints);
      await _peerConnection.setLocalDescription(answer);
      await callRef.setData(
          {"answer": (await _peerConnection.getLocalDescription()).toMap()},
          merge: true);
      await callRef.setData({"receiver_candidate":ice.map((e) => e.toMap()).toList()},merge: true);
      fSubs=callRef.snapshots().listen((event)async{
        if(event.exists) {
          if (event['active']) {
            print('Dinesh Reddy');
          }
          if (event['caller_candidate'] != null) {
            List cds = List.of(event['caller_candidate'] ?? []);
            for (Map cd in cds) {
              RTCIceCandidate candid = RTCIceCandidate(
                  cd['candidate'], cd['spdMineIndex'].toString(), cd['spdMineIndex']);
              try{
                await _peerConnection.addCandidate(candid);
              }catch(e){
                print(e.toString());
              }
            }
          }
        }
        else {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    } catch (e) {
      print("DINuUUU BUG"+e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }


  void _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    if(state==RTCIceConnectionState.RTCIceConnectionStateCompleted){

    }
  }

  void _onPeerConnectionState(state) {
    print(state);
  }

  void _onAddStream(MediaStream stream) {
    _remoteRenderer.srcObject = stream;
  }

  void _onRemoveStream(MediaStream stream) {
    _remoteRenderer.srcObject = null;
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ${candidate.candidate}');
    ice.add(candidate);
    _peerConnection.addCandidate(candidate);
  }

  void _onTrack(event) {
    print('onTrack');
    if (event.track.kind == 'video') {
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    if (track.kind == 'video') {
      _remoteRenderer.srcObject = stream;
    }
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    if (track.kind == 'video') {
      _remoteRenderer.srcObject = null;
    }
  }

  void _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }


  void _hangUp() async {
    try {
      await _localStream?.dispose();
      await _peerConnection?.close();
      _peerConnection = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      callRef.delete();
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      Expanded(
        child: Container(),
        // child: RTCVideoView(_localRenderer,),
      ),
      Expanded(
        child: Container(),
        // child: RTCVideoView(_remoteRenderer),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('LoopBack example'),
        actions: _inCalling
            ? <Widget>[
          IconButton(
            icon: Icon(Icons.keyboard),
            onPressed: (){

            },
          ),
        ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.black54),
              child: orientation == Orientation.portrait
                  ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widgets)
                  : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widgets),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
