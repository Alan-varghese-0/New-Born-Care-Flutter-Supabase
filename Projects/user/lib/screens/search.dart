import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/servicedate.dart';

// Midwife model class
class Midwife {
  final String id;
  final String name;
  final String location;
  final String bio;
  final String contact;
  final String photo;
  final int status; // Added midwife_status
  final int availability; // midwife_available

  Midwife({
    required this.id,
    required this.name,
    required this.location,
    required this.bio,
    required this.contact,
    required this.photo,
    int? status,
    int? availability,
  })  : status = status ?? 0, // Default to 0 (inactive) if null
        availability = availability ?? 0; // Default to 0 (unavailable) if null
}

class MidwifeListScreen extends StatefulWidget {
  const MidwifeListScreen({super.key});

  @override
  State<MidwifeListScreen> createState() => _MidwifeListScreenState();
}

class _MidwifeListScreenState extends State<MidwifeListScreen> {
  List<Midwife> _midwives = [];
  bool _isLoading = true;

  Future<void> fetchUser() async {
    try {
      // Fetch midwives where midwife_status = 1
      final response = await supabase
          .from("tbl_midwife")
          .select()
          .eq("midwife_status", 1); // Filter for active midwives only

      print("Midwives data fetched: $response");

      setState(() {
        _midwives = (response as List<dynamic>).map((data) {
          return Midwife(
            id: data['id']?.toString() ?? '',
            name: data['midwife_name'] ?? 'Unknown',
            location: data['midwife_address'] ?? 'No location',
            bio: data['midwife_about'] ?? 'No bio',
            contact: data['midwife_contact'] ?? 'No contact',
            photo: data['midwife_photo'] ?? 'https://via.placeholder.com/150',
            status: data['midwife_status'],
            availability: data['midwife_available'],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching midwives: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching midwives: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Find a Midwife",
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUser,
              child: _midwives.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline,
                              size: 70, color: Colors.pink.shade200),
                          const SizedBox(height: 20),
                          Text(
                            "No active midwives found",
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Check back later!",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.pink.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _midwives.length,
                      itemBuilder: (context, index) {
                        return MidwifeCard(midwife: _midwives[index]);
                      },
                    ),
            ),
    );
  }
}

class MidwifeCard extends StatelessWidget {
  final Midwife midwife;

  const MidwifeCard({super.key, required this.midwife});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(midwife.photo),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // Green if available (1), red if unavailable (0)
                      color: midwife.availability == 1 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      midwife.availability == 1 ? "Available" : "Unavailable",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                midwife.name,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Location: ${midwife.location}",
                style: GoogleFonts.nunito(
                    fontSize: 16, color: Colors.grey.shade600),
              ),
              Text(
                "About: ${midwife.bio}",
                style: GoogleFonts.nunito(
                    fontSize: 16, color: Colors.grey.shade600),
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
              ),
              Text(
                "Contact: ${midwife.contact}",
                style: GoogleFonts.nunito(
                    fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            MidwifeDetailsDialog(midwife: midwife),
                      );
                    },
                    child: Text(
                      "View Details",
                      style: GoogleFonts.nunito(
                        color: Colors.purple.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: midwife.availability == 1
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Fromdate(midwifeId: midwife.id),
                              ),
                            );
                          }
                        : null, // Disable button if unavailable (0)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: Text(
                      "Book Now",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MidwifeDetailsDialog extends StatelessWidget {
  final Midwife midwife;

  const MidwifeDetailsDialog({super.key, required this.midwife});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: CircleAvatar(
        radius: 75,
        backgroundImage: NetworkImage(midwife.photo),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              midwife.name,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Location: ${midwife.location}",
              style:
                  GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "About: ${midwife.bio}",
              style:
                  GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
            ),
            const SizedBox(height: 8),
            Text(
              "Contact: ${midwife.contact}",
              style:
                  GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${midwife.availability == 1 ? 'Available' : 'Unavailable'}",
              style:
                  GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: GoogleFonts.nunito(
              color: Colors.purple.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}