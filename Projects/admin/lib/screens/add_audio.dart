import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show File; // Only for mobile

class AddAudio extends StatefulWidget {
  const AddAudio({super.key});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> audioList = [];
  bool isLoading = false;
  String? selectedCategoryId;
  PlatformFile? _selectedAudioFile; // Cross-platform file
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAudio();
  }

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

  Future<void> _fetchAudio() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_audio')
          .select('*, tbl_audiocat(audio_name)')
          .order('audio_dt', ascending: false);
      setState(() {
        audioList = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching audio: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedAudioFile = result.files.single;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    }
  }

  Future<void> _uploadAudio() async {
    if (_formKey.currentState!.validate() &&
        _selectedAudioFile != null &&
        selectedCategoryId != null) {
      try {
        setState(() {
          isLoading = true;
        });
        final filePath = 'Uploads/$_fileName';

        // Handle web vs mobile uploads
        if (kIsWeb) {
          // Web: Use bytes
          if (_selectedAudioFile!.bytes != null) {
            await supabase.storage
                .from('audio')
                .uploadBinary(filePath, _selectedAudioFile!.bytes!);
          } else {
            throw Exception('No file bytes available for web upload');
          }
        } else {
          // Mobile: Use File
          if (_selectedAudioFile!.path != null) {
            await supabase.storage
                .from('audio')
                .upload(filePath, File(_selectedAudioFile!.path!));
          } else {
            throw Exception('No file path available for mobile upload');
          }
        }

        // Get the public URL of the uploaded file
        final publicUrl = supabase.storage.from('audio').getPublicUrl(filePath);

        // Insert metadata into tbl_audio, including the URL
        await supabase.from('tbl_audio').insert({
          'audio_dt': DateTime.now().toIso8601String(),
          'audio_file': _fileName,
          'audio_cat': int.parse(selectedCategoryId!),
          'audio_url': publicUrl, // Make sure your table has this column
        });

        setState(() {
          _selectedAudioFile = null;
          _fileName = null;
          selectedCategoryId = null;
        });
        await _fetchAudio();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio uploaded successfully'),
            backgroundColor: Color(0xFFD81B60),
          ),
        );
      } catch (e) {
        print("Error uploading audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading audio: $e'),
            backgroundColor: const Color(0xFFD81B60),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category and audio file'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    }
  }

  Future<void> _deleteAudio(int id, String fileName) async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.storage.from('audio').remove(['uploads/$fileName']);
      await supabase.from('tbl_audio').delete().eq('id', id);
      await _fetchAudio();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio deleted successfully'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    } catch (e) {
      print("Error deleting audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting audio: $e'),
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
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF37474F),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF455A64),
                          style: const TextStyle(color: Color(0xFFECEFF1)),
                          decoration: InputDecoration(
                            label: const Text('Category',
                                style: TextStyle(color: Color(0xFFECEFF1))),
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
                          value: selectedCategoryId,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Select Category',
                                  style: TextStyle(color: Color(0xFFECEFF1))),
                            ),
                            ...categoryList.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['id'].toString(),
                                child: Text(
                                  category['audio_name'],
                                  style:
                                      const TextStyle(color: Color(0xFFECEFF1)),
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickAudioFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF455A64),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFECEFF1)
                                      .withOpacity(0.2)),
                            ),
                            child: Text(
                              _fileName ?? 'Pick Audio File',
                              style: TextStyle(
                                color: _fileName != null
                                    ? const Color(0xFFECEFF1)
                                    : const Color(0xFFECEFF1).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isLoading ? null : _uploadAudio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
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
                    child: audioList.isEmpty
                        ? const Center(
                            child: Text(
                              'No audio files found.',
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
                            itemCount: audioList.length,
                            itemBuilder: (context, index) {
                              final audio = audioList[index];
                              return ListTile(
                                title: Text(
                                  audio['audio_file'],
                                  style: const TextStyle(
                                    color: Color(0xFFECEFF1),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${audio['tbl_audiocat']['audio_name']} - ${DateTime.parse(audio['audio_dt']).toLocal().toString().substring(0, 19)}',
                                  style: TextStyle(
                                    color: const Color(0xFFECEFF1)
                                        .withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _deleteAudio(audio['id'], audio['audio_file']);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFD81B60),
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