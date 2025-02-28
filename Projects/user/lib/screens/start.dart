import 'package:flutter/material.dart';
import 'package:user/screens/login.dart';
import 'package:user/screens/signup.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
       return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
          // image: DecorationImage(image: AssetImage("assets/snow.jpeg"),fit: BoxFit.fill),
            color:Color(0xFFE3F2F1)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
              }, child: Text(' login ',style: TextStyle(fontSize: 30),)),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp(),));
              },
               child: Text('sign up',style: TextStyle(fontSize: 30),)),
               
            ],
          ),
        )
     );
   }
}