import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Subcategory extends StatefulWidget {
  const Subcategory({super.key});

  @override
  State<Subcategory> createState() => _SubcategoryState();
}

class _SubcategoryState extends State<Subcategory> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _SubcategoryController = TextEditingController();
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> SubcategoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchSubcategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = response;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  String? selectedCategory;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_subcategory").insert({
        'Subcategory_name': _SubcategoryController.text,
        'category_id': selectedCategory
      });

      fetchSubcategories();
      _SubcategoryController.clear();
      selectedCategory = null;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inserted successfully')));
    } catch (e) {
      print('Error inserting: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error inserting: $e')));
    }
  }

  Future<void> fetchSubcategories() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase.from('tbl_subcategory').select();
      setState(() {
        isLoading = false;
        SubcategoryList = response;
      });
    } catch (e) {
      print('Error fetching subcategories: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching subcategories')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_subcategory").delete().eq('id', id);
      fetchSubcategories();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      print('Error deleting: $e');
    }
  }

  int edit = 0;
  Future<void> update() async {
    try {
      await supabase
          .from('tbl_subcategory')
          .update({"Subcategory_name": _SubcategoryController.text})
          .eq("id", edit);
      fetchSubcategories();
      _SubcategoryController.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {
      print('Error updating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
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
                        label: Text(
                          'Category',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      value: selectedCategory,
                      items: categoryList.map((category) {
                        return DropdownMenuItem(
                          value: category['id'].toString(),
                          child: Text(category['category_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _SubcategoryController,
                      decoration: InputDecoration(
                        label: Text(
                          'Subcategory',
                          style: TextStyle(color: Colors.white),
                        ),
                        hintText: 'Please enter the subcategory',
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
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
        ),
        SizedBox(height: 40),
        isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  color: Colors.white38,
                  padding: EdgeInsets.all(20),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    shrinkWrap: true,
                    itemCount: SubcategoryList.length,
                    itemBuilder: (context, index) {
                      final _subcategory = SubcategoryList[index];
                      return ListTile(
                        leading: Text(
                          _subcategory['Subcategory_name'],
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  delete(_subcategory['id']);
                                },
                                icon: Icon(Icons.delete_outline),
                                color: Color(0xFF6DAF7C), // Soft green delete icon
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _SubcategoryController.text =
                                        _subcategory['Subcategory_name'];
                                    edit = _subcategory['id'];
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: Color(0xFF6DAF7C), // Soft green edit icon
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
