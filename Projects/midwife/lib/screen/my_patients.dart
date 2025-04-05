import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midwife/main.dart';

class Health {
  final String bp;
  final String weight;
  final String sugar;
  final String? history; // Added for pregnancy history
  final String? conditions; // Added for known conditions

  Health({
    required this.bp,
    required this.weight,
    required this.sugar,
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
  Map<int, List<Health>> healthData = {}; // Map booking ID to health records
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
          .eq("midwife_id", userId);

      setState(() {
        patients = response;
        isLoading = false;
      });

      // Fetch health data for each booking
      for (var patient in patients) {
        await fetchHealthData(patient['id']);
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
            history: data['user_history']?.toString(), // Populate history
            conditions: data['user_condition']?.toString(), // Populate conditions
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching health data for booking $bookingId: $e");
      setState(() {
        healthData[bookingId] = []; // Empty list on error
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
      await fetchHealthData(bookingId); // Refresh health data for this booking
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
      await supabase.from('tbl_health').update({
        'user_history': _historyController.text,
        'user_condition': _conditionsController.text,
      }).eq('booking_id', bookingId); // Use booking_id instead of id
      
      await fetchHealthData(bookingId); // Refresh health data
      setState(() => isEditingHistory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pregnancy history updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating pregnancy history: $e")),
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
                      "No assigned patients found",
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
                  _buildInfoRow(Icons.cake, "Age: ${patient['user_dob'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.water_drop, "blood: ${patient['user_btype'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.calendar_today, "Due: ${patient['user_pdate'] ?? 'N/A'}"),
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
    final healthRecords = healthData[booking['id']] ?? [];
    final latestHealth = healthRecords.isNotEmpty ? healthRecords.last : null;

    if (isEditingHistory) {
      _historyController.text = latestHealth?.history ?? '';
      _conditionsController.text = latestHealth?.conditions ?? '';
      
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
              controller: _historyController,
              decoration: const InputDecoration(labelText: "Pregnancy History"),
              maxLines: 3,
            ),
            TextField(
              controller: _conditionsController,
              decoration: const InputDecoration(labelText: "Known Conditions"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => isEditingHistory = false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => updatePregnancyHistory(booking['id']),
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
            _buildDetailRow("Pregnancy History", latestHealth?.history ?? 'N/A', Icons.history, Colors.grey.shade600),
            _buildDetailRow("Known Conditions", latestHealth?.conditions ?? 'N/A', Icons.health_and_safety, Colors.orange.shade400),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.purple.shade700),
                onPressed: () => setState(() => isEditingHistory = true),
              ),
            ),
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
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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

  
}