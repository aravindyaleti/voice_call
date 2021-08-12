//
//
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
//
// class Streams{
//
//   static
//
//   static _get()async{
//     StreamSubscription stream;
//     FirebaseUser user= await FirebaseAuth.instance.currentUser();
//     CollectionReference reference=Firestore.instance.collection('Room');
//     stream= reference.where('target',isEqualTo: user.uid).where('active',isEqualTo: true).snapshots().listen((event) {
//       if(event.documents.isNotEmpty&&!active){
//         active =true;
//
//       }
//     });
//
//   }
//
// }