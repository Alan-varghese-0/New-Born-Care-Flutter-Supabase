import 'package:doctor/screen/login.dart';
import 'package:doctor/screen/registration.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.cyanAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorLoginPage()));
                },
                child: const Text('Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorRegistrationPage()));
                },
                child: const Text('Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}