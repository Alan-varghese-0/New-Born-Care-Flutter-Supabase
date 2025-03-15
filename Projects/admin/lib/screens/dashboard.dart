import 'package:admin/screens/account.dart';
import 'package:admin/screens/category.dart';
import 'package:admin/screens/district.dart';
import 'package:admin/screens/place.dart';
import 'package:admin/screens/subcategorty.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int selectedIndex = 0;

  List<String> pageName = [
    'Account',  // No change
    'District', // No change
    'Place',    // No change
    'Category', // No change
    'Subcategory', // No change
  ];

  List<IconData> pageIcon = [
    Icons.account_circle, // Icon for Account
    Icons.location_city,  // Icon for District
    Icons.place,          // Icon for Place
    Icons.category,       // Icon for Category
    Icons.subscriptions   // Icon for Subcategory
  ];

  List<Widget> pageContent = [
    Account(),   // Account (Unchanged)
    District(),  // District (Unchanged)
    Place(),     // Place (Unchanged)
    Category(),  // Category (Unchanged)
    Subcategory(), // Subcategory (Unchanged)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pregnancy Care Admin Dashboard"),
        backgroundColor: Color(0xFF6DAF7C), // Natural soft green
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications here
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Handle logout here
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (Left Side)
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFFF1F0E6), // Soft light beige for sidebar background
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    leading: Icon(
                      pageIcon[index],
                      color: Color(0xFF4C8C4A), // Darker green for icons
                    ),
                    title: Text(
                      pageName[index],
                      style: TextStyle(color: Color(0xFF4C8C4A)), // Darker green for text
                    ),
                  );
                },
              ),
            ),
          ),
          // Main content area (Right Side)
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/pregnancy_care_bg.jpg"), // Background image
                  fit: BoxFit.cover,
                ),
              ),
              child: pageContent[selectedIndex], // Displays the corresponding content page
            ),
          ),
        ],
      ),
    );
  }
}
