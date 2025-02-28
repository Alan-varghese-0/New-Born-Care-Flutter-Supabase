import 'package:admin/screens/account.dart';
import 'package:admin/screens/category.dart';
import 'package:admin/screens/district.dart';
import 'package:admin/screens/place.dart';
import 'package:admin/screens/subcategorty.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int selectedIndex = 0;

  List<String> pageName = [
    'Account',
    'District',
    'place',
    'category',
    'subcategory',
  ];

  List<IconData> pageIcon = [
    Icons.account_circle,
    Icons.location_city,
    Icons.place,
    Icons.category,
    Icons.subscriptions
  ];

   List<Widget> pageContent = [
    Account(),
    District(),
    Place(),
    Category(),
    Subcategorty(),
  ];
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text("dashboard"),
        backgroundColor:Color.fromARGB(255, 105, 112, 103),
      ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                
                 color: Color.fromARGB(255, 96, 100, 104),
                  child: ListView.builder(
                shrinkWrap: false,
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        print(index);
                        selectedIndex = index;
                      });
                    },
                    leading: Icon(pageIcon[index],
                    color: Colors.white,),
                    title: Text(pageName[index],
                    style: TextStyle(
                      color: Colors.white
                    ),
                    ),
                  );
                },
              ),
                
              )
            ),
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/pg1.jpg"),fit: BoxFit.cover)),
                
                // color: Colors.white,
                child: pageContent[selectedIndex],

              ),
            )
           
          ],
        ),
      );
    
  }
}