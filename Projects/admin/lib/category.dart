import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final formkey = GlobalKey<FormState>();

  final TextEditingController cat = TextEditingController();

  List<Map<String, dynamic>> fetchcat = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void> insert() async {
    try {
      await supabase.from('tbl_category').insert({'category_name': cat.text});

      print('inserted');
      fetchdata();

      cat.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inerted Aayitundeee')));
    } catch (e) {
      print('Error Kandu Pidiche...... $e');

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Kandu Pidichutooo Mattikoooooo $e')));
    }
  }

  Future<void> fetchdata() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase.from('tbl_category').select();

      setState(() {
        isLoading = false;
        fetchcat = response;
      });
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_category").delete().eq('id', id);

      fetchdata();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(' Deleted')));
    } catch (e) {
      print('error $e');
    }
  }

  int edit = 0;
  Future<void> update() async {
    try {
      await supabase
          .from('tbl_category')
          .update({"category_name": cat.text}).eq("id", edit);
      fetchdata();
      cat.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 80,
      ),
      children: [
        Form(
            key: formkey,
            child: Center(
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: cat,
                    decoration: InputDecoration(
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(10)
                    // ),
                    label: Text("category"),
                    labelStyle: TextStyle(color:Colors.white),
                    hintText: 'please enter the category',
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: const Color.fromARGB(255, 180, 171, 171),
                    filled: false,
                  ),
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (edit == 0) {
                          insert();
                        } else {
                          update();
                        }
                      },
                      child: Text('Submit'))
                ],
              ),
            )),
        SizedBox(
          height: 40,
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : Container(
              decoration:BoxDecoration( 
                borderRadius: BorderRadius.circular(35),
                color: Colors.white38,
              ),
                padding: EdgeInsets.all(20),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  shrinkWrap: true,
                  itemCount: fetchcat.length,
                  itemBuilder: (context, index) {
                    final _category = fetchcat[index];
                    return ListTile(
                        leading: Text(
                          style: TextStyle(fontSize: 18),
                          _category['category_name'],
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    delete(_category['id']);
                                  },
                                  icon: Icon(Icons.delete_outline)),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      cat.text = _category['category_name'];
                                      edit = _category['id'];
                                    });
                                  },
                                  icon: Icon(Icons.edit))
                            ],
                          ),
                        ));
                  },
                ),
              )
      ],
    );
  }
}