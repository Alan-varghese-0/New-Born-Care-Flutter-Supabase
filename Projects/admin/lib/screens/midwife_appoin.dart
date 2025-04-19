import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await supabase.from('tbl_appointments').select('''
        id,
        appointment_date,
        appointment_time,
        appointment_detals,
        user_id,
        midwife_id,
        tbl_user!user_id(user_name:patient_name),
        tbl_user!midwife_id(user_name:midwife_name)
      ''').order('appointment_date', ascending: true);
      print("Appointments data fetched: $response");
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching appointments: $e')),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredAppointments(String filter) {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    switch (filter) {
      case 'today':
        return _appointments.where((appt) {
          final date = DateTime.tryParse(appt['appointment_date'] ?? '') ?? today;
          return date.year == todayKey.year &&
              date.month == todayKey.month &&
              date.day == todayKey.day;
        }).toList();
      case 'upcoming':
        return _appointments.where((appt) {
          final date = DateTime.tryParse(appt['appointment_date'] ?? '') ?? today;
          return date.isAfter(todayKey);
        }).toList();
      case 'all':
      default:
        return _appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Appointments"),
        backgroundColor: const Color.fromARGB(255, 182, 152, 251),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Today"),
            Tab(text: "Upcoming"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                AppointmentList(
                  appointments: getFilteredAppointments('all'),
                  onRefresh: fetchAppointments,
                ),
                AppointmentList(
                  appointments: getFilteredAppointments('today'),
                  onRefresh: fetchAppointments,
                ),
                AppointmentList(
                  appointments: getFilteredAppointments('upcoming'),
                  onRefresh: fetchAppointments,
                ),
              ],
            ),
    );
  }
}

class AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final Future<void> Function() onRefresh;

  const AppointmentList({
    super.key,
    required this.appointments,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFD81B60),
      child: appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 70,
                    color: Color(0xFFECEFF1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No appointments found",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFECEFF1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Check back later!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFECEFF1),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return AppointmentCard(appointment: appointment);
              },
            ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF263238),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appointment #APPT${appointment['id'] ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFECEFF1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Patient: ${appointment['tbl_user_user_id']?['patient_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "Midwife: ${appointment['tbl_user_midwife_id']?['midwife_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "Midwife ID: ${appointment['midwife_id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "Date: ${appointment['appointment_date'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "Time: ${appointment['appointment_time'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AppointmentDetailsDialog(appointment: appointment),
                    );
                  },
                  child: const Text(
                    "View Details",
                    style: TextStyle(
                      color: Color(0xFFD81B60),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsDialog({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFF263238),
      title: const Text(
        "Appointment Details",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFFECEFF1),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appointment ID: ${appointment['id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Patient: ${appointment['tbl_user_user_id']?['patient_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Patient ID: ${appointment['user_id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Midwife: ${appointment['tbl_user_midwife_id']?['midwife_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Midwife ID: ${appointment['midwife_id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${appointment['appointment_date'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Time: ${appointment['appointment_time'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Details: ${appointment['appointment_detals'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(
              color: Color(0xFFD81B60),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}