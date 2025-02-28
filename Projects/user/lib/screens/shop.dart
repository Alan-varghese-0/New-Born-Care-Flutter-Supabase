import 'package:flutter/material.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(child: Center(
        child: Row(
          children: [
            // Expanded(child: DropdownButtonFormField(items: items, onChanged: onChanged))
          ],
        ),
      )),
    );
  }
}