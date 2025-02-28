import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/change_pass.dart';
import 'package:user/screens/edit_profile.dart';
import 'package:user/screens/home.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
   String name = "";
   String email ="";
   String contact ="";
   String Address ="";
  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response =
          await supabase.from("tbl_user").select().eq('id', uid).single();
      setState(() {
        name = response['user_name'];
        email = response['user_email'];
        contact = response['user_contact'];
        Address = response['user_address'];
      });
      getInitials(response['user_name']);
    } catch (e) {
      print("uesr not fount $e");
    }
  }

  String initial = "";

   void getInitials(String name) {
    String initials = '';
    if(name!="" || name.isNotEmpty){
      List<String> nameParts = name.split(' ');

    if (nameParts.isNotEmpty) {
      // Take the first letter of the first name
      initials += nameParts[0][0];
      if (nameParts.length > 1) {
        // Take the first letter of the last name if it exists
        initials += nameParts[1][0];
      }
    }
    }

    setState(() {
      initial=initials.toUpperCase();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
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
                    builder: (context) => Home(),
                  ));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          "my profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'log out',
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration:
            BoxDecoration(color:Color(0xFFFFF8E1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFFE3F2F1), // Or any color you prefer
                child: Text(
                  initial, // Call the function to get initials
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Name  : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                      child: Text(name ,style: TextStyle(fontSize: 20),textAlign: TextAlign.start,),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("E-mail  : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    Container(
                      padding:EdgeInsets.all(10) ,
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                      child: Text(email ,style: TextStyle(fontSize: 20),textAlign: TextAlign.start,),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Contact : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    Container(
                      padding:EdgeInsets.all(10) ,
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                      child: Text(contact ,style: TextStyle(fontSize: 20),textAlign: TextAlign.start,),
                    ),
                  ],
                ),
                 SizedBox(height: 20,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Address : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 250,
                      height: 80,
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                      child: Text(Address ,style: TextStyle(fontSize: 20),textAlign: TextAlign.start,),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
                    }, child: Text("Edit")),
                      ElevatedButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePass(),));
                    }, child: Text("Change password")),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
