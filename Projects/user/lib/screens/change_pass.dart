import 'package:flutter/material.dart';
import 'package:user/screens/my_account.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAccount(),
                  ));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.cyan),
      ),
    );
  }
}