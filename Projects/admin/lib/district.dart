import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {

  TextEditingController _district = TextEditingController();
  List<Map<String, dynamic>> fetchdistrict = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void> insert() async {
    try {
      setState(() {
        isLoading=true;
      });
      await supabase.from("tbl_district").insert({'district_name': _district.text});
      fetchdata();
      _district.clear();
      print("Instered");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Data Inserted Successfully")));
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Insert Failed: $e")));
    }
  }

  Future<void> fetchdata() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        fetchdistrict = response;
        isLoading=false;
      });
    } catch (e) {
      print("Error $e");
       ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Insert Failed: $e")));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_district').delete().eq('id', id);
      fetchdata();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted")));
    } catch (e) {
      print("Error Deleting $e");
    }
  }

  int editId = 0;

  Future<void> update() async {
    try {
      await supabase.from("tbl_district").update({
        "district_name":_district.text
      }).eq('id', editId);
      fetchdata();
      _district.clear();
      setState(() {
        editId=0;
      });
    } catch (e) {
      print(Text('edit unable $e'));
      
    }
  }
  


  @override
  Widget build(BuildContext context) {
    return
    isLoading ? Center(child: CircularProgressIndicator(),) :
     ListView(
      padding: EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 80
      ),
      children: [
        Form(child: Center(
          child: Row(
            children: [
              // Text("district"),
              Expanded(
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _district,
                  decoration: InputDecoration(
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(10)
                    // ),
                    label: Text("district"),
                    labelStyle: TextStyle(color:Colors.white),
                    hintText: 'please enter the district',
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: const Color.fromARGB(255, 180, 171, 171),
                    filled: false,
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                if(editId==0){
                  insert();
                }
                else
                {
                  update();
                }
              }, child: Text("submit",
              style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.w100),),
              )
            ],
          ),
        ),
        
        ),
        SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.5),
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: ListView.separated(
            
            separatorBuilder: (context, index) {
              return Divider();
            },
              shrinkWrap: true,
                itemCount: fetchdistrict.length,
                itemBuilder: (context, index) {
                final district= fetchdistrict[index];
                return ListTile(
                  leading:Text( district['district_name'],
                  style: TextStyle(color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                  ),),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          delete(district['id']);
                        }, icon: Icon(Icons.delete)),
                        IconButton(onPressed: (){
                          setState(() {
                            _district.text = district['district_name'];
                            editId = district['id'];
                          });
                        }, icon: Icon(Icons.edit)),
                      ],
                    ),
                  ),
                );
              },),
              
        )
      ],
    );
  }
}