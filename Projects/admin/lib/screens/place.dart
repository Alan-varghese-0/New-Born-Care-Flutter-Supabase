import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDist();
    fetchdata();
  }

  Future<void> fetchDist() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        distList = response;
      });
    } catch (e) {
      print("Error fetching district: $e");
    }
  }

  String? selectedDistrict;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_place").insert({
        'place_name': _placeController.text,
        'district_id': selectedDistrict
      });

      _placeController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Inserted successfully')));
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error found in insert $e')));
    }
  }

  Future<void> fetchdata() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase.from('tbl_place').select();

      setState(() {
        isLoading = false;
        placeList = response;
      });
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching places')));
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from("tbl_place").delete().eq('id', id);

      fetchdata();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      print('Error $e');
    }
  }

  int edit = 0;

  Future<void> update() async {
    try {
      await supabase
          .from('tbl_place')
          .update({"place_name": _placeController.text}).eq("id", edit);
      fetchdata();
      _placeController.clear();
      setState(() {
        edit = 0;
      });
    } catch (e) {
      print('Error $e');
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
                  // Dropdown for District selection
                  Expanded(
                    child: DropdownButtonFormField(
                      dropdownColor: Colors.white, // Natural white background
                      style: TextStyle(color: Colors.black), // Dark text
                      decoration: InputDecoration(
                        label: Text('District', style: TextStyle(color: Colors.black)),
                        filled: true,
                        fillColor: Color(0xFFF1F0E6), // Beige background for dropdown
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
                        ),
                      ),
                      value: selectedDistrict,
                      items: distList.map((district) {
                        return DropdownMenuItem(
                          value: district['id'].toString(),
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Text field for place name
                  Expanded(
                    child: TextFormField(
                      controller: _placeController,
                      style: TextStyle(color: Colors.black), // Dark text
                      decoration: InputDecoration(
                        label: Text('Place', style: TextStyle(color: Colors.black)),
                        hintText: "Please enter the place",
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                        filled: true,
                        fillColor: Color(0xFFF1F0E6), // Beige background for input field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Submit button
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
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 40),
        // Show loading indicator or list of places
        isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.black))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  color: Colors.white.withOpacity(0.6), // Soft white background
                  padding: EdgeInsets.all(20),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    shrinkWrap: true,
                    itemCount: placeList.length,
                    itemBuilder: (context, index) {
                      final _place = placeList[index];
                      return ListTile(
                        leading: Text(
                          _place['place_name'],
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              // Delete icon
                              IconButton(
                                onPressed: () {
                                  delete(_place['id']);
                                },
                                icon: Icon(Icons.delete_outline),
                                color: Color(0xFF6DAF7C), // Green for delete icon
                              ),
                              // Edit icon
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _placeController.text = _place['place_name'];
                                    edit = _place['id'];
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: Color(0xFF6DAF7C), // Green for edit icon
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
