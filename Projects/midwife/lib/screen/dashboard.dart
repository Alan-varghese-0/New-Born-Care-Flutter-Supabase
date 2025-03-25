import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';
import 'package:midwife/screen/add_report.dart';
import 'package:midwife/screen/appointments.dart';
import 'package:midwife/screen/my_account.dart';
import 'package:midwife/screen/my_history.dart';
import 'package:midwife/screen/my_patients.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> mockPatientData = {
    'name': 'Jane Doe',
    'age': '28',
    'due_date': '2025-06-15',
    'contact': '+123 456 7890',
    'blood_pressure': '120/80 mmHg',
    'weight': '65',
    'history': 'Previous miscarriage in 2022',
    'conditions': 'Gestational diabetes',
    'appointments': [
      {'date': '2025-04-10', 'notes': 'Routine checkup - all vitals stable'},
      {'date': '2025-05-05', 'notes': 'Ultrasound scheduled - fetal growth assessment'},
    ],
  };

  String name = "";
  String email = "";
  String contact = "";
  String address = "";
  String image = "";
  String initial = "";

  // List to store notes (mock data for now)
  List<Map<String, String>> notes = [
    {'date': '2025-03-18', 'content': 'Reviewed patient records for upcoming visits.'},
    {'date': '2025-03-19', 'content': 'Prepared materials for prenatal class.'},
  ];

  Future<void> fetchMidwife() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_midwife").select().eq('id', uid).single();
      setState(() {
        name = response['midwife_name'];
        email = response['midwife_email'];
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
    assignedPatients.add(mockPatientData);
  }

  List<Map<String, dynamic>> assignedPatients = [];
  List<Map<String, dynamic>> assignedHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Welcome, $name!",
          style: GoogleFonts.nunito(
            fontSize: 20,
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
            icon: const Icon(Icons.notifications, size: 28, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "No new notifications",
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildNotesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MidwifeAccount()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal.shade100.withOpacity(0.9),
                backgroundImage: NetworkImage(image),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.teal.shade600, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAction(
              "My Patient",
              Icons.people,
              Colors.teal.shade600,
              AssignedPatientDetails(patientData: mockPatientData),
            ),
            _buildQuickAction(
              "Appointments",
              Icons.calendar_today,
              Colors.teal.shade500,
              const MidwifeAppointmentsScreen(),
            ),
            _buildQuickAction(
              "Reports",
              Icons.bar_chart,
              Colors.teal.shade400,
               PatientReportsScreen(),
            ),
            _buildQuickAction(
              "History",
              Icons.history,
              Colors.teal.shade300,
              const PreviousPatientsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, Widget destinationScreen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Notes",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddNoteDialog(context);
              },
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: Text(
                "Add Note",
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        notes.isEmpty
            ? Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No notes available.",
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 150, // Fixed height for scrollable notes
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.note, color: Colors.teal.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['date']!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note['content']!,
                                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Add New Note",
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter your note here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.nunito(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    notes.add({
                      'date': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD format
                      'content': noteController.text,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Note added successfully!",
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                      backgroundColor: Colors.teal.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.nunito(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage: NetworkImage(image),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.person, "My Profile", const MidwifeAccount()),
                _buildDrawerItem(context, Icons.people, "My Patients",
                    AssignedPatientDetails(patientData: mockPatientData)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade600),
      title: Text(
        title,
        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const HomeScreen(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}