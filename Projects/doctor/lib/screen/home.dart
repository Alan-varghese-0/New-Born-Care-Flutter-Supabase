import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  final List<String> menuItems = ["Dashboard", "Appointments", "Patients", "Messages", "Settings"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blue[900],
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/doctor.jpg"), // Placeholder Image
                ),
                SizedBox(height: 10),
                Text(
                  "Dr. John Doe",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Cardiologist", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 20),
                Divider(color: Colors.white54),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          index == 0 ? Icons.dashboard : 
                          index == 1 ? Icons.calendar_today :
                          index == 2 ? Icons.people : 
                          index == 3 ? Icons.message : Icons.settings,
                          color: Colors.white,
                        ),
                        title: Text(menuItems[index], style: TextStyle(color: Colors.white)),
                        selected: _selectedIndex == index,
                        selectedTileColor: Colors.blue[700],
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                Divider(color: Colors.white54),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Welcome, Dr. John Doe",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("assets/doctor.jpg"), // Profile Image
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionCard("Appointments", Icons.calendar_today, Colors.orange),
                      _buildQuickActionCard("Patients", Icons.people, Colors.green),
                      _buildQuickActionCard("Messages", Icons.message, Colors.blue),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Recent Appointments
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upcoming Appointments",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(Icons.person, color: Colors.blue),
                                    title: Text("Patient ${index + 1}"),
                                    subtitle: Text("Date: 2025-03-20 | Time: 10:00 AM"),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Card Widget
  Widget _buildQuickActionCard(String title, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
