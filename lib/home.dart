import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voice_call/calling_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voice_call/receive_screen.dart';
import 'RTCVideoPlayer.dart';


class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription stream;
  bool active=false;


  @override
  void dispose() {
    // TODO: implement dispose
    active=false;
    super.dispose();
  }

  Future _get()async{
    FirebaseUser user= await FirebaseAuth.instance.currentUser();
    CollectionReference reference=Firestore.instance.collection('Room');
    stream= reference.where('target',isEqualTo: user.uid).where('active',isEqualTo: true).snapshots().listen((event) {
      if(event.documents.isNotEmpty&&!active){
        active =true;
        setState(() {

        });
        showDialog(context: context,builder:(ctx)=>AlertDialog(
          title: Text("You have a call"),
          actions: [
            FlatButton(
              onPressed: () async{
                event.documents.first.reference.setData({
                  "target_accept":true
                },merge: true);
                Navigator.pop(ctx);
                await Navigator.push(context, MaterialPageRoute(builder: (context)=>Receiver(event.documents.first)));
              },
              child: Text("ACCEPT"),
            ),
            FlatButton(
              onPressed: (){
                event.documents.first.reference.delete();
                Navigator.pop(ctx);
              },
              child: Text("REJECT"),
            ),
          ],
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey,backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned(top: 0,
          child: Container(width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('User').where('uid',isGreaterThanOrEqualTo: '').snapshots(),
            builder: (context, snapshot) {
              _get();
              return ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text('${snapshot.data.documents[index].data['name']}',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                  subtitle: Text('Project Manager',style: TextStyle(color: Colors.grey,),),
                  trailing: CircleAvatar(backgroundColor: Colors.amber.shade700,
                    child: IconButton(icon: Icon(Icons.call,color: Colors.white,),
                        onPressed: (){

                        }),
                  ),
                  onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Calling(DateTime.now().millisecondsSinceEpoch.toString(),
                      snapshot.data.documents[index].data['uid'])));
                  },
                );
              },);
            }
          ),),
        ),
        Positioned(top:MediaQuery.of(context).size.width,
        child: Container(color: Colors.black,
          child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: MediaQuery.of(context).size.width,
              child: GridView.count(crossAxisCount: 3,shrinkWrap: true,padding: EdgeInsets.all(10),
              mainAxisSpacing: 10,crossAxisSpacing: 10,childAspectRatio: 1.5,
              children: ['1','2','3','4','5','6','7','8','9','*','0','#'].map((e) =>
                  CircleAvatar(backgroundColor: Colors.grey.shade900,radius: 30,
                    child: IconButton(icon: Text('$e',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                  onPressed: (){

                  }),
              )).toList(),),
            ),
            Container(width: MediaQuery.of(context).size.width,
              child: Row(mainAxisSize: MainAxisSize.min,children: [
                Expanded(flex: 3,child: Container()),

                Expanded(flex: 3,child: CircleAvatar(backgroundColor: Colors.amber.shade700,radius: 33,
                  child: IconButton(icon: Icon(Icons.call,color: Colors.white,),
                      onPressed: (){

                      }),
                )),
                Expanded(flex: 3,child: IconButton(icon: Icon(Icons.backspace_outlined,color: Colors.white,),
                    onPressed: (){

                    }),),

              ],),
            )
          ],),
        ),),
      ],),
    );
  }
}
