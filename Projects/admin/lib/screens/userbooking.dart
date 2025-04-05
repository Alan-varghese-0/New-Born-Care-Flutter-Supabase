import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchBookings() async {
    try {
      final response = await supabase.from("tbl_booking").select("*, tbl_user(*), tbl_midwife(*)");
      print("Bookings data fetched: $response");
      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
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

  Future<void> approveBooking(String bookingId, String mid) async {
    try {
      await supabase.from('tbl_booking').update({'booking_status': 1}).eq('id', bookingId);
await Future.wait([
      // Update booking status to approved (1)
      supabase
          .from('tbl_booking')
          .update({'booking_status': 1})
          .eq('id', bookingId),
      
      // Update midwife to unavailable (1) since booking is approved
      supabase
          .from('tbl_midwife')
          .update({'midwife_available': 0})  // Changed from 0 to 1
          .eq('id', mid),
    ]);      fetchBookings(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Approved!")));
    } catch (e) {
      print("Error approving booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to approve booking.")));
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await supabase.from('tbl_booking').update({'booking_status': 2}).eq('id', bookingId);
      fetchBookings(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Rejected!")));
    } catch (e) {
      print("Error rejecting booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to reject booking.")));
    }
  }

  List<Map<String, dynamic>> getFilteredBookings(int status) {
    return _bookings.where((booking) => (booking['booking_status'] ?? 0) == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bookings"),
        backgroundColor: const Color.fromARGB(255, 182, 152, 251), // Purple from previous design
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
                // New Bookings (status = 0)
                BookingList(
                  bookings: getFilteredBookings(0),
                  showActions: true, // Show Accept/Reject for new bookings
                  onApprove: approveBooking,
                  onReject: rejectBooking,
                ),
                // Accepted Bookings (status = 1)
                BookingList(
                  bookings: getFilteredBookings(1),
                  showActions: false, // No actions for accepted
                  onApprove: approveBooking,
                  onReject: rejectBooking,
                ),
                // Rejected Bookings (status = 2)
                BookingList(
                  bookings: getFilteredBookings(2),
                  showActions: false, // No actions for rejected
                  onApprove: approveBooking,
                  onReject: rejectBooking,
                ),
              ],
            ),
    );
  }
}

// Booking list widget
class BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final bool showActions;
  final Function(String, String) onApprove;
  final Function(String) onReject;

  const BookingList({
    super.key,
    required this.bookings,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await (context.findAncestorStateOfType<_AdminBookingsScreenState>())?.fetchBookings();
      },
      color: const Color(0xFFD81B60), // Deep Pink
      child: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 70,
                    color: Color(0xFFECEFF1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No bookings found",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFECEFF1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Check back later!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFECEFF1),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  showActions: showActions,
                  onApprove: () => onApprove(booking['id'].toString(),booking['midwife_id'].toString()),
                  onReject: () => onReject(booking['id'].toString()),
                );
              },
            ),
    );
  }
}

// Booking card widget
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const BookingCard({
    super.key,
    required this.booking,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF263238), // Dark Grayish Blue
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking #NBCOD000${booking['id'] ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFECEFF1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "User: ${booking['tbl_user']?['user_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "Midwife: ${booking['tbl_midwife']?['midwife_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "From: ${booking['booking_fromdate'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            Text(
              "To: ${booking['booking_enddate'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
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
                      builder: (context) => BookingDetailsDialog(booking: booking),
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

// Booking details dialog
class BookingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFF263238),
      title: const Text(
        "Booking Details",
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
              "Booking ID: ${booking['id'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "User: ${booking['tbl_user']?['user_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "Midwife: ${booking['tbl_midwife']?['midwife_name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "From Date: ${booking['booking_fromdate'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Color(0xFFECEFF1)),
            ),
            const SizedBox(height: 8),
            Text(
              "End Date: ${booking['booking_enddate'] ?? 'N/A'}",
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