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
    _tabController = TabController(length: 4, vsync: this);
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
      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching bookings: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFD81B60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> approveBooking(String bookingId, String mid) async {
    try {
      final TextEditingController amountController = TextEditingController();
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Color(0xFF263238),
          title: Text("Set Booking Amount", style: TextStyle(color: Color(0xFFECEFF1), fontWeight: FontWeight.bold)),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Color(0xFFECEFF1)),
            decoration: InputDecoration(
              labelText: "Booking Amount",
              labelStyle: TextStyle(color: Color(0xFFECEFF1)),
              hintText: "Enter amount",
              hintStyle: TextStyle(color: Color(0xFFECEFF1).withOpacity(0.7)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFFD81B60), width: 2)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: TextStyle(color: Color(0xFFD81B60)))),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter valid amount"), backgroundColor: Color(0xFFD81B60)));
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 194, 170, 250)),
              child: Text("Confirm", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
      if (confirmed != true) return;

      final amount = double.parse(amountController.text);
      await Future.wait([
        supabase.from('tbl_booking').update({'booking_status': 1, 'booking_amount': amount}).eq('id', bookingId),
        supabase.from('tbl_midwife').update({'midwife_available': 0}).eq('id', mid),
      ]);
      await fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Approved"), backgroundColor: Color.fromARGB(255, 194, 170, 250)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Color(0xFFD81B60)));
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await supabase.from('tbl_booking').update({'booking_status': 2}).eq('id', bookingId);
      await fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Rejected"), backgroundColor: Color.fromARGB(255, 194, 170, 250)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Color(0xFFD81B60)));
    }
  }

  List<Map<String, dynamic>> getFilteredBookings(int status) {
    return _bookings.where((b) => b['booking_status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Bookings"),
        backgroundColor: Color.fromARGB(255, 182, 152, 251),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Paid"),
            Tab(text: "Rejected"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFD81B60))))
          : TabBarView(
              controller: _tabController,
              children: [
                BookingList(bookings: getFilteredBookings(0), showActions: true, onApprove: approveBooking, onReject: rejectBooking),
                BookingList(bookings: getFilteredBookings(3), showActions: false, onApprove: approveBooking, onReject: rejectBooking),
                BookingList(bookings: getFilteredBookings(2), showActions: false, onApprove: approveBooking, onReject: rejectBooking),
                BookingList(bookings: getFilteredBookings(5), showActions: false, onApprove: approveBooking, onReject: rejectBooking),
              ],
            ),
    );
  }
}

class BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final bool showActions;
  final Function(String, String) onApprove;
  final Function(String) onReject;

  const BookingList({super.key, required this.bookings, required this.showActions, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await (context.findAncestorStateOfType<_AdminBookingsScreenState>())?.fetchBookings();
      },
      color: Color(0xFFD81B60),
      child: bookings.isEmpty
          ? Center(child: Text("No bookings found", style: TextStyle(color: Color(0xFFECEFF1), fontSize: 18)))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  showActions: showActions,
                  onApprove: () => onApprove(booking['id'].toString(), booking['midwife_id'].toString()),
                  onReject: () => onReject(booking['id'].toString()),
                );
              },
            ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const BookingCard({super.key, required this.booking, required this.showActions, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final status = booking['booking_status'] ?? 0;
    final amount = booking['booking_amount'] != null ? double.tryParse(booking['booking_amount'].toString()) : null;
    final statusText = ["New", "Accepted", "Rejected", "Paid", "User Rejected", "Cancelled"];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFF263238),
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking #NBCOD000${booking['id'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1), fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text("User: ${booking['tbl_user']?['user_name'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
            Text("Midwife: ${booking['tbl_midwife']?['midwife_name'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
            Text("From: ${booking['booking_fromdate'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
            Text("To: ${booking['booking_enddate'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
            Text("Status: ${statusText[status]}", style: TextStyle(color: Color(0xFFECEFF1))),
            if (status == 1 || status == 3)
              Text("Amount: ${amount != null ? '\$${amount.toStringAsFixed(2)}' : 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showActions) ...[
                  ElevatedButton(onPressed: onApprove, child: Text("Accept"), style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 194, 170, 250))),
                  SizedBox(width: 8),
                  ElevatedButton(onPressed: onReject, child: Text("Reject"), style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 194, 170, 250))),
                ],
                TextButton(
                  onPressed: () => showDialog(context: context, builder: (_) => BookingDetailsDialog(booking: booking)),
                  child: Text("View Details", style: TextStyle(color: Color(0xFFD81B60))),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BookingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking['booking_status'] ?? 0;
    final amount = booking['booking_amount'] != null ? double.tryParse(booking['booking_amount'].toString()) : null;
    final statusText = ["New", "Accepted", "Rejected", "Paid", "User Rejected", "Cancelled"];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color(0xFF263238),
      title: Text("Booking Details", style: TextStyle(color: Color(0xFFECEFF1), fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Booking ID: ${booking['id']}", style: TextStyle(color: Color(0xFFECEFF1))),
          Text("User: ${booking['tbl_user']?['user_name'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
          Text("Midwife: ${booking['tbl_midwife']?['midwife_name'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
          Text("From: ${booking['booking_fromdate'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
          Text("To: ${booking['booking_enddate'] ?? 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
          Text("Status: ${statusText[status]}", style: TextStyle(color: Color(0xFFECEFF1))),
          if (status == 1 || status == 3)
            Text("Amount: ${amount != null ? '\$${amount.toStringAsFixed(2)}' : 'N/A'}", style: TextStyle(color: Color(0xFFECEFF1))),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close", style: TextStyle(color: Color(0xFFD81B60))),
        ),
      ],
    );
  }
}
