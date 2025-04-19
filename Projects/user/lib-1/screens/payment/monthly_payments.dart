import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';

class MonthlyPayments extends StatefulWidget {
  const MonthlyPayments({super.key});

  @override
  State<MonthlyPayments> createState() => _MonthlyPaymentsState();
}

class _MonthlyPaymentsState extends State<MonthlyPayments> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  // Fetch monthly payments from the database
  Future<void> fetchMonthlyPayments() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("No authenticated user");
      final response = await supabase
          .from("tbl_payments")
          .select("*")
          .eq('user_id', userId)
          .order('payment_date', ascending: false);
      print("Monthly payments data fetched: $response");

      setState(() {
        _payments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching monthly payments: $e");
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
                              "Amount: \$${payment['amount']}",
                              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date: ${payment['payment_date']}",
                              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Status: ${payment['status']}",
                              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600),
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