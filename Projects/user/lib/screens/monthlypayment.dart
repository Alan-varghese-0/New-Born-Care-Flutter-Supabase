import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:intl/intl.dart'; // Add this import

class Monthlypayment extends StatefulWidget {
  final int bookingID;
  const Monthlypayment({super.key, required this.bookingID});

  @override
  State<Monthlypayment> createState() => _MonthlypaymentState();
}

class _MonthlypaymentState extends State<Monthlypayment> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  // Fetch monthly payments from the database
  Future<void> fetchMonthlyPayments() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("No authenticated user");
      final response = await supabase
          .from("tbl_payment")
          .select("*")
          .eq('booking_id', widget.bookingID)
          .eq('payment_status', 1)
          .order('created_at', ascending: false);
      setState(() {
        _payments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching monthly payments: $e', style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: Colors.pink.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMonthlyPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(
          "Monthly Payments",
          style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade800,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade800),
              ),
            )
          : _payments.isEmpty
              ? Center(
                  child: Text(
                    "No payments found",
                    style: GoogleFonts.nunito(fontSize: 20, color: Colors.purple.shade800),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    // Format the timestampz date
                    final createdAt = payment['created_at'];
                    String formattedDate = '';
                    if (createdAt != null) {
                      final dateTime = DateTime.parse(createdAt);
                      formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount: \$${payment['payment_amount']}",
                              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date: $formattedDate",
                              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                             payment['payment_status'] == 1 ? "Status: Paid" : "Status: Unpaid",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: payment['payment_status'] == 1
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}