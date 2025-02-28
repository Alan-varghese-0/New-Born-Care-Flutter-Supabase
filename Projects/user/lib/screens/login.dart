import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/components/form_validation.dart';
import 'package:user/main.dart';
import 'package:user/screens/home.dart';
import 'package:user/screens/signup.dart';
import 'package:user/screens/start.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  void Signin() async {
    try {
      String email = _email.text;
      String password = _pass.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ));
      }

      print("sign in successfully");
    } catch (e) {
      if (e is AuthException) {
    print("Error During sign in: $e");
    if(e.code == "invalid_credentials")
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email or Password Incorrect")));
    }
    print("Error Code: ${e.code}");
  } else {
    print("Unexpected error: $e");
  }
    }
  }

  bool _isObsture = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Start(),
                  ));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          "login",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Form(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                BoxDecoration(color:Color(0xFFE3F2F1),),
            child: Container(
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    // Text(
                    //   "E-mail",
                    //   style: TextStyle(
                    //     fontSize: 25,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   textAlign: TextAlign.left,
                    // ),
                    TextFormField(
                      controller: _email,
                      validator: (value) => FormValidation.validateEmail(value),
                      decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          hintText: 'Enter your Email',
                          suffixIcon: Icon(Icons.mail)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text(
                    //   'password',
                    //   style: TextStyle(
                    //     fontSize: 25,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   textAlign: TextAlign.left,
                    // ),
                    TextFormField(
                      controller: _pass,
                      validator: (value) =>
                          FormValidation.validatePassword(value),
                      decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObsture = !_isObsture;
                            });
                          },
                          icon: Icon(_isObsture
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _isObsture,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFFFFF8E1)),
                        onPressed: () {
                          Signin();
                        },
                        child: Text(
                          'login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        )),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      children: [
                        Text(
                          "            don't have an account",
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ));
                            },
                            child: Text("sign up")),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
