import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/home.dart';

class Fromdate extends StatefulWidget {
  final String midwifeId; // Add midwifeId parameter

  const Fromdate({super.key, required this.midwifeId}); // Make it required

  @override
  State<Fromdate> createState() => _FromdateState();
}

class _FromdateState extends State<Fromdate> {
  final TextEditingController _fdateController = TextEditingController();
  final TextEditingController _dDateController = TextEditingController();
  DateTime? _selectedPDate;
  DateTime? _selectedDueDate;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectPDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime maxDate = DateTime(currentDate.year + 2, currentDate.month, currentDate.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedPDate ?? currentDate,
      firstDate: currentDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 230, 104, 146),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedPDate) {
      setState(() {
        _selectedPDate = pickedDate;
        _fdateController.text = "${_selectedPDate?.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime maxDate = DateTime(currentDate.year + 2, currentDate.month, currentDate.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? currentDate,
      firstDate: currentDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 230, 104, 146),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDueDate) {
      setState(() {
        _selectedDueDate = pickedDate;
        _dDateController.text = "${_selectedDueDate?.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> insertpg() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from("tbl_booking").insert({
        "booking_fromdate": _fdateController.text,
        "booking_enddate": _dDateController.text,
        "midwife_id": widget.midwifeId, // Use the passed midwifeId
        "user_id": userId, // Include the user ID
      });
      print("Dates are added with Midwife ID: ${widget.midwifeId}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      print("Error no dates added: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding booking: $e')),
      );
    }
  }

  @override
  void dispose() {
    _fdateController.dispose();
    _dDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(30),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Select Booking Dates",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 230, 104, 146),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _fdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'From Date',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Color.fromARGB(255, 230, 104, 146),
                        size: 24,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    onTap: () => _selectPDate(context),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _dDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Color.fromARGB(255, 230, 104, 146),
                        size: 24,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    onTap: () => _selectDueDate(context),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 230, 104, 146),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    insertpg();
                  },
                  child: Text(
                    "SUBMIT",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}