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
      fetchdata();
      cat.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inserted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching categories')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_category").delete().eq('id', id);
      fetchdata();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  int edit = 0;

  Future<void> update() async {
    try {
      await supabase
          .from('tbl_category')
          .update({"category_name": cat.text})
          .eq("id", edit);
      fetchdata();
      cat.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 80),
      children: [
        Form(
          key: formkey,
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cat,
                    style: TextStyle(color: Colors.black), // Dark text for readability
                    decoration: InputDecoration(
                      label: Text(
                        "Category",
                        style: TextStyle(color: Colors.black),
                      ),
                      hintText: 'Please enter the category',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                      filled: true,
                      fillColor: Color(0xFFF1F0E6), // Beige background for text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (edit == 0) {
                      insert();
                    } else {
                      update();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF6DAF7C),
                  ),
                  child: Text('Submit', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 40),
        isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.black))
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Colors.white.withOpacity(0.6), // Soft white background
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
                        _category['category_name'],
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                delete(_category['id']);
                              },
                              icon: Icon(Icons.delete_outline),
                              color: Color(0xFF6DAF7C), // Green delete icon
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  cat.text = _category['category_name'];
                                  edit = _category['id'];
                                });
                              },
                              icon: Icon(Icons.edit),
                              color: Color(0xFF6DAF7C), // Green edit icon
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
