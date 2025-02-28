import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/my_account.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController(); 
  final TextEditingController _addressController = TextEditingController();   

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
  }

   Future<void> fetchdata() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response =
          await supabase.from("tbl_user").select().eq('id', uid).single();
      setState(() {
        _nameController.text = response['user_name'];
        _contactController.text = response['user_contact'];
        _addressController.text = response['user_address'];
      });
    } catch (e) {
      print("uesr not fount $e");
    }
  }

  Future<void> update() async {
    try {
      String uid = supabase.auth.currentUser!.id;
       await supabase.from("tbl_user").update({
        "user_name": _nameController.text,
        "user_contact" : _contactController.text,
        "user_address" : _addressController.text
        }).eq("id", uid);
        print("update success");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("successfully updated")));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAccount(),));
    } catch (e) {
      print("update failed $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("update failed cause => $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAccount(),
                    ));
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.blue,
              )),
          title: Text(
            "Edit profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Center(
            child: Form(
          child: Container(
            padding: EdgeInsets.all(30),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Enter here...',
                        suffixIcon: Icon(Icons.person)),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "contact",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Enter here...',
                        suffixIcon: Icon(Icons.phone)),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "address",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Enter here...',
                        suffixIcon: Icon(Icons.place)),
                    minLines: 3,
                    maxLines: null,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: ElevatedButton(onPressed: (){
                      update();
                    }, child: Text("submit",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  )
                ])),
          ),
        )));
  }
}
