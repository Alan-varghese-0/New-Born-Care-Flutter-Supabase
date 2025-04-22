import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:midwife/main.dart';
import 'package:midwife/screen/appointments.dart';
import 'package:midwife/screen/my_account.dart';
import 'package:midwife/screen/my_history.dart';
import 'package:midwife/screen/my_patients.dart';
import 'package:midwife/screen/login.dart'; // Added import for Login screen

// Upcoming Appointments Card
class UpcomingAppointmentsCard extends StatefulWidget {
  final String userId;
  const UpcomingAppointmentsCard({super.key, required this.userId});

  @override
  State<UpcomingAppointmentsCard> createState() => _UpcomingAppointmentsCardState();
}

class _UpcomingAppointmentsCardState extends State<UpcomingAppointmentsCard> {
  List<dynamic> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final response = await supabase
          .from('tbl_appointments')
          .select()
          .eq('user_id', widget.userId)
          .gte('appointment_date', today)
          .order('appointment_date', ascending: true)
          .limit(5);

      setState(() {
        _appointments = response;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming Appointments",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _appointments.isEmpty
                    ? Text("No upcoming appointments.")
                    : Column(
                        children: _appointments.map((appt) {
                          final date = DateTime.parse(appt['appointment_date']);
                          final time = appt['appointment_time'] ?? '';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.calendar_today, color: Colors.purple.shade400),
                            title: Text(
                              "$time - ${appt['appointment_detals'] ?? ''}",
                              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              DateFormat('EEE, MMM d').format(date),
                              style: GoogleFonts.nunito(color: Colors.grey.shade600),
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String name = "";
  String email = "";
  String contact = "";
  String address = "";
  String image = "";
  List<dynamic> assignedPatients = [];
  String? selectedUserId;

  Future<void> fetchMidwife() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_midwife").select().eq('id', uid).single();
      setState(() {
        name = response['midwife_name'] ?? 'Unknown';
        email = response['midwife_email'] ?? 'N/A';
        contact = response['midwife_contact'] ?? 'N/A';
        address = response['midwife_address'] ?? 'N/A';
        image = response['midwife_photo'] ?? 'https://via.placeholder.com/150';
      });
    } catch (e) {
      print("Midwife not found: $e");
    }
  }

  Future<void> fetchPatients() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final List<dynamic> response = await supabase
          .from("tbl_booking")
          .select("*, tbl_user(*)")
          .eq("midwife_id", userId);

      setState(() {
        assignedPatients = response;
        selectedUserId = assignedPatients.isNotEmpty
            ? assignedPatients.first['tbl_user']['id']?.toString()
            : null;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading patient data: $e");
      setState(() {
        isLoading = false;
        selectedUserId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading patient data: $e")),
      );
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MidwifeLogin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMidwife();
    fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: Text(
          "Welcome, $name!",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                  backgroundColor: Colors.purple.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.purple.shade100.withOpacity(0.9),
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
                        color: Colors.purple.shade700,
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
              Icon(Icons.arrow_forward_ios, color: Colors.purple.shade700, size: 20),
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
            color: Colors.purple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAction(
              "My Patient",
              Icons.people,
              Colors.purple.shade700,
              const AssignedPatientDetails(),
            ),
            _buildQuickAction(
              "Appointments",
              Icons.calendar_today,
              Colors.purple.shade600,
              MidwifeAppointmentsScreen(userId: selectedUserId ?? ''),
            ),
            _buildQuickAction(
              "History",
              Icons.history,
              Colors.purple.shade400,
              const PreviousPatientsScreen(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (selectedUserId != null)
          UpcomingAppointmentsCard(userId: selectedUserId!),
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
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.purple.shade700,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple.shade100.withOpacity(0.9),
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
                _buildDrawerItem(context, Icons.people, "My Patients", const AssignedPatientDetails()),
                _buildDrawerItem(context, Icons.logout, "Log Out", logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, dynamic action) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade700),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.purple.shade700,
        ),
      ),
      onTap: () {
        if (action is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => action),
          );
        } else if (action is Function) {
          action();
        }
      },
    );
  }
}