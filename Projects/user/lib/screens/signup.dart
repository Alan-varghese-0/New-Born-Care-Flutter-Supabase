import 'package:flutter/material.dart';
import 'package:user/components/form_validation.dart';
import 'package:user/main.dart';
import 'package:user/screens/duedate.dart';
import 'package:user/screens/login.dart';
import 'package:user/screens/start.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isObsture = true;
  bool _isObsture2 = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _cpassController = TextEditingController();

  final TextEditingController _dobcontroller = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime minDate = currentDate
        .subtract(Duration(days: 365 * 18)); // 18 years ago from today

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minDate,
      firstDate: DateTime(1900),
      lastDate: minDate, // Set the last selectable date to 18 years ago
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobcontroller.text = "${_selectedDate?.toLocal()}"
            .split(' ')[0]; // Display as yyyy-MM-dd
      });
    }
  }

  Future<void> register() async {
    try {
      final authentication = await supabase.auth.signUp(password: _passController.text, email: _emailController.text);
      String uid = authentication.user!.id;
      signUp(uid);
    } catch (e) {
      print("Error Auth: $e");
    }
  }

  Future<void> signUp(String uid) async {
    try {
      await supabase.from("tbl_user").insert({
        "id":uid,
        "user_name" : _nameController.text,
        "user_email": _emailController.text,
        "user_contact": _contactController.text,
        "user_pass" : _passController.text,
        "user_dob" : _dobcontroller.text,
        "user_address": _addressController.text,
        
      });
      print("Instered");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("mission accomplished")));
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Duedate(),));
    } catch (e) {
      print("Error Registration: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("mission failed || cause of failuer => $e")));

    }
  }

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
          "sign up",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration:
              BoxDecoration(color: Color(0xFFFFC0CB)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Enter your name",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _nameController,
                  validator: (value) => FormValidation.validateName(value),
                  decoration: InputDecoration(
                      fillColor:Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'name here..',
                      suffixIcon: Icon(Icons.person_3_outlined)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your DOB",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateDob(value),
                  controller: _dobcontroller,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'DOB here...',
                      suffixIcon: Icon(Icons.calendar_month_outlined)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your E-mail",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) => FormValidation.validateEmail(value),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'E-mail here...',
                      suffixIcon: Icon(Icons.mail)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your Contact",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _contactController,
                  validator: (value) => FormValidation.validateContact(value),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Contact here...',
                      suffixIcon: Icon(Icons.phone)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your addtrss",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _addressController,
                  validator: (value) => FormValidation.validateAddress(value),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Address here...',
                      suffixIcon: Icon(Icons.place)),
                  minLines: 3,
                  maxLines: null,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _passController,
                  validator: (value) => FormValidation.validatePassword(value),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: 'password here...',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObsture = !_isObsture;
                        });
                      },
                      icon: Icon(
                          _isObsture ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObsture,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Comform password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _cpassController,
                  validator: (value) =>
                      FormValidation.validateConfirmPassword(value, _passController.text),
                  decoration: InputDecoration(
                    fillColor:Color(0xFFFFFFFF),
                      filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: 'password here...',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObsture2 = !_isObsture2;
                        });
                      },
                      icon: Icon(_isObsture2
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObsture2,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 230, 104, 146)),
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                       register();
                      // }
                    },
                    child: Text("sign up")),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Color.fromARGB(255, 230, 104, 146)),
                        )),
                  ],
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
