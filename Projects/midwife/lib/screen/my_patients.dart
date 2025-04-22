import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';

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

class PatientDetails {
  final String? history;
  final String? conditions;

  PatientDetails({
    this.history,
    this.conditions,
  });
}

class AssignedPatientDetails extends StatefulWidget {
  const AssignedPatientDetails({super.key});

  @override
  State<AssignedPatientDetails> createState() => _AssignedPatientDetailsState();
}

class _AssignedPatientDetailsState extends State<AssignedPatientDetails> {
  List<dynamic> patients = [];
  Map<int, List<Health>> healthData = {};
  Map<int, List<PatientDetails>> patientDetailsData = {};
  bool isLoading = true;
  bool isEditingHealth = false;
  bool isEditingHistory = false;

  // Controllers for health info
  final _bpController = TextEditingController();
  final _weightController = TextEditingController();
  final _sugarController = TextEditingController();

  // Controllers for pregnancy history
  final _historyController = TextEditingController();
  final _conditionsController = TextEditingController();

  Future<void> fetchPatients() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final List<dynamic> response = await supabase
          .from("tbl_booking")
          .select("*, tbl_user(*)")
          .eq("midwife_id", userId)
          .eq("booking_status", 3);

      setState(() {
        patients = response;
        isLoading = false;
      });

      for (var patient in patients) {
        await fetchHealthData(patient['id']);
        await fetchPatientDetailsData(patient['id']);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading patient data: $e")),
      );
    }
  }

  Future<void> fetchHealthData(int bookingId) async {
    try {
      final response = await supabase
          .from("tbl_health")
          .select()
          .eq("booking_id", bookingId);

      setState(() {
        healthData[bookingId] = (response as List<dynamic>).map((data) {
          return Health(
            bp: data['user_bp']?.toString() ?? 'N/A',
            weight: data['user_weight']?.toString() ?? 'N/A',
            sugar: data['user_bsugar']?.toString() ?? 'N/A',
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching health data for booking $bookingId: $e");
      setState(() {
        healthData[bookingId] = [];
      });
    }
  }

  Future<void> fetchPatientDetailsData(int bookingId) async {
    try {
      final response = await supabase
          .from("tbl_pdetails")
          .select()
          .eq("booking_id", bookingId);

      setState(() {
        patientDetailsData[bookingId] = (response as List<dynamic>).map((data) {
          return PatientDetails(
            history: data['user_history']?.toString(),
            conditions: data['user_conditions']?.toString(),
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching patient details for booking $bookingId: $e");
      setState(() {
        patientDetailsData[bookingId] = [];
      });
    }
  }

  Future<void> updateHealthInfo(int bookingId) async {
    try {
      await supabase.from('tbl_health').insert({
        'booking_id': bookingId,
        'user_bp': _bpController.text,
        'user_weight': _weightController.text,
        'user_bsugar': _sugarController.text,
      });
      await fetchHealthData(bookingId);
      setState(() => isEditingHealth = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Health info inserted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inserting health info: $e")),
      );
    }
  }

  Future<void> updatePregnancyHistory(int bookingId) async {
    try {
      await supabase.from('tbl_pdetails').insert({
        'booking_id': bookingId,
        'user_history': _historyController.text,
        'user_condition': _conditionsController.text,
      });
      await fetchPatientDetailsData(bookingId);
      setState(() => isEditingHistory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pregnancy history inserted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inserting pregnancy history: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  @override
  void dispose() {
    _bpController.dispose();
    _weightController.dispose();
    _sugarController.dispose();
    _historyController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: Text(
          "Assigned Patients",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : patients.isEmpty
                ? Center(
                    child: Text(
                      "No assigned patients with confirmed bookings found",
                      style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index]['tbl_user'];
                      final booking = patients[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(patient),
                          const SizedBox(height: 25),
                          _buildSectionTitle("Health Information"),
                          const SizedBox(height: 10),
                          _buildHealthInfo(booking),
                          const SizedBox(height: 25),
                          _buildSectionTitle("Pregnancy History"),
                          const SizedBox(height: 10),
                          _buildPregnancyHistory(booking),
                          const SizedBox(height: 25),
                        ],
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> patient) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.purple.shade100.withOpacity(0.9),
              child: Icon(Icons.pregnant_woman, color: Colors.purple.shade700, size: 35),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['user_name'] ?? 'Unknown',
                    style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.cake, "Date of birth: ${patient['user_dob'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.water_drop, "Blood: ${patient['user_btype'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.calendar_today, "Due date: ${patient['user_pdate'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.phone, "Contact: ${patient['user_contact'] ?? 'N/A'}"),
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
          Icon(icon, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.bookmark, color: Colors.purple.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInfo(Map<String, dynamic> booking) {
    final healthRecords = healthData[booking['id']] ?? [];
    final latestHealth = healthRecords.isNotEmpty ? healthRecords.last : null;

    if (isEditingHealth) {
      _bpController.text = latestHealth?.bp ?? '';
      _weightController.text = latestHealth?.weight ?? '';
      _sugarController.text = latestHealth?.sugar ?? '';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            TextField(
              controller: _bpController,
              decoration: const InputDecoration(labelText: "Blood Pressure"),
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _sugarController,
              decoration: const InputDecoration(labelText: "Blood Sugar (mg/dL)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => isEditingHealth = false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => updateHealthInfo(booking['id']),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Blood Pressure", latestHealth?.bp ?? 'N/A', Icons.favorite, Colors.red.shade400),
            _buildDetailRow("Weight", "${latestHealth?.weight ?? 'N/A'} kg", Icons.scale, Colors.purple.shade700),
            _buildDetailRow("Blood Sugar", "${latestHealth?.sugar ?? 'N/A'} mg/dL", Icons.water_drop, Colors.teal.shade400),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.purple.shade700),
                onPressed: () => setState(() => isEditingHealth = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyHistory(Map<String, dynamic> booking) {
    final detailsRecords = patientDetailsData[booking['id']] ?? [];
    final latestDetails = detailsRecords.isNotEmpty ? detailsRecords.last : null;

    if (isEditingHistory) {
      _historyController.text = latestDetails?.history ?? '';
      _conditionsController.text = latestDetails?.conditions ?? '';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Pregnancy History",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _historyController,
              decoration: InputDecoration(
                labelText: "Pregnancy History",
                labelStyle: GoogleFonts.nunito(color: Colors.purple.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade700, width: 2),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _conditionsController,
              decoration: InputDecoration(
                labelText: "Known Conditions",
                labelStyle: GoogleFonts.nunito(color: Colors.purple.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade700, width: 2),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => isEditingHistory = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => updatePregnancyHistory(booking['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Save",
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                "Pregnancy History",
                latestDetails?.history ?? 'N/A',
                Icons.history,
                Colors.purple.shade600,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                "Known Conditions",
                latestDetails?.conditions ?? 'N/A',
                Icons.health_and_safety,
                Colors.purple.shade600,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: FloatingActionButton(
              onPressed: () => setState(() => isEditingHistory = true),
              mini: true,
              backgroundColor: Colors.purple.shade700,
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
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
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                color: Colors.purple.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 44), // Align with icon
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}