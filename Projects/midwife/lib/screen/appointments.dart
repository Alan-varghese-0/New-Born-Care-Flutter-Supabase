// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class MidwifeAppointmentsScreen extends StatefulWidget {
//   @override
//   _MidwifeAppointmentsScreenState createState() => _MidwifeAppointmentsScreenState();
// }

// class _MidwifeAppointmentsScreenState extends State<MidwifeAppointmentsScreen> {
//   DateTime _selectedDay = DateTime.now();
//   Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
//   final TextEditingController _noteController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchAppointments();
//   }

//   Future<void> fetchAppointments() async {
//     try {
//       final uid = Supabase.instance.client.auth.currentUser?.id;
//       final response = await Supabase.instance.client
//           .from("tbl_appointments")
//           .select()
//           .eq("midwife_id", uid);

//       Map<DateTime, List<Map<String, dynamic>>> fetchedAppointments = {};

//       for (var appointment in response) {
//         DateTime date = DateTime.parse(appointment['date']);
//         if (!fetchedAppointments.containsKey(date)) {
//           fetchedAppointments[date] = [];
//         }
//         fetchedAppointments[date]?.add(appointment);
//       }

//       setState(() {
//         _appointments = fetchedAppointments;
//       });
//     } catch (e) {
//       print("Error fetching appointments: $e");
//     }
//   }

//   void _addAppointment() async {
//     if (_noteController.text.isEmpty) return;

//     try {
//       final uid = Supabase.instance.client.auth.currentUser?.id;
//       final newAppointment = {
//         'midwife_id': uid,
//         'date': _selectedDay.toIso8601String(),
//         'note': _noteController.text
//       };

//       await Supabase.instance.client.from("tbl_appointments").insert(newAppointment);
//       fetchAppointments();
//       _noteController.clear();
//       Navigator.pop(context);
//     } catch (e) {
//       print("Error adding appointment: $e");
//     }
//   }

//   void _showAddAppointmentDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Add Appointment", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
//           content: TextField(
//             controller: _noteController,
//             decoration: InputDecoration(hintText: "Enter appointment details..."),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//             ElevatedButton(onPressed: _addAppointment, child: Text("Save")),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Midwife Appointment Diary",
//             style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.purple.shade700,
//       ),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _selectedDay,
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//               });
//             },
//             eventLoader: (day) => _appointments[day] ?? [],
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: _appointments[_selectedDay] != null
//                 ? ListView.builder(
//                     itemCount: _appointments[_selectedDay]!.length,
//                     itemBuilder: (context, index) {
//                       final appointment = _appointments[_selectedDay]![index];
//                       return Card(
//                         elevation: 3,
//                         child: ListTile(
//                           title: Text(appointment['note'],
//                               style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
//                           trailing: IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               await Supabase.instance.client
//                                   .from("tbl_appointments")
//                                   .delete()
//                                   .eq('id', appointment['id']);
//                               fetchAppointments();
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   )
//                 : Center(child: Text("No Appointments", style: GoogleFonts.nunito(fontSize: 16))),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddAppointmentDialog,
//         backgroundColor: Colors.purple.shade700,
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class MidwifeAppointmentsScreen extends StatefulWidget {
  const MidwifeAppointmentsScreen({super.key});

  @override
  _MidwifeAppointmentsScreenState createState() => _MidwifeAppointmentsScreenState();
}

class _MidwifeAppointmentsScreenState extends State<MidwifeAppointmentsScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _appointments = {};
  final TextEditingController _noteController = TextEditingController();

  void _addAppointment() {
    if (_noteController.text.isEmpty) return;

    setState(() {
      final dayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      if (!_appointments.containsKey(dayKey)) {
        _appointments[dayKey] = [];
      }
      _appointments[dayKey]!.add(_noteController.text);
    });

    _noteController.clear();
    Navigator.pop(context);
  }

  void _deleteAppointment(int index) {
    setState(() {
      final dayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      _appointments[dayKey]?.removeAt(index);
      if (_appointments[dayKey]?.isEmpty ?? true) {
        _appointments.remove(dayKey);
      }
    });
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Add Appointment",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          content: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter appointment details...",
              hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.teal.shade50.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.nunito(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: _addAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text(
          "Midwife Appointment Diary",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
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
                  color: Colors.teal.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.teal.shade600,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.teal.shade400,
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
                  color: Colors.teal.shade700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.event, color: Colors.teal.shade500, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Appointments for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
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
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            appointment,
                            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () => _deleteAppointment(index),
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
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: Colors.teal.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const MidwifeAppointmentsScreen(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}