import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/components/form_validation.dart';
import 'package:user/main.dart';
import 'package:user/screens/home.dart';
import 'package:user/screens/signin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  void signIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String email = _email.text.trim();
      String password = _pass.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
      print("Sign in successful");
    } catch (e) {
      if (e is AuthException) {
        print("Error during sign in: $e");
        if (e.code == "invalid_credentials") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Email or password incorrect",
                style: GoogleFonts.nunito(color: Colors.white),
              ),
              backgroundColor: Colors.pink.shade300, // Match theme
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        print("Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "An unexpected error occurred",
              style: GoogleFonts.nunito(color: Colors.white),
            ),
            backgroundColor: Colors.pink.shade300, // Match theme
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade200, Colors.purple.shade200], // Match Forum gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    "Welcome Back!",
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800, // Match theme
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Log in to stay connected with your midwife",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[600], // Match Forum subtitle
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Match Forum text field
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _email,
                      validator: (value) => FormValidation.validateEmail(value),
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.mail, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Match Forum text field
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _pass,
                      validator: (value) => FormValidation.validatePassword(value),
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.lock, color: Colors.purple.shade600), // Match theme
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.purple.shade600, // Match theme
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300, // Match Forum button
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Match Forum button shape
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 2, // Match Forum button elevation
                    ),
                    child: Text(
                      "Log In",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600], // Match Forum subtitle
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUp()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600, // Match theme
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}