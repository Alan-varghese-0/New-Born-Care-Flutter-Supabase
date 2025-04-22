import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';
import 'package:midwife/screen/changepass.dart';
import 'package:midwife/screen/dashboard.dart';
import 'package:midwife/screen/editprofile.dart';
import 'package:midwife/screen/login.dart';

class MidwifeAccount extends StatefulWidget {
  const MidwifeAccount({super.key});

  @override
  State<MidwifeAccount> createState() => _MidwifeAccountState();
}

class _MidwifeAccountState extends State<MidwifeAccount> {
  String name = "";
  String email = "";
  String about = "";
  String contact = "";
  String address = "";
  String image = '';

  Future<void> fetchMidwife() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_midwife").select().eq('id', uid).single();
      setState(() {
        name = response['midwife_name'];
        email = response['midwife_email'];
        about = response['midwife_about'];
        contact = response['midwife_contact'];
        address = response['midwife_address'];
        image = response['midwife_photo'];
      });
    } catch (e) {
      print("Midwife not found: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMidwife();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700, // Match MidwifeLogin AppBar
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Midwife Profile",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.login_outlined,color: Colors.white,),
            onPressed: () {
              supabase.auth.signOut().then((value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MidwifeLogin()),
                  (route) => false,
                );
              }).catchError((error) {
                print("Error signing out: $error");
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Match MidwifeLogin card background
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.purple.shade700, // Match MidwifeLogin AppBar
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.purple.shade100.withOpacity(0.9), // Subtle purple tint
                      backgroundImage: NetworkImage(image),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Profile Fields and Buttons
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Information",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700, // Match MidwifeLogin header
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildProfileField("Contact", contact, Icons.phone),
                    const SizedBox(height: 16),
                    buildProfileField("Address", address, Icons.location_on),
                    const SizedBox(height: 16),
                    buildProfileField("About me", about, Icons.info),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700, // Match MidwifeLogin button
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade200, // Lighter purple for secondary action
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Change Password",
                            style: GoogleFonts.nunito(fontSize: 16, color: Colors.purple.shade800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)], // Match MidwifeLogin shadow
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.purple.shade700, size: 24), // Match MidwifeLogin theme
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700, // Match MidwifeLogin header
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "Not provided" : value,
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
