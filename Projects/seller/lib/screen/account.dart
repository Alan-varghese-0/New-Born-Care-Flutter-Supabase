import 'package:flutter/material.dart';
import 'package:seller/main.dart';
import 'package:seller/screen/changepass.dart';
import 'package:seller/screen/home.dart';

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
      final response = await supabase.from("tbl_seller").select().eq('id', uid).single();
      setState(() {
        name = response['seller_name'];
        email = response['seller_email'];
        contact = response['seller_contact'];
        address = response['seller_address'];
      });
      getInitials(response['seller_name']);
    } catch (e) {
      print("User not found: $e");
    }
  }

  void getInitials(String name) {
    String initials = '';
    if (name.isNotEmpty) {
      List<String> nameParts = name.split(' ');
      initials += nameParts[0][0];
      if (nameParts.length > 1) {
        initials += nameParts[1][0];
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Seller Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log out',
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 30),
                buildProfileField("Name", name, Icons.person),
                buildProfileField("Email", email, Icons.email),
                buildProfileField("Contact", contact, Icons.phone),
                buildProfileField("Address", address, Icons.location_on),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Schangepassword()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Change Password", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal[800]),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                ],
              ),
              child: Text(value, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}