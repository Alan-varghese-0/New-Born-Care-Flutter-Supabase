import 'package:flutter/material.dart';
import 'package:seller/screen/add_stock.dart';
import 'package:seller/screen/edit_product.dart';

class ProductDetailPage extends StatefulWidget {
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Controllers for editable fields
  TextEditingController _nameController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _nameController.text = "Product Name";
    _detailController.text = "Product details go here";
    _priceController.text = "\$99.99";
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _detailController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Function to update stock
  // void _updateStock() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Stock Updated"),
  //       content: Text("Product stock has been updated successfully."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Function to delete the product
  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Product"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Go back to the previous screen (simulating deletion)
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Detail",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ListView(
              children: [
                // Product Image
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "assets/pg.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Editable Product Information
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _detailController,
                  decoration: InputDecoration(
                    labelText: "Detail",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),

                // Rating Section
                Row(
                  children: [
                    Text(
                      "Rating: ",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        if (index < 3) {
                          return Icon(Icons.star, color: Colors.amber, size: 20);
                        } else if (index == 3) {
                          return Icon(Icons.star_half, color: Colors.amber, size: 20);
                        } else {
                          return Icon(Icons.star_border, color: Colors.amber, size: 20);
                        }
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Update Stock Button
                ElevatedButton(
                  onPressed: () {
                    // Call the function to update stock
                    // _updateStock();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddStock()));
                  },
                  child: Text("Update Stock"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Positioned Delete Button in Top Right Corner
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _deleteProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
           Positioned(
            top: 60,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Call the function to update stock
                // _updateStock();
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProduct()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: Text(
                "edit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
