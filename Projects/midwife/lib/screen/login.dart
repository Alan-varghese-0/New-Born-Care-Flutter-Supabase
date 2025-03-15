import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/components/form_validation.dart';
import 'package:midwife/screen/dashboard.dart';
import 'package:midwife/screen/registration.dart';
import 'package:midwife/screen/start.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MidwifeLogin extends StatefulWidget {
  const MidwifeLogin({super.key});

  @override
  State<MidwifeLogin> createState() => _MidwifeLoginState();
}

class _MidwifeLoginState extends State<MidwifeLogin> {
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => home()),
          (route) => false,
        );
      }
    } catch (e) {
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
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Start()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Midwife Login",
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
      ),
      body: Center(
        child: Container(
          width: 380,
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
                Text(
                  "Caring for Mothers, One Step at a Time",
                  style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                  textAlign: TextAlign.center,
                ),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  Register()),
                  ),
                  child: const Text("New midwife? Register here."),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
