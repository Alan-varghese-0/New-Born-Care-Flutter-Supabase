import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String? _selectedCategory;
  String? _selectedSubcategory;
  
  List<String> categories = ['Electronics', 'Clothing', 'Food'];
  List<String> electronicsSubcategories = ['Phone', 'Laptop', 'Accessories'];
  List<String> clothingSubcategories = ['Shirt', 'Pants', 'Jacket'];
  List<String> foodSubcategories = ['Fruits', 'Vegetables', 'Snacks'];
  List<String> subcategories = [];

  @override
  void initState() {
    super.initState();
    subcategories = electronicsSubcategories;
  }

  void _updateSubcategory(String? category) {
    setState(() {
      if (category == 'Electronics') {
        subcategories = electronicsSubcategories;
      } else if (category == 'Clothing') {
        subcategories = clothingSubcategories;
      } else if (category == 'Food') {
        subcategories = foodSubcategories;
      } else {
        subcategories = [];
      }
      _selectedSubcategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Product",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Product Name"),
                    _buildTextField("Product Image"),
                    _buildTextField("Product Details", maxLines: 5),
                    _buildTextField("Product Price", keyboardType: TextInputType.number),
                    _buildDropdown("Select Category", categories, _selectedCategory, (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        _updateSubcategory(newValue);
                      });
                    }),
                    _buildDropdown("Select Subcategory", subcategories, _selectedSubcategory, (newValue) {
                      setState(() {
                        _selectedSubcategory = newValue;
                      });
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Add Product", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedValue,
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
