import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seller/components/form_validation.dart';
import 'package:seller/screen/home.dart';
import 'package:seller/screen/register.dart';
import 'package:seller/screen/start.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  void signIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text,
        password: _pass.text,
      );
      if (res.user != null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(),), (route) => false);
      }
    } catch (e) {
      print(" error$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Start())),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text("Login", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Welcome Back!", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _email,
                  validator: (value) => FormValidation.validateEmail(value),
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.mail),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _pass,
                  validator: (value) => FormValidation.validatePassword(value),
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Register())),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
