import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/monthlypayment.dart';
import 'package:user/screens/payment/payment.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("No authenticated user");
      final response = await supabase
          .from("tbl_booking")
          .select("*, tbl_user(*), tbl_midwife(*)")
          .eq('user_id', userId);
      print("Bookings data fetched: $response");

      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      // Show payment popup for approved bookings
      for (var booking in _bookings) {
        // Show initial payment popup for approved bookings (status == 1)
        if (booking['booking_status'] == 1) {
          showPaymentDialog(booking['id'], booking['booking_amount']);
          break; // Only one popup at a time
        }

        // Show monthly payment popup for active bookings (status == 3)
        if (booking['booking_status'] == 3) {
          final fromDate = DateTime.tryParse(booking['booking_fromdate'] ?? '');
          final endDate = booking['booking_enddate'] != null
              ? DateTime.tryParse(booking['booking_enddate'])
              : null;
          if (fromDate == null) continue;

          final now = DateTime.now();
          // Only show popup if booking is active for this month
          final isActive = (now.isAfter(fromDate) || now.isAtSameMomentAs(fromDate)) &&
              (endDate == null || now.isBefore(endDate) || now.isAtSameMomentAs(endDate));

          if (isActive) {
            // Use booking_fromdate's month and year for the first payment
            int paymentMonth = now.month;
            int paymentYear = now.year;

            // If you want to always use booking_fromdate's month/year for the first payment:
            if (now.year == fromDate.year && now.month == fromDate.month) {
              paymentMonth = fromDate.month;
              paymentYear = fromDate.year;
            }

            // Check if payment for this month exists (using created_at if you don't have payment_month/year columns)
            final startOfMonth = DateTime(paymentYear, paymentMonth, 1);
            final startOfNextMonth = DateTime(paymentMonth == 12 ? paymentYear + 1 : paymentYear, paymentMonth == 12 ? 1 : paymentMonth + 1, 1);

            final paymentResponse = await supabase
                .from('tbl_payment')
                .select()
                .eq('booking_id', booking['id'])
                .gte('created_at', startOfMonth.toIso8601String())
                .lt('created_at', startOfNextMonth.toIso8601String())
                .maybeSingle();

            if (paymentResponse == null || paymentResponse['payment_status'] != 1) {
              showPaymentDialog(booking['id'], booking['booking_amount'], isMonthly: true);
              break; // Only one popup at a time
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching bookings: $e', style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: Colors.pink.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> showPaymentDialog(int bookingId, int amount, {bool isMonthly = false}) async {
    final bool? action = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          isMonthly ? "Monthly Payment Required" : "Payment Required",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
        content: Text(
          isMonthly
              ? "Your monthly payment of \$${amount.toStringAsFixed(2)} is due for this booking. Please pay to continue the service."
              : "Your booking has been approved. Please make a payment of \$${amount.toStringAsFixed(2)} to proceed.",
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await supabase.from('tbl_booking').update({
                  'booking_status': 4,
                }).eq('id', bookingId);
                await fetchBookings();
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Booking rejected", style: GoogleFonts.nunito(color: Colors.white)),
                    backgroundColor: Colors.pink.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } catch (e) {
                print("Error rejecting booking: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error rejecting booking: $e", style: GoogleFonts.nunito(color: Colors.white)),
                    backgroundColor: Colors.pink.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(
              "Reject",
              style: GoogleFonts.nunito(color: Colors.red.shade600, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentGatewayScreen(id: bookingId, amt: amount,), // bookingId is String
        ),
      );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Continue",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );

  
  }

  Future<void> cancelBooking(String bookingId, String midwifeId) async {
  TextEditingController complaintController = TextEditingController();

  final bool? submitted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: Text(
        "Cancel Booking & Add Complaint",
        style: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Please let us know the reason for cancellation or any complaint you have.",
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: complaintController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter your complaint...",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            "Close",
            style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "Submit",
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  if (submitted == true) {
    try {
      // Update booking status to 5 (cancelled)
      await supabase.from('tbl_booking').update({
        'booking_status': 5,
        'booking_enddate': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      // Update midwife availability to 1 (available)
      await supabase.from('tbl_midwife').update({
        'midwife_available': 1,
      }).eq('id', midwifeId);

      // Optionally, insert complaint
      if (complaintController.text.trim().isNotEmpty) {
        await supabase.from('tbl_complaint').insert({
          'midwife_id': midwifeId,
          'booking_id': bookingId,
          'complaint': complaintController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking cancelled and complaint submitted.", style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: Colors.purple.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: Colors.pink.shade400,
        ),
      );
    }
  }
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
              color: Colors.purple.shade800,
              child: Column(
                children: [
                  Expanded(
                    child: _bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
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
                              return BookingCard(
                                booking: booking,
                                onCancel: () => cancelBooking(
                                  booking['id'].toString(),
                                  booking['tbl_midwife']?['id'],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onCancel;

  const BookingCard({super.key, required this.booking, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = booking['tbl_midwife']?['midwife_photo'];
    final status = booking['booking_status'] ?? 0;
    final bool isCancelled = status == 5;
    final bool isUserRejected = status == 4;
    final bool canViewDetails = status == 3 || status == 5 || status == 4;
    final bool showCancelButton = status == 0 || status == 1 || status == 3;
    final statusText = status == 0
        ? 'Pending'
        : status == 1
            ? 'Approved'
            : status == 2
                ? 'Rejected'
                : status == 3
                    ? 'Payment Pending'
                    : status == 4
                        ? 'User Rejected'
                        : 'Cancelled';
    final amount = double.tryParse(booking['booking_amount']?.toString() ?? '0') ?? 0;

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
              if (!canViewDetails)
                Text(
                  "Complete payment to view booking details",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (canViewDetails) ...[
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
                              booking['tbl_midwife']?['midwife_name']?[0] ?? 'M',
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
                    color: isCancelled || isUserRejected ? Colors.red.shade600 : Colors.grey.shade600,
                  ),
                ),
              ],
              Text(
                "Status: $statusText",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isCancelled || isUserRejected ? Colors.red.shade600 : Colors.grey.shade600,
                ),
              ),
              if (status == 3)
                Text(
                  "Amount: \$${amount.toStringAsFixed(2)}",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: showCancelButton && !isCancelled && !isUserRejected ? onCancel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isCancelled ? "Cancelled" : "Cancel Booking",
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Monthlypayment(bookingID: booking['id']) // Ensure String
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      status == 3 ? "view payments " : "Payments",
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
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