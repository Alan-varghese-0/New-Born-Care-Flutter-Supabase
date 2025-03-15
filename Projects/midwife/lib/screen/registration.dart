import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:midwife/main.dart';
import 'package:midwife/screen/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isObsture = true;
  bool _isObsture2 = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController proofController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conpasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  List<Map<String, dynamic>> placelist = [];
  List<Map<String, dynamic>> distList = [];
  String? selectedplace;
  String? selecteddist;
  

  String gender = "male"; // Set a default value
  PlatformFile? pickedImage;
  PlatformFile? pickedproof;
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedImage = result.files.first; // Store the picked file
      });
    } else {
      print("No image selected");
    }
  }  

   Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedproof = result.files.first;
      });
    } else {
      print("No proof selected");
    }
  }

  Future<String?> photoUpload() async {
  if (pickedImage == null) {
    print("No photo selected");
    return null;
  }

  try {
    final bucketName = 'midwife'; // Replace with your actual bucket name
    String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
    final filePath = "$formattedDate-${pickedImage!.name}";

    if (pickedImage!.bytes == null) {
      print("Error: File bytes are null");
      return null;
    }

    await supabase.storage.from(bucketName).uploadBinary(
          filePath,
          pickedImage!.bytes!, // Ensure this is not null
        );

    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
    return publicUrl;
  } catch (e) {
    print("Error photo upload: $e");
    return null;
  }
}

  Future<String?> proofUpload() async {
  try {
    final bucketName = 'midwife_proofs'; // Change to your actual bucket name for proof documents
    String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
    final filePath = "$formattedDate-${pickedproof!.name}";

    if (pickedproof == null || pickedproof!.bytes == null) {
      print("Error: Proof file is null or has no bytes");
      return null;
    }

    await supabase.storage.from(bucketName).uploadBinary(
          filePath,
          pickedproof!.bytes!, // Ensure this is not null
        );

    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
    return publicUrl;
  } catch (e) {
    print("Error proof upload: $e");
    return null;
  }
}


  @override
  void initState() {
    super.initState();
    fetchdistrict();
  }

  Future<void> fetchplace(String id) async {
    try {
      final response =
          await supabase.from('tbl_place').select().eq('district_id', id);
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

  

 

  Future<void> reg() async {
    try {
      final authResponse = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
      String uid = authResponse.user!.id;
      insert(uid);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> insert(String uid) async {
    try {String dobValue = dobController.text.isEmpty 
    ? DateFormat('yyyy-MM-dd').format(DateTime.now()) 
    : dobController.text;
      String? photoUrl = await photoUpload();
      String? proofUrl = await proofUpload();
      await supabase.from('tbl_midwife').insert([
        {
          'midwife_name': nameController.text,
          'midwife_email': emailController.text,
          'midwife_contact': contactController.text,
          'midwife_address': addressController.text,
          'midwife_pass': passwordController.text,
          'midwife_dob': dobValue,
          'midwife_photo': photoUrl,
          'midwife_licence': proofUrl,
          'place_id': selectedplace,
          'midwife_gender' : gender,
        },
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MidwifeLogin(),
          ));
    } catch (e) {
      print("failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed:')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seller Registration",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      buildTextField("Full Name", nameController, Icons.person),
                      buildTextField("Email", emailController, Icons.email),
                      buildTextField("Contact", contactController, Icons.phone),
                      buildTextField(
                          "Address", addressController, Icons.location_city),
                      buildDropdownField("District", selecteddist, distList,
                          (value) {
                        setState(() {
                          selecteddist = value!;
                          fetchplace(value);
                        });
                      }),
                      buildDropdownField("Place", selectedplace, placelist,
                          (value) {
                        setState(() {
                          selectedplace = value!;
                        });
                      }),
                      buildGenderRadio(),

                      buildTextField("Date of Birth", dobController, Icons.calendar_today, onTap: handleDatePick),


                      buildTextField(
                          "Upload Photo", photoController, Icons.photo,
                          onTap: handleImagePick),
                      buildTextField(
                          "Upload Proof", proofController, Icons.file_present,
                          onTap: handleProofPick),
                      buildPasswordField(
                          "Password", passwordController, _isObsture, () {
                        setState(() => _isObsture = !_isObsture);
                      }),
                      buildPasswordField("Confirm Password",
                          conpasswordController, _isObsture2, () {
                        setState(() => _isObsture2 = !_isObsture2);
                      }),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: reg,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String hint, TextEditingController controller, IconData icon,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: inputDecoration(hint).copyWith(
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget buildPasswordField(String hint, TextEditingController controller,
      bool isObscure, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: inputDecoration(hint).copyWith(
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField(String hint, String? value,
      List<Map<String, dynamic>> list, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField(
        decoration: inputDecoration(hint),
        value: value,
        items: list.map((item) {
          return DropdownMenuItem(
            value: item['id'].toString(),
            child: Text(item['district_name'] ?? item['place_name']),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
  Widget buildGenderRadio() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Row(
        children: ["Male", "Female"].map((String genderOption) {
          return Expanded(
            child: Row(
              children: [
                Radio<String>(
                  value: genderOption,
                  groupValue: gender,
                  onChanged: (String? value) {
                    setState(() {
                      gender = value ?? "male"; // Default to Male if null
                    });
                  },
                ),
                Text(genderOption),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Future<void> handleDatePick() async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1970),
    lastDate: DateTime.now(),
  );
  if (pickedDate != null) {
    setState(() {
      dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    });
  }
}

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
  }
}
