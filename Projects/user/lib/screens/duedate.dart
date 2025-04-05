import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/home.dart';

class Duedate extends StatefulWidget {
  const Duedate({super.key});

  @override
  State<Duedate> createState() => _DuedateState();
}

class _DuedateState extends State<Duedate> {
  final TextEditingController _pdatecontroller = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
     DateTime currentDate = DateTime.now();
    DateTime maxDate = DateTime(currentDate.year - 2, currentDate.month, currentDate.day);
        ; // 18 years ago from today

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: maxDate,
      lastDate: currentDate, // Set the last selectable date to 18 years ago
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _pdatecontroller.text = "${_selectedDate?.toLocal()}"
            .split(' ')[0]; // Display as yyyy-MM-dd
      });
    }
  }

  Future<void> updatepgd() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from("tbl_user").update({
        "user_pdate":_pdatecontroller.text
      }).eq('id', userId); 
      print("date is added");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(),));
    } catch (e) {
      print("error no date added $e");
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _pdatecontroller,
                      readOnly:
                          true, // Makes the TextField non-editable by user, tapping opens DatePicker
                      decoration: InputDecoration(
                        labelText: 'pregnancy date',
                        labelStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 50,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 230, 104, 146)),
                      onPressed: (){
                        updatepgd();
                    }, child: Text("submit",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
