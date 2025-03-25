import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientReportsScreen extends StatefulWidget {
  const PatientReportsScreen({super.key});

  @override
  _PatientReportsScreenState createState() => _PatientReportsScreenState();
}

class _PatientReportsScreenState extends State<PatientReportsScreen> {
  // Single patient’s reports (mock data for one patient)
  List<Map<String, String>> _dailyReports = [
    {'date': '2025-03-18', 'content': 'Patient stable, BP 120/80, no complaints.'},
    {'date': '2025-03-19', 'content': 'Discussed prenatal diet, weight 65 kg.'},
  ];

  final TextEditingController _reportController = TextEditingController();
  final String _patientName = "Jane Doe"; // Fixed patient name

  void _addDailyReport() {
    if (_reportController.text.isEmpty) return;

    setState(() {
      _dailyReports.add({
        'date': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
        'content': _reportController.text,
      });
    });

    _reportController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Daily report added for $_patientName!",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteReport(int index) {
    setState(() {
      _dailyReports.removeAt(index);
    });
  }

  void _showAddReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Add Daily Report for $_patientName",
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          content: TextField(
            controller: _reportController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter daily update for $_patientName...",
              hintStyle: GoogleFonts.nunito(color: Colors.grey.shade600),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.nunito(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: _addDailyReport,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Daily Reports for $_patientName",
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: _dailyReports.isEmpty
            ? Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No daily reports available for $_patientName.",
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _dailyReports.length,
                itemBuilder: (context, index) {
                  final report = _dailyReports[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(Icons.note, color: Colors.teal.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report['date']!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report['content']!,
                                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () => _deleteReport(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportDialog,
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const PatientReportsScreen(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}