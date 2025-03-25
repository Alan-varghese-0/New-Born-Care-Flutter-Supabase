import 'package:admin/screens/dashboard.dart';
import 'package:admin/main.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = false;

  Future<void> signIn() async {
    try {
      setState(() {
        isLoading = true;
      });
      String email = _email.text.trim();
      String password = _pass.text.trim();
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Signed in successfully"),
            backgroundColor: Color(0xFFD81B60),
          ),
        );
      }
    } catch (e) {
      print("Error during sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF37474F), // Slate Gray background
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  color: Color(0xFFD81B60), // Deep Pink spinner
                )
              : Container(
                  width: 300, // Slightly wider for better layout
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF455A64), // Darker Slate
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Admin Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFFECEFF1), // Light Gray
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _email,
                          style: TextStyle(color: Color(0xFFECEFF1)),
                          decoration: InputDecoration(
                            label: Text(
                              "Email",
                              style: TextStyle(color: Color(0xFFECEFF1)),
                            ),
                            hintText: "Enter your email",
                            hintStyle: TextStyle(color: Color(0xFFECEFF1).withOpacity(0.6)),
                            filled: true,
                            fillColor: Color(0xFF37474F), // Slightly lighter fill
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFECEFF1).withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFD81B60)), // Deep Pink focus
                            ),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Color(0xFFECEFF1),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _pass,
                          style: TextStyle(color: Color(0xFFECEFF1)),
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            label: Text(
                              "Password",
                              style: TextStyle(color: Color(0xFFECEFF1)),
                            ),
                            hintText: "Enter your password",
                            hintStyle: TextStyle(color: Color(0xFFECEFF1).withOpacity(0.6)),
                            filled: true,
                            fillColor: Color(0xFF37474F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFECEFF1).withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFD81B60)),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFFECEFF1),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              icon: Icon(
                                _isObscure ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFFECEFF1),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD81B60), // Deep Pink
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            elevation: 2,
                          ),
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
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