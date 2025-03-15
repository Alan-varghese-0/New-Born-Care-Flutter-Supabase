import 'package:flutter/material.dart';

class AddStock extends StatefulWidget {
  const AddStock({super.key});

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  final TextEditingController _stockController = TextEditingController();

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Stock"),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title text
            Text(
              "Add Stock",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),

            // Stock Quantity TextField
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock Quantity",
                labelStyle: TextStyle(color: Colors.green[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[800]!),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Add Stock Button
            ElevatedButton(
              onPressed: () {
                if (_stockController.text.isNotEmpty) {
                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Stock Updated"),
                      content: Text("Product stock has been updated successfully."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show error if no quantity is entered
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Error"),
                      content: Text("Please enter a valid stock quantity."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text("Add Stock", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
