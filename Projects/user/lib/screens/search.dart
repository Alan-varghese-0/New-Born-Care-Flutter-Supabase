import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart'; // Ensure supabase is defined here

// Midwife model class
class Midwife {
  final String name;
  final String location;
  final String bio;
  final String contact;

  Midwife({
    required this.name,
    required this.location,
    required this.bio,
    required this.contact,
  });
}

// Main screen
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
      final response = await supabase.from("tbl_midwife").select();
      print("Midwives data fetched: $response");

      setState(() {
        _midwives = (response as List<dynamic>).map((data) {
          print(data['midwife_about']);
          return Midwife(
            name: data['midwife_name'],
            location: data['midwife_address'],
            bio: data['midwife_about'],
            contact: data['midwife_contact'],
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
      backgroundColor: Colors.pink.shade50, // Match Forum background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Match Forum gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Find a Midwife",
          style: GoogleFonts.pacifico( // Match Forum title style
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), // Match Forum back button
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
                          Icon(Icons.person_outline, size: 70, color: Colors.pink.shade200), // Match Forum empty state style
                          const SizedBox(height: 20),
                          Text(
                            "No midwives found",
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

// Midwife card widget
class MidwifeCard extends StatelessWidget {
  final Midwife midwife;

  const MidwifeCard({super.key, required this.midwife});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Match Forum card elevation
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Match Forum card shape
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
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
                  Text(
                    midwife.name,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600, // Adjusted to match theme
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green, // Static for now, adjust if dynamic
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Available",
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
                "Location: ${midwife.location}",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600), // Match Forum subtitle
              ),
              Text(
                "About: ${midwife.bio}",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
              ),
              Text(
                "Contact: ${midwife.contact}",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => MidwifeDetailsDialog(midwife: midwife),
                      );
                    },
                    child: Text(
                      "View Details",
                      style: GoogleFonts.nunito(
                        color: Colors.purple.shade600, // Match theme
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Booking ${midwife.name}...")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300, // Match Forum button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// Details dialog
class MidwifeDetailsDialog extends StatelessWidget {
  final Midwife midwife;

  const MidwifeDetailsDialog({super.key, required this.midwife});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Match card shape
      backgroundColor: Colors.white,
      title: Text(
        midwife.name,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.purple.shade600, // Match theme
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Location: ${midwife.location}",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600), // Match Forum text
            ),
            const SizedBox(height: 8),
            Text(
              "About: ${midwife.bio}",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Contact: ${midwife.contact}",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: Available", // Static for now
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
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
              color: Colors.purple.shade600, // Match theme
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}