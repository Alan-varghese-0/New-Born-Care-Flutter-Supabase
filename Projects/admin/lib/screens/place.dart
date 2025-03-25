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
      setState(() {
        isLoading = true;
      });
      await supabase.from("tbl_place").insert({
        'place_name': _placeController.text,
        'district_id': selectedDistrict
      });
      _placeController.clear();
      selectedDistrict = null; // Reset dropdown after insert
      fetchdata(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserted successfully'),
          backgroundColor: Color(0xFFD81B60), // Deep Pink
        ),
      );
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error found in insert $e')),
      );
    }
  }

  Future<void> fetchdata() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Join tbl_place with tbl_district to get district names
      final response = await supabase
          .from('tbl_place')
          .select('*, tbl_district(district_name)')
          .order('place_name', ascending: true);

      setState(() {
        isLoading = false;
        placeList = response;
      });
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places')),
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from("tbl_place").delete().eq('id', id);
      fetchdata();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted successfully'),
          backgroundColor: Color(0xFFD81B60), // Deep Pink
        ),
      );
    } catch (e) {
      print('Error $e');
    }
  }

  int edit = 0;

  Future<void> update() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase
          .from('tbl_place')
          .update({"place_name": _placeController.text}).eq("id", edit);
      fetchdata();
      _placeController.clear();
      setState(() {
        edit = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated successfully'),
          backgroundColor: Color(0xFFD81B60), // Deep Pink
        ),
      );
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF37474F), // Slate Gray background
      child: ListView(
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
                        dropdownColor: Color(0xFF455A64), // Darker Slate for dropdown
                        style: TextStyle(color: Color(0xFFECEFF1)), // Light Gray text
                        decoration: InputDecoration(
                          label: Text('District', style: TextStyle(color: Color(0xFFECEFF1))),
                          filled: true,
                          fillColor: Color(0xFF455A64), // Darker Slate background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFECEFF1).withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFD81B60)), // Deep Pink focus
                          ),
                        ),
                        value: selectedDistrict,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Select District', style: TextStyle(color: Color(0xFFECEFF1))),
                          ),
                          ...distList.map((district) {
                            return DropdownMenuItem(
                              value: district['id'].toString(),
                              child: Text(
                                district['district_name'],
                                style: TextStyle(color: Color(0xFFECEFF1)),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a district';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Text field for place name
                    Expanded(
                      child: TextFormField(
                        controller: _placeController,
                        style: TextStyle(color: Color(0xFFECEFF1)), // Light Gray text
                        decoration: InputDecoration(
                          label: Text('Place', style: TextStyle(color: Color(0xFFECEFF1))),
                          hintText: "Please enter the place",
                          hintStyle: TextStyle(color: Color(0xFFECEFF1).withOpacity(0.6)),
                          filled: true,
                          fillColor: Color(0xFF455A64), // Darker Slate background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFECEFF1).withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFD81B60)), // Deep Pink focus
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a place';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          if (edit == 0) {
                            insert();
                          } else {
                            update();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD81B60), // Deep Pink
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          // Show loading indicator or list of places
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD81B60), // Deep Pink spinner
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF455A64), // Darker Slate for list container
                    ),
                    padding: EdgeInsets.all(20),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(color: Color(0xFFECEFF1).withOpacity(0.2));
                      },
                      shrinkWrap: true,
                      itemCount: placeList.length,
                      itemBuilder: (context, index) {
                        final _place = placeList[index];
                        return ListTile(
                          title: Text(
                            _place['place_name'],
                            style: TextStyle(
                              color: Color(0xFFECEFF1), // Light Gray
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            _place['tbl_district']['district_name'] ?? 'Unknown District',
                            style: TextStyle(
                              color: Color(0xFFECEFF1).withOpacity(0.7), // Slightly faded
                              fontSize: 14,
                            ),
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
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFD81B60), // Deep Pink
                                  ),
                                ),
                                // Edit icon
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _placeController.text = _place['place_name'];
                                      selectedDistrict = _place['district_id'].toString();
                                      edit = _place['id'];
                                    });
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color(0xFFD81B60), // Deep Pink
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