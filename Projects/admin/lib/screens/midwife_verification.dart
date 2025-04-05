import 'dart:typed_data';

import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MidwifeVerify extends StatefulWidget {
  const MidwifeVerify({super.key});

  @override
  State<MidwifeVerify> createState() => _MidwifeVerifyState();
}

class _MidwifeVerifyState extends State<MidwifeVerify> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _midwives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchMidwife();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchMidwife() async {
    try {
      final response = await supabase.from("tbl_midwife").select(
          "id, midwife_name, midwife_email, midwife_address, midwife_gender, midwife_about, midwife_photo, midwife_status, midwife_licence");
      print("Midwife data fetched: $response");
      setState(() {
        _midwives = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching midwife: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching midwife: $e')),
      );
    }
  }

  Future<void> approveMidwife(String midwifeId) async {
    try {
      await supabase.from('tbl_midwife').update({'midwife_status': 1}).eq('id', midwifeId);
      fetchMidwife();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Midwife Approved!")));
    } catch (e) {
      print("Error approving midwife: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to approve midwife.")));
    }
  }

  Future<void> rejectMidwife(String midwifeId) async {
    try {
      await supabase.from('tbl_midwife').update({'midwife_status': 2}).eq('id', midwifeId);
      fetchMidwife();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Midwife Rejected!")));
    } catch (e) {
      print("Error rejecting midwife: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to reject midwife.")));
    }
  }

  List<Map<String, dynamic>> getFilteredMidwives(int status) {
    return _midwives.where((midwife) => (midwife['midwife_status'] ?? 0) == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Midwife Verification"),
        backgroundColor: const Color.fromARGB(255, 182, 152, 251),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Accepted"),
            Tab(text: "Rejected"),
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
                MidwifeList(
                  midwives: getFilteredMidwives(0),
                  showActions: true,
                  onApprove: approveMidwife,
                  onReject: rejectMidwife,
                ),
                MidwifeList(
                  midwives: getFilteredMidwives(1),
                  showActions: false,
                  onApprove: approveMidwife,
                  onReject: rejectMidwife,
                ),
                MidwifeList(
                  midwives: getFilteredMidwives(2),
                  showActions: false,
                  onApprove: approveMidwife,
                  onReject: rejectMidwife,
                ),
              ],
            ),
    );
  }
}

// Midwife list widget
class MidwifeList extends StatelessWidget {
  final List<Map<String, dynamic>> midwives;
  final bool showActions;
  final Function(String) onApprove;
  final Function(String) onReject;

  const MidwifeList({
    super.key,
    required this.midwives,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await (context.findAncestorStateOfType<_MidwifeVerifyState>())?.fetchMidwife();
      },
      color: const Color(0xFFD81B60),
      child: midwives.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 70,
                    color: Color(0xFFECEFF1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No midwives found",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      color: Color(0xFFECEFF1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Check back later!",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Color(0xFFECEFF1),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: midwives.length,
              itemBuilder: (context, index) {
                final midwife = midwives[index];
                return MidwifeCard(
                  midwife: midwife,
                  showActions: showActions,
                  onApprove: () => onApprove(midwife['id'].toString()),
                  onReject: () => onReject(midwife['id'].toString()),
                );
              },
            ),
    );
  }
}

// Midwife card widget
class MidwifeCard extends StatelessWidget {
  final Map<String, dynamic> midwife;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const MidwifeCard({
    super.key,
    required this.midwife,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = midwife['midwife_photo'];
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
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple.shade100.withOpacity(0.9),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          midwife['midwife_name']?[0] ?? 'M',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            color: Colors.purple.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Midwife: ${midwife['midwife_name'] ?? 'N/A'}",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Email: ${midwife['midwife_email'] ?? 'N/A'}",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Address: ${midwife['midwife_address'] ?? 'N/A'}",
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              "Gender: ${midwife['midwife_gender'] ?? 'N/A'}",
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              "About: ${midwife['midwife_about'] ?? 'N/A'}",
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showActions) ...[
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 194, 170, 250),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 194, 170, 250),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MidwifeDetailsDialog(midwife: midwife),
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

// Midwife details dialog with file viewing
class MidwifeDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> midwife;

  const MidwifeDetailsDialog({super.key, required this.midwife});

  @override
  State<MidwifeDetailsDialog> createState() => _MidwifeDetailsDialogState();
}

class _MidwifeDetailsDialogState extends State<MidwifeDetailsDialog> {
  bool _isLoadingFile = false;
  Uint8List? _fileBytes; // To store the file content
  String? _fileUrl; // To store the signed URL

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadFile() async {
    final licencePath = widget.midwife['midwife_licence'];
    if (licencePath == null || licencePath.isEmpty) return;

    setState(() => _isLoadingFile = true);
    try {
      // Fetch the file from Supabase Storage
      final response = await supabase.storage.from('midwife').download(licencePath);
      setState(() {
        _fileBytes = response;
        _isLoadingFile = false;
      });

      // Optionally generate a signed URL for viewing (e.g., in a browser or external app)
      final signedUrl = await supabase.storage.from('midwife').createSignedUrl(licencePath, 60); // 60 seconds validity
      setState(() => _fileUrl = signedUrl);
    } catch (e) {
      print("Error loading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load licence file: $e")),
      );
      setState(() => _isLoadingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFF263238),
      title: const Text(
        "Midwife Details",
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
              "Midwife ID: ${widget.midwife['id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Name: ${widget.midwife['midwife_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Email: ${widget.midwife['midwife_email'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Address: ${widget.midwife['midwife_address'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Gender: ${widget.midwife['midwife_gender'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "About: ${widget.midwife['midwife_about'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Licence:",
              style: TextStyle(fontSize: 16, color: Color(0xFFECEFF1), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // _isLoadingFile
            //     ? const Center(
            //         child: CircularProgressIndicator(
            //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)),
            //         ),
            //       ) :
                 widget.midwife['midwife_licence'] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display if it's an image
                          if (widget.midwife['midwife_licence']?.toLowerCase().endsWith('.png') == true ||
                              widget.midwife['midwife_licence']?.toLowerCase().endsWith('.jpg') == true ||
                              widget.midwife['midwife_licence']?.toLowerCase().endsWith('.jpeg') == true)
                            Image.network(
                              widget.midwife['midwife_licence']!,
                              height: 200,
                              fit: BoxFit.contain,
                            )
                          else
                            // For non-image files (e.g., PDF), show a message or download option
                            Text(
                              "File available (${widget.midwife['midwife_licence'].split('/').last})",
                              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
                            ),
                          if (_fileUrl != null)
                            TextButton(
                              onPressed: () {
                                // Open the signed URL in a browser or external app
                                // Requires url_launcher package
                                // launch(_fileUrl!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("URL launch not implemented. Use url_launcher.")),
                                );
                              },
                              child: const Text(
                                "Open File",
                                style: TextStyle(color: Color(0xFFD81B60)),
                              ),
                            ),
                        ],
                      )
                    : Text(
                        "No licence file available",
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