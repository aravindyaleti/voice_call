import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voice_call/home.dart';
import 'package:voice_call/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
    );
  }
}


class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  Future _get()async{
    FirebaseAuth auth=FirebaseAuth.instance;
    FirebaseUser user=await auth.currentUser();
    if(user!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>MyHome()));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>LogIn()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _get();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      body: Column(mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Text('Connect...',style: TextStyle(color: Colors.white,fontSize: 24),),
        Padding(padding: EdgeInsets.only(top: 12,left: MediaQuery.of(context).size.width*0.2,right: MediaQuery.of(context).size.width*0.2),
            child: LinearProgressIndicator()
        ),
    ],),
    );
  }
}

