import 'package:doctor/screen/login.dart';
import 'package:flutter/material.dart';

class DoctorRegistrationPage extends StatefulWidget {
  @override
  _DoctorRegistrationPageState createState() => _DoctorRegistrationPageState();
}

class _DoctorRegistrationPageState extends State<DoctorRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedDistrict;
  String? selectedPlace;
  String? selectedSpecialization = "Gynecologist";

  final List<String> districts = ["District A", "District B", "District C"];
  final List<String> places = ["Place X", "Place Y", "Place Z"];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500, // Fixed width for form
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.local_hospital, size: 60, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  "Doctor Registration",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 15),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),

                // Contact
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 15),

                // License
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: "License Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                SizedBox(height: 15),

                // Address
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                    prefix: Icon(Icons.location_on),
                  ),
                ),
                SizedBox(height: 15),

                // District Dropdown
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: InputDecoration(
                    labelText: "Select District",
                    border: OutlineInputBorder(),
                  ),
                  items: districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedPlace = null; // Reset place when district changes
                    });
                  },
                ),
                SizedBox(height: 15),

                // Place Dropdown (this can be dynamic based on the selected district)
                DropdownButtonFormField<String>(
                  value: selectedPlace,
                  decoration: InputDecoration(
                    labelText: "Select Place",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: "City A", child: Text("City A")),
                    DropdownMenuItem(value: "City B", child: Text("City B")),
                    DropdownMenuItem(value: "City C", child: Text("City C")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPlace = value;
                    });
                  },
                ),
                SizedBox(height: 15),

                // Contact Number
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 15),

                // Specialization (Radio Button)
                
                SizedBox(height: 20),
                // Register Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {},
                  child:
                      Text("Register", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorLoginPage()));
                  },
                  child: Text("Already have an account? Login", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
              
          ),
        ),
      ),
      
    );
  }
}
