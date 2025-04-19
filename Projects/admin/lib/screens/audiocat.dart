import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Audiocat extends StatefulWidget {
  const Audiocat({super.key});

  @override
  State<Audiocat> createState() => _AudiocatState();
}

class _AudiocatState extends State<Audiocat> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> categoryList = [];
  bool isLoading = false;
  int edit = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch existing categories from Supabase
  Future<void> _fetchCategories() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_audiocat')
          .select()
          .order('audio_name', ascending: true);
      setState(() {
        categoryList = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching categories: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    }
  }

  // Insert a new category
  Future<void> _insertCategory() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('tbl_audiocat').insert({
        'audio_name': _nameController.text.trim(),
        'audio_dis': _descriptionController.text.trim(),
      });
      _nameController.clear();
      _descriptionController.clear();
      await _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    } catch (e) {
      print("Error inserting category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inserting category: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update an existing category
  Future<void> _updateCategory() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('tbl_audiocat').update({
        'audio_name': _nameController.text.trim(),
        'audio_dis': _descriptionController.text.trim(),
      }).eq('id', edit);
      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        edit = 0;
      });
      await _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    } catch (e) {
      print("Error updating category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete a category
  Future<void> _deleteCategory(int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('tbl_audiocat').delete().eq('id', id);
      await _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    } catch (e) {
      print("Error deleting category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting category: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF37474F), // Slate gray background
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Form inputs
                  Row(
                    children: [
                      // Category name input
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFFECEFF1)),
                          decoration: InputDecoration(
                            label: const Text('Category Name',
                                style: TextStyle(color: Color(0xFFECEFF1))),
                            hintText: "Enter category name",
                            hintStyle: TextStyle(
                                color: const Color(0xFFECEFF1)
                                    .withOpacity(0.6)),
                            filled: true,
                            fillColor: const Color(0xFF455A64),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: const Color(0xFFECEFF1)
                                      .withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD81B60)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a category name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Description input
                      Expanded(
                        child: TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Color(0xFFECEFF1)),
                          decoration: InputDecoration(
                            label: const Text('Description',
                                style: TextStyle(color: Color(0xFFECEFF1))),
                            hintText: "Enter description",
                            hintStyle: TextStyle(
                                color: const Color(0xFFECEFF1)
                                    .withOpacity(0.6)),
                            filled: true,
                            fillColor: const Color(0xFF455A64),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: const Color(0xFFECEFF1)
                                      .withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD81B60)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Submit button
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  if (edit == 0) {
                                    _insertCategory();
                                  } else {
                                    _updateCategory();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: Text(
                          edit == 0 ? 'Submit' : 'Update',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Category list
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD81B60),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF455A64),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: categoryList.isEmpty
                        ? const Center(
                            child: Text(
                              'No categories found.',
                              style: TextStyle(
                                color: Color(0xFFECEFF1),
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider(
                                  color: const Color(0xFFECEFF1)
                                      .withOpacity(0.2));
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryList.length,
                            itemBuilder: (context, index) {
                              final category = categoryList[index];
                              return ListTile(
                                title: Text(
                                  category['audio_name'], // Display audio_name
                                  style: const TextStyle(
                                    color: Color(0xFFECEFF1),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  category['audio_dis'], // Display audio_dis
                                  style: TextStyle(
                                    color: const Color(0xFFECEFF1)
                                        .withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _deleteCategory(category['id']);
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFD81B60),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _nameController.text =
                                                category['audio_name'];
                                            _descriptionController.text =
                                                category['audio_dis'];
                                            edit = category['id'];
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFD81B60),
                                        ),
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
      ),
    );
  }
}