import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviousPatientsScreen extends StatefulWidget {
  const PreviousPatientsScreen({super.key});

  @override
  State<PreviousPatientsScreen> createState() => _PreviousPatientsScreenState();
}

class _PreviousPatientsScreenState extends State<PreviousPatientsScreen> {
  final List<Map<String, String>> previousPatients = [
    {
      "name": "Sophia Carter",
      "age": "29",
      "due_date": "Feb 12, 2024",
      "contact": "+1234567890",
    },
    {
      "name": "Isabella Anderson",
      "age": "32",
      "due_date": "Jan 5, 2024",
      "contact": "+9876543210",
    },
    {
      "name": "Emma Thompson",
      "age": "27",
      "due_date": "Dec 18, 2023",
      "contact": "+1122334455",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Previous Patients",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: previousPatients.isEmpty
            ? Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No previous patients found.",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: previousPatients.length,
                itemBuilder: (context, index) {
                  final patient = previousPatients[index];
                  return _buildPatientCard(patient);
                },
              ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, String> patient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.teal.shade100.withOpacity(0.9),
              child: Icon(
                Icons.person,
                color: Colors.teal.shade600,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name']!,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Age: ${patient['age']}",
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  Text(
                    "Due Date: ${patient['due_date']}",
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  Text(
                    "Contact: ${patient['contact']}",
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.description, color: Colors.teal.shade600),
              tooltip: "View Reports",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Viewing reports for ${patient['name']}",
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
      ),
    );
  }
}
