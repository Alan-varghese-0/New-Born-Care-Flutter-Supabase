import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Subcategorty extends StatefulWidget {
  const Subcategorty({super.key});

  @override
  State<Subcategorty> createState() => _SubcategortyState();
}

class _SubcategortyState extends State<Subcategorty> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _SubcategortyController = TextEditingController();
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> SubcategortyList = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDist();
    fetchdata();
  }

  Future<void> fetchDist() async {
    try {
      print("category");
      final response = await supabase.from('tbl_category').select();
      print(response);
      setState(() {
        categoryList = response;
      });
    } catch (e) {
      print("Error fetching category: $e");
    }
  }

  String? selectedcategory;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_subcategory").insert({
        'Subcategorty_name': _SubcategortyController.text,
        'category_id': selectedcategory
      });

      print("Data inserted");
      fetchdata();
      _SubcategortyController.clear();
      selectedcategory=null;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inserted successufully')));
    } catch (e) {
      print('Error 1 $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error found in insert $e')));
    }
  }

  Future<void> fetchdata() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase.from('tbl_subcategory').select();

      setState(() {
        isLoading = false;
        SubcategortyList = response;
      });
    } catch (e) {
      print('Error 2 $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Errorooo')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_subcategory").delete().eq('id', id);

      fetchdata();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(' Deleted')));
    } catch (e) {
      print('error 3 $e');
    }
  }

  int edit = 0;
  Future<void> update() async {
    try {
      await supabase
          .from('tbl_subcategory')
          .update({"Subcategorty_name": _SubcategortyController.text}).eq("id", edit);
      fetchdata();
      _SubcategortyController.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {
      print('error 4 $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 50,
          ),
          child: Form(
              key: formkey,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        dropdownColor: Colors.black,
                        style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('category',
                              style: TextStyle(color: Colors.white))
                              ),
                          value: selectedcategory,
                          items: categoryList.map((category) {
                            return DropdownMenuItem(
                            
                                value: category['id'].toString(),
                                child: Text(category['category_name']));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedcategory = value!;
                            });
                          }),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _SubcategortyController,
                      decoration: InputDecoration(
                        label: Text(' Subcategorty',style: TextStyle(color: Colors.white),),
                        hintText: "please enter the Subcategorty",
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (edit == 0) {
                            insert();
                          } else {
                            update();
                          }
                        },
                        child: Text('Submit',style:TextStyle(color: Colors.black )))
                  ],
                ),
              )),
        ),
        SizedBox(
          height: 40,
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: Container(
                    color: Colors.white38,
                    padding: EdgeInsets.all(20),
                    child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        shrinkWrap: true,
                        itemCount: SubcategortyList.length,
                        itemBuilder: (context, index) {
                          final _Subcategorty = SubcategortyList[index];
                          return ListTile(
                              leading: Text(
                                style: TextStyle(fontSize: 18),
                                _Subcategorty['Subcategorty_name'],
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          delete(_Subcategorty['id']);
                                        },
                                        icon: Icon(Icons.delete_outline)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _SubcategortyController.text =
                                                _Subcategorty['Subcategorty_name'];
                                            edit = _Subcategorty['id'];
                                          });
                                        },
                                        icon: Icon(Icons.edit))
                                  ],
                                ),
                              ));
                        })),
              )
      ],
    );
  }
}