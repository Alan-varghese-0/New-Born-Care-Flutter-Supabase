import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int districtCount = 0;
  int placeCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Fetch district count
      final districtResponse = await supabase.from('tbl_district').select().count();
      final placeResponse = await supabase.from('tbl_place').select().count();

      setState(() {
        districtCount = districtResponse.count;
        placeCount = placeResponse.count;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching stats: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching stats: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF37474F), // Slate Gray background
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD81B60), // Deep Pink spinner
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Welcome Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF455A64), // Darker Slate
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to Pregnancy Care Admin",
                          style: TextStyle(
                            color: Color(0xFFECEFF1), // Light Gray
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Manage districts, places, and more from this dashboard.",
                          style: TextStyle(
                            color: Color(0xFFECEFF1).withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Stats Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard("Districts", districtCount.toString()),
                      _buildStatCard("Places", placeCount.toString()),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Quick Actions or Placeholder
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF455A64), // Darker Slate
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Actions",
                          style: TextStyle(
                            color: Color(0xFFECEFF1),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to District screen or trigger an action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Add District clicked"),
                                backgroundColor: Color(0xFFD81B60),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD81B60), // Deep Pink
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: Text(
                            "Add District",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to Place screen or trigger an action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Add Place clicked"),
                                backgroundColor: Color(0xFFD81B60),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD81B60), // Deep Pink
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: Text(
                            "Add Place",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF455A64), // Darker Slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD81B60).withOpacity(0.5)), // Subtle pink border
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: Color(0xFFD81B60), // Deep Pink
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFFECEFF1), // Light Gray
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}