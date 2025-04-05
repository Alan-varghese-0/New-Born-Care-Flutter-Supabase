import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  // Fetch bookings from tbl_booking for the current user
  Future<void> fetchBookings() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from("tbl_booking")
          .select("*, tbl_user(*), tbl_midwife(*)")
          .eq('user_id', userId); // Filter by current user
      print("Bookings data fetched: $response");

      setState(() {
        _bookings = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Soft pink background from Home
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Matching Home gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "My Midwife Bookings",
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade800),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchBookings,
              color: Colors.purple.shade800, // Matching theme color
              child: _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border, // Heart icon for pregnancy theme
                            size: 70,
                            color: Colors.purple.shade200,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No bookings yet",
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Book a midwife to start your journey!",
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
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        return BookingCard(booking: booking);
                      },
                    ),
            ),
    );
  }
}

// Booking card widget
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Get the midwife photo URL from tbl_midwife
    final String? photoUrl = booking['tbl_midwife']?['midwife_photo'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withOpacity(0.5), // Soft pink shadow
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
                children: [
                  CircleAvatar(
                    radius: 40, // Reduced size for better layout
                    backgroundColor: Colors.purple.shade100.withOpacity(0.9), // Subtle purple tint
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null, // Use photo if available
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(
                            booking['tbl_midwife']?['midwife_name']?[0] ?? 'M',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null, // Fallback to initial if no photo
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Midwife: ${booking['tbl_midwife']?['midwife_name'] ?? 'N/A'}",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Email: ${booking['tbl_midwife']?['midwife_email'] ?? 'N/A'}",
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
                "Address: ${booking['tbl_midwife']?['midwife_address'] ?? 'N/A'}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "Gender: ${booking['tbl_midwife']?['midwife_gender'] ?? 'N/A'}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "About: ${booking['tbl_midwife']?['midwife_about'] ?? 'N/A'}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "From: ${booking['booking_fromdate'] ?? 'N/A'}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "To: ${booking['booking_enddate'] ?? 'N/A'}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}