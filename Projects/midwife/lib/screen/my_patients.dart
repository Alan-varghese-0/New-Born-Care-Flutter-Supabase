import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignedPatientDetails extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const AssignedPatientDetails({super.key, required this.patientData});

  @override
  State<AssignedPatientDetails> createState() => _AssignedPatientDetailsState();
}

class _AssignedPatientDetailsState extends State<AssignedPatientDetails> {
  @override
  Widget build(BuildContext context) {
    final patient = widget.patientData;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "${patient['name']}'s Details",
          style: GoogleFonts.nunito(
            fontSize: 22,
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
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sharing patient details...")),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(patient),
              const SizedBox(height: 25),
              _buildSectionTitle("Vital Signs"),
              const SizedBox(height: 10),
              _buildVitalSigns(patient),
              const SizedBox(height: 25),
              _buildSectionTitle("Appointments"),
              const SizedBox(height: 10),
              _buildAppointmentList(patient['appointments']),
              const SizedBox(height: 25),
              _buildSectionTitle("Midwife Notes"),
              const SizedBox(height: 10),
              _buildNotesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> patient) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.teal.shade100.withOpacity(0.4),
              child: Icon(Icons.pregnant_woman, color: Colors.teal.shade600, size: 35),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.cake, "Age: ${patient['age']}"),
                  _buildInfoRow(Icons.calendar_today, "Due: ${patient['due_date']}"),
                  _buildInfoRow(Icons.phone, "Contact: ${patient['contact']}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal.shade500),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.bookmark, color: Colors.teal.shade500, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalSigns(Map<String, dynamic> patient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Blood Pressure", patient['blood_pressure'], Icons.favorite, Colors.red.shade400),
            _buildDetailRow("Weight", "${patient['weight']} kg", Icons.scale, Colors.teal.shade500),
            _buildDetailRow("Pregnancy History", patient['history'], Icons.history, Colors.grey.shade600),
            _buildDetailRow("Known Conditions", patient['conditions'], Icons.health_and_safety, Colors.orange.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>>? appointments) {
    if (appointments == null || appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          "No upcoming appointments.",
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      children: appointments.map((appointment) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(Icons.event, color: Colors.teal.shade500, size: 28),
            title: Text(
              appointment['date'],
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              appointment['notes'],
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade600),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal.shade300, size: 18),
            onTap: () {
              // Could navigate to a detailed appointment view
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Add observations or notes...",
                hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.teal.shade50.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Notes saved successfully!",
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                    backgroundColor: Colors.teal.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: Text(
                "Save Notes",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AssignedPatientDetails(
      patientData: {
        'name': 'Jane Doe',
        'age': 28,
        'due_date': '2025-06-15',
        'contact': '+1-555-123-4567',
        'blood_pressure': '120/80 mmHg',
        'weight': 65,
        'history': 'First pregnancy, no complications reported so far',
        'conditions': 'Mild anemia, monitored closely',
        'appointments': [
          {'date': '2025-03-25', 'notes': 'Routine checkup'},
          {'date': '2025-04-10', 'notes': 'Ultrasound'},
        ],
      },
    ),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}