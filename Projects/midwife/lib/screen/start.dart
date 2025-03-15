import 'package:flutter/material.dart';
import 'package:midwife/screen/login.dart';
import 'package:midwife/screen/registration.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midwife'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (contect) => Register()));
              },
              child: const Text('Registration'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (contect) => MidwifeLogin()));
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}