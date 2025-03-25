import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/community/viewpost.dart';
import 'package:user/screens/forum.dart';
import 'package:user/screens/home_content.dart';
import 'package:user/screens/my_account.dart';
import 'package:user/screens/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name = "";

  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_user").select().eq('id', uid).single();
      setState(() {
        name = response['user_name'] ?? "";
      });
    } catch (e) {
      print("User fetch failed: $e");
    }
  }

  int selectedIndex = 0;

  List<Widget> pageContent = [
    const HomeContent(),
    const Forum(),
    const Viewpost(),
  ];

  String getInitials(String name) {
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
    return initials.toUpperCase();
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
      drawer: Drawer(
        width: 250,
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccount()));
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.purple.shade100.withOpacity(0.2), // Softer purple
                    child: Text(
                      getInitials(name),
                      style: GoogleFonts.nunito(
                        fontSize: 30,
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name.isEmpty ? "Mama-to-Be" : name, // Pregnancy-friendly default
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico( // Nurturing font
                      fontSize: 24,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDrawerItem(Icons.favorite, "My Journey", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccount()));
            }),
            _buildDrawerItem(Icons.chat_bubble_outline, "Pregnancy Q&A", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Forum()));
            }),
            _buildDrawerItem(Icons.photo_camera, "Moments", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Viewpost()));
            }),
            _buildDrawerItem(Icons.help_outline, "Support", () {}),
            _buildDrawerItem(Icons.logout, "Log Out", () async {
              await supabase.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
            }),
          ],
        ),
      ),
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
        title: Text(
          "NewBorn Care", // Pregnancy-focused app name
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MidwifeListScreen()));
            },
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            tooltip: 'Find a Midwife',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccount()));
            },
            icon: const Icon(Icons.person, color: Colors.white, size: 28),
            tooltip: 'My Journey',
          ),
        ],
      ),
      body: pageContent[selectedIndex],
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   unselectedItemColor: Colors.pink.shade300,
      //   selectedItemColor: Colors.purple.shade800,
      //   currentIndex: selectedIndex,
      //   onTap: (value) {
      //     setState(() {
      //       selectedIndex = value;
      //     });
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Q&A"),
      //     BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Moments"),
      //   ],
      //   type: BottomNavigationBarType.fixed,
      //   selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14),
      //   unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
      // ),
      // floatingActionButton: selectedIndex == 1
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           // Add logic to create a new Q&A post if needed
      //         },
      //         backgroundColor: Colors.pink.shade300, // Theme color
      //         elevation: 4,
      //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //         child: const Icon(Icons.add, color: Colors.white, size: 32),
      //       )
      //     : null,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade600, size: 24), // Theme color
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: Colors.purple.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}