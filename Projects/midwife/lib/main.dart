import 'package:flutter/material.dart';
import 'package:midwife/screen/dashboard.dart';
import 'package:midwife/screen/login.dart';


import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://jvxojwcrownupffdoneo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2eG9qd2Nyb3dudXBmZmRvbmVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxNzY0NTYsImV4cCI6MjA1Mjc1MjQ1Nn0.Xz28NAERRm6goI-rgWuMzbVwOXEIiIB4MPpqQ9j7Z_g',
  );
  runApp(const MainApp());
}
        
final supabase = Supabase.instance.client;


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: AuthWrapper(),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final session = supabase.auth.currentSession;

    if (session != null) {
      // User is logged in, navigate to HomePage
      return HomeScreen();
    } else {
      // User is not logged in, navigate to LandingPage
      return MidwifeLogin();
    }
  }
}