import 'package:flutter/material.dart';
import 'package:seller/screen/start.dart';




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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Start(),
    );
  }
}
