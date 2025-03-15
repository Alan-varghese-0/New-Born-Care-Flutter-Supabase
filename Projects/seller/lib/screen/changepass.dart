import 'package:flutter/material.dart';

class Schangepassword extends StatefulWidget {
  const Schangepassword({super.key});

  @override
  State<Schangepassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<Schangepassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 500, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildPasswordField("Old Password", _oldPasswordController, _isOldPasswordVisible, () {
                setState(() {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                });
              }),
              const SizedBox(height: 15),
              buildPasswordField("New Password", _newPasswordController, _isNewPasswordVisible, () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              }),
              const SizedBox(height: 15),
              buildPasswordField("Confirm Password", _confirmPasswordController, _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Update Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.teal),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.orange[50],
      ),
    );
  }

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }
    // Call API to update password (Implement logic here)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully"), backgroundColor: Colors.green),
    );
  }
}
