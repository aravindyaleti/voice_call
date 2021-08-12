import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voice_call/home.dart';


class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mail=new TextEditingController();
  TextEditingController pass=new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey,backgroundColor: Colors.black,body: Container(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center,children: [
        Padding(
          padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05,top: MediaQuery.of(context).size.height*0.07,bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 32,color: Colors.white),),
              SizedBox(height: 10,),
              Text('Login to continue',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
            ],
          ),
        ),
        SizedBox(height: 30,),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 18),
          child: Container(padding: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color:Colors.grey)),
            child: TextField(
              showCursor: true,controller: mail,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.mail_outline),
                hintStyle: TextStyle(color: Colors.grey,),
                hintText: "Email",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 18),
          child: Container(padding: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color:Colors.grey)),
            child: TextField(
              showCursor: true,controller: pass,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock),
                hintStyle: TextStyle(color: Colors.grey,),
                hintText: "Password",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),

        SizedBox(height: 60,),
        Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05,right: MediaQuery.of(context).size.width*0.05),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              gradient: new LinearGradient(
                  colors: [Colors.amber.shade600,Colors.yellow,Colors.amber.shade600],
                  begin: FractionalOffset(0.2, 0.2),
                  end: FractionalOffset(1.0, 1.0),
                  tileMode: TileMode.clamp),
            ),
            child: MaterialButton(
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                  child: Text("Login", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ),
                onPressed: () {
                  _signIn();
                }
            ),
          ),
        ),
      ],),
    ),
    );
  }


  Future _signIn()async{
    FirebaseAuth auth =FirebaseAuth.instance;
    FirebaseUser user;
    showDialog(context: context,builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }, barrierDismissible: false);
    try{
     user= await auth.signInWithEmailAndPassword(email: mail.text, password: pass.text).then((value) => value.user);
     if(user!=null){
       Navigator.pop(context);
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>MyHome()));
     }else{
       _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong! Please try it again')));
       Navigator.pop(context);
     }
    }catch(e){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('${e.message}')));
      Navigator.pop(context);
    }
  }
}
