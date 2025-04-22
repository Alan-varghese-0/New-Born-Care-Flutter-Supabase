import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';

// Health class to structure tbl_health data
class Health {
  final String bp;
  final String weight;
  final String sugar;

  Health({
    required this.bp,
    required this.weight,
    required this.sugar,
  });
}

// PatientDetails class to structure tbl_pdetails data
class PatientDetails {
  final String? history;
  final String? conditions;

  PatientDetails({
    this.history,
    this.conditions,
  });
}

class PreviousPatientsScreen extends StatefulWidget {
  const PreviousPatientsScreen({super.key});

  @override
  State<PreviousPatientsScreen> createState() => _PreviousPatientsScreenState();
}

class _PreviousPatientsScreenState extends State<PreviousPatientsScreen> {
  List<dynamic> previousPatients = [];
  bool isLoading = true;

  Future<void> fetchPreviousPatients() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final List<dynamic> response = await supabase
          .from("tbl_booking")
          .select("*, tbl_user(*)")
          .eq("midwife_id", userId)
          .eq("booking_status", 5); // Assuming 5 indicates completed bookings

      setState(() {
        previousPatients = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading previous patients: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<List<Health>> fetchHealthData(int bookingId) async {
    try {
      final response = await supabase
          .from("tbl_health")
          .select()
          .eq("booking_id", bookingId);

      return (response as List<dynamic>).map((data) {
        return Health(
          bp: data['user_bp']?.toString() ?? 'N/A',
          weight: data['user_weight']?.toString() ?? 'N/A',
          sugar: data['user_bsugar']?.toString() ?? 'N/A',
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching health data: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return [];
    }
  }

  Future<List<PatientDetails>> fetchPatientDetailsData(int bookingId) async {
    try {
      final response = await supabase
          .from("tbl_pdetails")
          .select()
          .eq("booking_id", bookingId);

      return (response as List<dynamic>).map((data) {
        return PatientDetails(
          history: data['user_history']?.toString(),
          conditions: data['user_condition']?.toString(),
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching patient details: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return [];
    }
  }

  void showHealthDetailsDialog(BuildContext context, Map<String, dynamic> patient, int bookingId) async {
    final healthRecords = await fetchHealthData(bookingId);
    final detailsRecords = await fetchPatientDetailsData(bookingId);
    final latestHealth = healthRecords.isNotEmpty ? healthRecords.last : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "${patient['user_name'] ?? 'Unknown'}'s Health Details",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (latestHealth == null && detailsRecords.isEmpty)
                Text(
                  "No health or pregnancy data available.",
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
                )
              else ...[
                if (latestHealth != null) ...[
                  Text(
                    "Health Information",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow("Blood Pressure", latestHealth.bp, Icons.favorite, Colors.purple.shade700),
                        _buildDetailRow("Weight", "${latestHealth.weight} kg", Icons.scale, Colors.purple.shade700),
                        _buildDetailRow("Blood Sugar", "${latestHealth.sugar} mg/dL", Icons.water_drop, Colors.purple.shade700),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  "Pregnancy History",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: detailsRecords.isEmpty
                      ? Text(
                          "No pregnancy history available.",
                          style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: detailsRecords.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final details = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Record $index",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    "Pregnancy History",
                                    details.history ?? 'Not provided',
                                    Icons.history,
                                    Colors.purple.shade700,
                                  ),
                                  _buildDetailRow(
                                    "Known Conditions",
                                    details.conditions ?? 'Not provided',
                                    Icons.health_and_safety,
                                    Colors.purple.shade700,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.nunito(color: Colors.purple.shade700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPreviousPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: Text(
          "Previous Patients",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : previousPatients.isEmpty
                ? Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No previous patients found.",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: previousPatients.length,
                    itemBuilder: (context, index) {
                      final patient = previousPatients[index]['tbl_user'];
                      final booking = previousPatients[index];
                      return _buildPatientCard(patient, booking);
                    },
                  ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.purple.shade100.withOpacity(0.9),
              child: Icon(
                Icons.pregnant_woman,
                color: Colors.purple.shade700,
                size: 35,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['user_name'] ?? 'Unknown',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.cake, "DOB: ${patient['user_dob'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.calendar_today, "Due: ${patient['user_pdate'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.phone, "Contact: ${patient['user_contact'] ?? 'N/A'}"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.description, color: Colors.purple.shade700),
              tooltip: "View Health Details",
              onPressed: () {
                showHealthDetailsDialog(context, patient, booking['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.purple.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}