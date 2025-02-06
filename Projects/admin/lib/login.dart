import 'package:admin/dashboard.dart';
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
  void Signin()async{
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
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }

print("sign in successfully");

  } catch (e) {
    print("Error During sign in $e");
  }
}

    bool _isObsture = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            // color: const Color.fromARGB(255, 227, 176, 25)
            image: DecorationImage(image: AssetImage("assets/pg.jpg"),fit: BoxFit.fill)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: const Color.fromARGB(255, 255, 230, 154)
              ),),
              Container(
                width: 250,
                height: 300,
                // ignore: deprecated_member_use
                decoration: BoxDecoration(borderRadius:BorderRadius.circular(50),
                color: Colors.grey.withOpacity(0.5),
                 ),
                
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        // fillColor: Colors.white,
                        // filled: false,
                        hintText: "enter the email",
                        label: Text("email"),
                        prefixIcon: Icon(Icons.mail)
                      ),
                    ),
                    TextFormField(
                      controller: _pass,
                      decoration: InputDecoration(
                        // fillColor: Colors.white,
                        // filled: false,
                        hintText: "enter the password",
                        label: Text("password"),
                        prefixIcon: Icon(Icons.lock) ,
                  suffixIcon: IconButton(onPressed: (){
                    setState(() {
                      _isObsture = !_isObsture;
                    });
                  }, icon: Icon( _isObsture ?  Icons.visibility_off : Icons.visibility ),),
                  // filled: false,
                  // fillColor: Colors.amber,           
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: _isObsture,
                      ),
                    
                    ElevatedButton(onPressed: (){
                     Signin();
                    }, 
                    style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 99, 85)
                    ),
                    child: Text("Sign in",style:TextStyle(color: Color(0xFFF8C8D1)),))
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}