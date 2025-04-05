import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/components/form_validation.dart';
import 'package:user/main.dart';
import 'package:user/screens/duedate.dart';
import 'package:user/screens/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isObscure = true;
  bool _isObscure2 = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _cpassController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime minDate = currentDate.subtract(const Duration(days: 365 * 18)); // 18 years ago

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minDate,
      firstDate: DateTime(1900),
      lastDate: minDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = pickedDate.toLocal().toString().split(' ')[0]; // YYYY-MM-DD
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authentication = await supabase.auth.signUp(
        password: _passController.text,
        email: _emailController.text,
      );
      String uid = authentication.user!.id;
      await signUp(uid);
    } catch (e) {
      print("Error Auth: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sign-up failed: $e",
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.red[400], // Match error theme
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> signUp(String uid) async {
    try {
      await supabase.from("tbl_user").insert({
        "id": uid,
        "user_name": _nameController.text.trim(),
        "user_email": _emailController.text.trim(),
        "user_contact": _contactController.text.trim(),
        "user_pass": _passController.text, // Note: Avoid storing plaintext passwords
        "user_dob": _dobController.text,
        "user_address": _addressController.text.trim(),
        "user_btype": selectedBlood,
      });
      print("Inserted");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sign-up successful!",
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.pink.shade300, // Match success theme
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Duedate()),
      );
    } catch (e) {
      print("Error Registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Registration failed: $e",
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.red[400], // Match error theme
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? selectedBlood;

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
                    "Create Your Account",
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800, // Match theme
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign up to connect with your midwife",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[600], // Match Forum subtitle
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Name Field
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
                      controller: _nameController,
                      validator: (value) => FormValidation.validateName(value),
                      decoration: InputDecoration(
                        hintText: "Enter your full name",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.person, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DOB Field
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
                      controller: _dobController,
                      validator: (value) => FormValidation.validateDob(value),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: "Select your date of birth",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 20),

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
                    child: DropdownButtonFormField(
                      value: selectedBlood,
                      items: [
                      DropdownMenuItem(
                        value: "A+",
                        child: Text("A+"),
                      ),
                      DropdownMenuItem(
                        value: "A-",
                        child: Text("A-"),
                      ),
                      DropdownMenuItem(
                        value: "B+",
                        child: Text("B+"),
                      ),
                      DropdownMenuItem(
                        value: "B-",
                        child: Text("B-"),
                      ),
                      DropdownMenuItem(
                        value: "O+",
                        child: Text("O+"),
                      ),
                      DropdownMenuItem(
                        value: "O-",
                        child: Text("O-"),
                      ),
                      DropdownMenuItem(
                        value: "AB+",
                        child: Text("AB+"),
                      ),
                      DropdownMenuItem(
                        value: "AB-",
                        child: Text("AB-"),
                      ),
                    ], onChanged: (value){
                      setState(() {
                        selectedBlood = value;
                      });
                    },
                     decoration: InputDecoration(
                        hintText: "Select your blood type",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.bloodtype, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    )
                  ),
                  const SizedBox(height: 20),
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
                      controller: _emailController,
                      validator: (value) => FormValidation.validateEmail(value),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.mail, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Field
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
                      controller: _contactController,
                      validator: (value) => FormValidation.validateContact(value),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter your contact number",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.phone, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]), // Match Forum text
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address Field
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
                      controller: _addressController,
                      validator: (value) => FormValidation.validateAddress(value),
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter your address",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.place, color: Colors.purple.shade600), // Match theme
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
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
                      controller: _passController,
                      validator: (value) => FormValidation.validatePassword(value),
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        hintText: "Create a password",
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
                  const SizedBox(height: 20),

                  // Confirm Password Field
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
                      controller: _cpassController,
                      validator: (value) => FormValidation.validateConfirmPassword(value, _passController.text),
                      obscureText: _isObscure2,
                      decoration: InputDecoration(
                        hintText: "Confirm your password",
                        hintStyle: GoogleFonts.nunito(color: Colors.purple.shade600), // Match theme
                        prefixIcon: Icon(Icons.lock, color: Colors.purple.shade600), // Match theme
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure2 ? Icons.visibility_off : Icons.visibility,
                            color: Colors.purple.shade600, // Match theme
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure2 = !_isObscure2;
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

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: register,
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
                      "Sign Up",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600], // Match Forum subtitle
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: Text(
                          "Log In",
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
