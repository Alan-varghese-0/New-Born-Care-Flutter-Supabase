import 'package:flutter/material.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 30,
      ),
      children: [
        Form(
            child: Center(
          child: Column(
            children: [
              TextFormField(
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  label: Text("ask your questions"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:  Color.fromARGB(255, 230, 104, 146)),
                onPressed: () {}, child: Text("Search",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),))
            ],
          ),
        )),
      ],
    );
  }
}
