import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seller/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:seller/screen/login.dart';

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

  List<Map<String, dynamic>> placelist = [];
  List<Map<String, dynamic>> distList = [];
  String? selectedplace;
  String? selecteddist;
  PlatformFile? pickedImage;
  PlatformFile? pickedproof;
  Future<String?> photoUpload() async {
    try {
      final bucketName = 'seller'; // Replace with your bucket name
       String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<String?> proofUpload() async {
    try {
      final bucketName = 'seller'; // Replace with your bucket name
       String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${pickedproof!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedproof!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
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

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        photoController.text = result.files.first.name;
      });
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedproof = result.files.first;
        proofController.text = result.files.first.name;
      });
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
    try {
      String? photoUrl = await photoUpload();
      String? proofUrl = await proofUpload();
      await supabase.from('tbl_seller').insert([
        {
          'seller_name': nameController.text,
          'seller_email': emailController.text,
          'seller_contact': contactController.text,
          'seller_address': addressController.text,
          'seller_password': passwordController.text,
          'seller_logo': photoUrl,
          'seller_proof': proofUrl,
          'place_id': selectedplace,
        },
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      buildTextField("Full Name", nameController, Icons.person),
                      buildTextField("Email", emailController, Icons.email),
                      buildTextField("Contact", contactController, Icons.phone),
                      buildTextField("Address", addressController, Icons.location_city),
                      buildDropdownField("District", selecteddist, distList, (value) {
                        setState(() {
                          selecteddist = value!;
                          fetchplace(value);
                        });
                      }),
                      buildDropdownField("Place", selectedplace, placelist, (value) {
                        setState(() {
                          selectedplace = value!;
                        });
                      }),
                      buildTextField("Upload Photo", photoController, Icons.photo, onTap: handleImagePick),
                      buildTextField("Upload Proof", proofController, Icons.file_present, onTap: handleProofPick),
                      buildPasswordField("Password", passwordController, _isObsture, () {
                        setState(() => _isObsture = !_isObsture);
                      }),
                      buildPasswordField("Confirm Password", conpasswordController, _isObsture2, () {
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget buildTextField(String hint, TextEditingController controller, IconData icon, {VoidCallback? onTap}) {
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

  Widget buildPasswordField(String hint, TextEditingController controller, bool isObscure, VoidCallback toggle) {
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

  Widget buildDropdownField(String hint, String? value, List<Map<String, dynamic>> list, Function(String?) onChanged) {
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
