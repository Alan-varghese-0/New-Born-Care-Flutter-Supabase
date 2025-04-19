import 'package:admin/screens/account.dart';
import 'package:admin/screens/add_audio.dart';
import 'package:admin/screens/audiocat.dart';
import 'package:admin/screens/district.dart';
import 'package:admin/screens/midwife_appoin.dart';
import 'package:admin/screens/midwife_verification.dart';
import 'package:admin/screens/place.dart';
import 'package:admin/screens/userbooking.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0;

  List<String> pageName = [
    'Account',
    'District',
    'Place',
    'audio \n category',
    'new audio',
    'midwife \n verification',
    'booking',
  ];

  List<IconData> pageIcon = [
    Icons.account_circle,
    Icons.location_city,
    Icons.place,
    Icons.headset_mic,
    Icons.music_note_sharp,
    Icons.verified_user,
    Icons.book,
  ];

  List<Widget> pageContent = [
    Home(),
    District(),
    Place(),
    Audiocat(),
    AddAudio(),
    MidwifeVerify(),
    AdminBookingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pregnancy Care Admin",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFD81B60), // Deep Pink
        elevation: 2, // Subtle shadow
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications here
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              // Handle logout here
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (Left Side)
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF263238), // Dark Grayish Blue
              child: Column(
                children: [
                  // Sidebar Header
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Color(0xFFD81B60), // Deep Pink
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite, // Heart icon for pregnancy care
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Care Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sidebar Menu
                  Expanded(
                    child: ListView.builder(
                      itemCount: pageName.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            leading: Icon(
                              pageIcon[index],
                              color: isSelected ? Colors.white : Color(0xFFECEFF1),
                              size: 26,
                            ),
                            title: Text(
                              pageName[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Color(0xFFECEFF1),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            tileColor: isSelected ? Color(0xFFD81B60) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            hoverColor: Color(0xFFD81B60).withOpacity(0.2), // Subtle pink hover
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content area (Right Side)
          Expanded(
            flex: 6,
            child: Container(
              color: Color(0xFF37474F), // Slate Gray
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2, // Subtle shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Color(0xFF455A64), // Darker Slate
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: pageContent[selectedIndex],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}