import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:midwife/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isLoading = false;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _aboutMe = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  String _gender = "Male";
  String? _district;
  String? _place;
  List<Map<String, dynamic>> placelist = [];
  List<Map<String, dynamic>> distList = [];
  PlatformFile? _pickedImage;
  PlatformFile? _pickedProof;

  final SupabaseClient supabase = Supabase.instance.client;

  // Email validation function
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchdistrict();
  }

  Future<void> fetchplace(String districtId) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('district_id', districtId);
      setState(() {
        placelist = response;
      });
    } catch (e) {
      print('Error fetching place: $e');
    }
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        distList = response;
      });
    } catch (e) {
      print('Error fetching district: $e');
    }
  }

  Future<void> _handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _pickedImage = result.files.first;
      });
    }
  }

  Future<void> _handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _pickedProof = result.files.first;
      });
    }
  }

  Future<void> _handleDatePick() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade700,
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
    if (pickedDate != null) {
      setState(() {
        _dob.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<String?> _uploadFile(PlatformFile file, String folder) async {
    try {
      final fileBytes = file.bytes ?? File(file.path!).readAsBytesSync();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final filePath = '$folder/$fileName';

      await supabase.storage.from('midwife').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from('midwife').getPublicUrl(filePath);
    } catch (e) {
      print("Image Error: $e");
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _email.text,
        password: _password.text,
      );

      if (response.user != null) {
        String? photoUrl;
        String? proofUrl;

        if (_pickedImage != null) {
          photoUrl = await _uploadFile(_pickedImage!, 'photos');
          if (photoUrl == null) throw Exception('Photo upload failed');
        }

        if (_pickedProof != null) {
          proofUrl = await _uploadFile(_pickedProof!, 'proofs');
          if (proofUrl == null) throw Exception('Proof upload failed');
        }

        await supabase.from('tbl_midwife').insert({
          'id': response.user!.id,
          'midwife_name': _name.text,
          'midwife_email': _email.text,
          'midwife_pass': _password.text,
          'midwife_contact': _contact.text,
          'midwife_address': _address.text,
          'place_id': _place,
          'midwife_dob': _dob.text,
          'midwife_gender': _gender,
          'midwife_about': _aboutMe.text,
          'midwife_photo': photoUrl,
          'midwife_licence': proofUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful!',
              style: GoogleFonts.nunito(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MidwifeLogin()),
        );
      }
    } catch (e) {
      print('Error registering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: $e',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MidwifeLogin()));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        title: Text(
          "Become a Midwife",
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Support Mothers Every Step of the Way",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", _name, Icons.person),
                  _buildTextField("Email", _email, Icons.email, isEmail: true),
                  _buildTextField("Contact Number", _contact, Icons.phone),
                  _buildTextField("Address", _address, Icons.location_on),
                  _buildDropdownField(
                    "District",
                    _district,
                    distList.map((d) => d['district_name'] as String).toList(),
                    (value) {
                      setState(() {
                        _district = value;
                        _place = null;
                        final selectedDistrict = distList.firstWhere((d) => d['district_name'] == value);
                        fetchplace(selectedDistrict['id'].toString());
                      });
                    },
                  ),
                  _buildDropdownField(
                    "Place",
                    _place != null
                        ? placelist.firstWhere((p) => p['id'].toString() == _place, orElse: () => {'place_name': ''})['place_name']
                        : null,
                    placelist.map((p) => p['place_name'] as String).toList(),
                    (value) {
                      setState(() {
                        _place = placelist.firstWhere((p) => p['place_name'] == value)['id'].toString();
                      });
                    },
                    enabled: _district != null && placelist.isNotEmpty,
                  ),
                  _buildDateField("Date of Birth", _dob),
                  _buildTextField("About Me", _aboutMe, Icons.info, maxLines: 3),
                  _buildGenderSelection(),
                  _buildFilePicker("Profile Photo", _pickedImage, _handleImagePick),
                  _buildFilePicker("Certification Proof", _pickedProof, _handleProofPick),
                  _buildPasswordField("Password", _password, _isObscure1, () => setState(() => _isObscure1 = !_isObscure1)),
                  _buildPasswordField("Confirm Password", _confirmPassword, _isObscure2, () => setState(() => _isObscure2 = !_isObscure2)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            "Register as Midwife",
                            style: GoogleFonts.nunito(fontSize: 18),
                          ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MidwifeLogin())),
                    child: Text(
                      "Already a midwife? Login here",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.purple.shade700),
          prefixIcon: Icon(icon, color: Colors.purple.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: isEmail ? validateEmail : (value) => value!.isEmpty ? "Please enter $label" : null,
        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: _handleDatePick,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.purple.shade700),
          prefixIcon: Icon(Icons.calendar_today, color: Colors.purple.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) => value!.isEmpty ? "Please select $label" : null,
        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.nunito(fontSize: 16, color: Colors.purple.shade700)),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.purple.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ["Male", "Female"].map((String option) {
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Row(
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value!),
                      activeColor: Colors.purple.shade700,
                    ),
                    Text(option, style: GoogleFonts.nunito(fontSize: 16, color: Colors.purple.shade700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.purple.shade700),
          prefixIcon: Icon(Icons.lock, color: Colors.purple.shade700),
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.purple.shade700),
            onPressed: toggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          if (label == "Confirm Password" && value != _password.text) {
            return "Passwords do not match";
          }
          return null;
        },
        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildFilePicker(String label, PlatformFile? file, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  file != null ? file.name : label,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: file != null ? Colors.purple.shade700 : Colors.purple.shade700.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.upload, color: Colors.purple.shade700, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}