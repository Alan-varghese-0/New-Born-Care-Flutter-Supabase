import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/change_pass.dart';
import 'package:user/screens/edit_profile.dart';
import 'package:user/screens/home.dart';
import 'package:user/screens/login.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String name = "";
  String email = "";
  String contact = "";
  String address = "";
  String initial = "";

  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_user").select().eq('id', uid).single();
      print("User data fetched: $response");
      setState(() {
        name = response['user_name'] ?? "";
        email = response['user_email'] ?? "";
        contact = response['user_contact'] ?? "";
        address = response['user_address'] ?? "";
      });
      getInitials(response['user_name'] ?? "");
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  void getInitials(String name) {
    String initials = '';
    if (name.isNotEmpty) {
      List<String> nameParts = name.split(' ');
      if (nameParts.isNotEmpty) {
        initials += nameParts[0][0];
        if (nameParts.length > 1) {
          initials += nameParts[1][0];
        }
      }
    }
    setState(() {
      initial = initials.toUpperCase();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Soft pink background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Pregnancy theme gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
          },
        ),
        title: Text(
          "My Journey",
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_outlined),
            onPressed: () {
              supabase.auth.signOut().then((value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              }).catchError((error) {
                print("Error signing out: $error");
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade200.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.purple.shade100.withOpacity(0.2),
                  child: Text(
                    initial,
                    style: GoogleFonts.nunito(
                      fontSize: 50,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Profile Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileField("Name", name),
                    const SizedBox(height: 20),
                    _buildProfileField("Email", email),
                    const SizedBox(height: 20),
                    _buildProfileField("Contact", contact),
                    const SizedBox(height: 20),
                    _buildProfileField("Address", address, height: 80),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons (Fixed Overflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Reduced padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Reduced padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        "Change Password",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, {double height = 50}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label:",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.purple.shade800,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: height,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value.isEmpty ? "Not set" : value,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }
}