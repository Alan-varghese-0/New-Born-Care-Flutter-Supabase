import 'package:flutter/material.dart';
import 'package:midwife/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class MidwifeAppointmentsScreen extends StatefulWidget {
  final String userId;

  const MidwifeAppointmentsScreen({super.key, required this.userId});

  @override
  _MidwifeAppointmentsScreenState createState() => _MidwifeAppointmentsScreenState();
}

class _MidwifeAppointmentsScreenState extends State<MidwifeAppointmentsScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};

  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isLoading = true;
  bool _hasValidUserId = true;

  @override
  void initState() {
    super.initState();
    _checkUserIdAndFetch();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _checkUserIdAndFetch() async {
    if (widget.userId.isEmpty) {
      setState(() {
        _hasValidUserId = false;
        _isLoading = false;
      });
      return;
    }
    await _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await supabase
          .from("tbl_appointments")
          .select()
          .eq("user_id", widget.userId);

      setState(() {
        _appointments.clear();
        for (var appointment in response) {
          final date = DateTime.tryParse(appointment['appointment_date']) ?? DateTime.now();
          final dayKey = DateTime(date.year, date.month, date.day);
          _appointments[dayKey] ??= [];
          _appointments[dayKey]!.add({
            'id': appointment['id'],
            'time': appointment['appointment_time'],
            'details': appointment['appointment_detals'], // keep as-is if column name has typo
          });
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching appointments: $e")),
      );
    }
  }

  Future<void> _addAppointment() async {
    if (_detailsController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid user ID provided")),
      );
      return;
    }

    try {
      final appointmentDate = _selectedDay.toIso8601String().split('T')[0];
      await supabase.from('tbl_appointments').insert({
        'appointment_date': appointmentDate,
        'appointment_time': _timeController.text,
        'appointment_detals': _detailsController.text,
        'user_id': widget.userId,
      });

      await _fetchAppointments();
      _detailsController.clear();
      _timeController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment added successfully")),
      );
    } catch (e) {
      print("Error adding appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding appointment: $e")),
      );
    }
  }

  Future<void> _deleteAppointment(DateTime dayKey, int index) async {
    try {
      final appointmentId = _appointments[dayKey]![index]['id'];
      await supabase.from('tbl_appointments').delete().eq('id', appointmentId);
      await _fetchAppointments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting appointment: $e")),
      );
    }
  }

  void _showAddAppointmentDialog() {
    if (!_hasValidUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot add appointment: No valid user ID")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Add Appointment",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    hintText: "Enter time (e.g., 10:00 AM)",
                    hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade900, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter appointment details...",
                    hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade900, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.nunito(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: _addAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: Text(
          "Appointment Diary",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasValidUserId
              ? Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: (day) => _appointments[DateTime(day.year, day.month, day.day)] ?? [],
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.purple.shade200,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.purple.shade700,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.purple.shade400,
                              shape: BoxShape.circle,
                            ),
                            outsideDaysVisible: false,
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: Colors.purple.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Appointments for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _appointments[dayKey] != null && _appointments[dayKey]!.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _appointments[dayKey]!.length,
                                itemBuilder: (context, index) {
                                  final appointment = _appointments[dayKey]![index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      title: Text(
                                        "${appointment['time']} - ${appointment['details']}",
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red.shade400),
                                        onPressed: () => _deleteAppointment(dayKey, index),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  "No Appointments",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 60, color: Colors.purple.shade700),
                      const SizedBox(height: 16),
                      Text(
                        "No Valid User ID Provided",
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please assign a patient first",
                        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _hasValidUserId
          ? FloatingActionButton(
              onPressed: _showAddAppointmentDialog,
              backgroundColor: Colors.purple.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
