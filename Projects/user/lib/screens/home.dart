import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/cart.dart';
import 'package:user/screens/forum.dart';
import 'package:user/screens/home_content.dart';
import 'package:user/screens/my_account.dart';
import 'package:user/screens/post.dart';
import 'package:user/screens/search.dart';
import 'package:user/screens/shop.dart';

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
      final response =
          await supabase.from("tbl_user").select().eq('id', uid).single();
      setState(() {
        name = response['user_name'];
      });
    } catch (e) {
      print("user feach failed $e");
    }
  }

  int selectedIndex = 0;

  List<Widget> pageContent = [
    HomeContent(),
    Forum(),
    Shop(),
    Post(),
  ];

  // Function to extract the initials
  String getInitials(String name) {
    String initials = '';
    if(name!="" || name.isNotEmpty){
      List<String> nameParts = name.split(' ');

    if (nameParts.isNotEmpty) {
      // Take the first letter of the first name
      initials += nameParts[0][0];
      if (nameParts.length > 1) {
        // Take the first letter of the last name if it exists
        initials += nameParts[1][0];
      }
    }
    }

    return initials.toUpperCase(); // Ensure the initials are uppercase
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 250,
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAccount(),
                    ));
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue, // Or any color you prefer
                child: Text(
                  getInitials(name), // Call the function to get initials
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.question_answer),
            //   title: Text("Q&A"),
            // ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text("my orders"),
            ),
            ListTile(
              leading: Icon(Icons.sms_failed_sharp),
              title: Text("my Q&A"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),ListTile(
              leading: Icon(Icons.headset_mic_rounded),
              title: Text("help and support"),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Log Out"),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("New Born Care"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ));
              },
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(),
                    ));
              },
              icon: Icon(Icons.shopping_cart)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAccount(),
                    ));
              },
              icon: Icon(Icons.person_2)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Color.fromARGB(255, 230, 104, 146),
          selectedItemColor: const Color.fromARGB(255, 99, 161, 212),
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer), label: "Q&A"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket_outlined), label: "Shop"),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_collection_rounded), label: "Post"),
          ]),
      body: pageContent[selectedIndex],
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
