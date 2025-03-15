import 'package:flutter/material.dart';
import 'package:seller/main.dart';
import 'package:seller/screen/account.dart';
import 'package:seller/screen/c_and_r.dart';
import 'package:seller/screen/products.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        leading: IconButton(onPressed: null, icon: Icon(Icons.logout_outlined,color: Colors.black,)),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Products(),
                    ));
              },
              child: Text(
                "Products",
                style: GoogleFonts.playfairDisplay(color: Colors.black),
              )),
          SizedBox(width: 20),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CAndR(),
                    ));
              },
              child: Text(
                "Complaints/Reviews",
                style: GoogleFonts.playfairDisplay(color: Colors.black),
              )),
          SizedBox(width: 20),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAccount()),
                );
              } else if (value == 'Log Out') {
                // Add your logout functionality here
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Profile',
                  child: Text('My Profile'),
                ),
                PopupMenuItem<String>(
                  value: 'Log Out',
                  child: Text('Log Out'),
                ),
              ];
            },
            icon: Icon(Icons.more_vert, color: Colors.black),
            color: Colors.green[300],
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.black,
                      child: Text(
                        initial,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Email: $email'  , style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Address: $address', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Contact: $contact', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickActionCard('New Orders', Colors.blue, () {
                  // Add action for new orders
                }),
                _quickActionCard('Manage Products', Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Products()));
                }),
                _quickActionCard('Complaints/Reviews', Colors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CAndR()));
                }),
              ],
            ),

            SizedBox(height: 30),

            // New Orders Section
            Text(
              'New Orders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with dynamic order count
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text('Order #${index + 1}'),
                      subtitle: Text('Order details here'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Add navigation or actions for each order
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Card widget
  Widget _quickActionCard(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: color,
        child: Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
