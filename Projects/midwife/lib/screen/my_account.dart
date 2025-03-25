import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';
import 'package:midwife/screen/dashboard.dart';

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
  String initial = "";
  String image ='';
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
      // getInitials(response['midwife_name']);
    } catch (e) {
      print("Midwife not found: $e");
    }
  }

  // void getInitials(String name) {
  //   String initials = '';
  //   if (name.isNotEmpty) {
  //     List<String> nameParts = name.split(' ');
  //     initials += nameParts[0][0];
  //     if (nameParts.length > 1) {
  //       initials += nameParts[1][0];
  //     }
  //   }
  //   setState(() {
  //     initial = initials.toUpperCase();
  //   });
  // }

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
        backgroundColor: Colors.teal.shade600,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log out',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Logged out successfully",
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  backgroundColor: Colors.teal.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section (Unchanged)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      backgroundImage: NetworkImage(image),
                      // // child: Text(
                      // //   initial,
                      // //   style: GoogleFonts.nunito(
                      // //     fontSize: 36,
                      // //     fontWeight: FontWeight.bold,
                      // //     color: Colors.teal.shade700,
                      // //   ),
                      // ),
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
              // Profile Fields and Buttons (Redesigned)
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
                        color: Colors.teal.shade700,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Edit Profile feature coming soon!",
                                  style: GoogleFonts.nunito(color: Colors.white),
                                ),
                                backgroundColor: Colors.teal.shade600,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Text(
                            "Edit Profile",
                            style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Change Password feature coming soon!",
                                  style: GoogleFonts.nunito(color: Colors.white),
                                ),
                                backgroundColor: Colors.teal.shade600,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade200,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Text(
                            "Change Password",
                            style: GoogleFonts.nunito(fontSize: 16, color: Colors.teal.shade800),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.teal.shade600, size: 24),
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
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "Not provided" : value,
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade800),
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

void main() {
  runApp(MaterialApp(
    home: const MidwifeAccount(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}