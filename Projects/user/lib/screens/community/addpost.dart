import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:user/main.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _contentController = TextEditingController();
  bool isSubmitting = false;
  String? errorMessage;
  bool _showImageOptions = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _showImageOptions = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image. Please try again.')),
      );
    }
  }

  void _showImageSourceOptions() {
    setState(() {
      _showImageOptions = true;
    });
  }

  Future<String?> _uploadImage() async {
    try {
      if (_image == null) return null;

      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm-ss').format(DateTime.now());
      String fileExtension = path.extension(_image!.path);
      String fileName = 'post-$formattedDate$fileExtension';

      await supabase.storage.from('post').upload(fileName, _image!);
      final imageUrl = supabase.storage.from('post').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      throw e;
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _image == null) {
      setState(() {
        errorMessage = 'Please add some text or an image to your post';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage();
      }

      await supabase.from('tbl_post').insert({
        'post_content': _contentController.text.trim(),
        'post_file': imageUrl,
        'post_datetime': DateTime.now().toIso8601String(),
        'user_id': supabase.auth.currentUser!.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Post created successfully!",
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.pink.shade300, // Match theme
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = 'Failed to create post. Please try again.';
      });
      print("Error creating post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Match Forum background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Match Forum gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Create Post',
          style: GoogleFonts.pacifico( // Match Forum title style
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28), // Match Forum back button style
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: isSubmitting ? null : _createPost,
              child: isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      'Post',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_showImageOptions) setState(() => _showImageOptions = false);
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.purple.shade100.withOpacity(0.2), // Match Forum avatar
                          child: Icon(
                            Icons.person,
                            color: Colors.purple.shade600, // Match Forum avatar color
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share with the community',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.purple.shade600, // Match theme
                              ),
                            ),
                            Text(
                              'Your post will be visible to all members',
                              style: GoogleFonts.nunito(
                                color: Colors.grey[600], // Match Forum subtitle
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16), // Match Forum text field
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.nunito(
                            color: Colors.purple.shade600, // Match Forum label
                            fontSize: 18,
                          ),
                        ),
                        maxLines: 10,
                        minLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey[800]), // Match Forum text
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_image != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16), // Match Forum card shape
                            child: Image.file(
                              _image!,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() => _image = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade600, // Match theme
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.shade400.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.nunito(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Add to your post:',
                      style: GoogleFonts.nunito(
                        color: Colors.purple.shade600, // Match theme
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: Icon(
                          Icons.photo,
                          color: Colors.purple.shade600, // Match theme
                          size: 30,
                        ),
                        onPressed: _showImageSourceOptions,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showImageOptions)
              Positioned(
                bottom: 80,
                left: 20,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), // Match Forum card shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade100.withOpacity(0.5), // Match Forum shadow
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library, color: Colors.purple.shade600), // Match theme
                        title: Text(
                          'Gallery',
                          style: GoogleFonts.nunito(
                            color: Colors.purple.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      ListTile(
                        leading: Icon(Icons.camera_alt, color: Colors.purple.shade600), // Match theme
                        title: Text(
                          'Camera',
                          style: GoogleFonts.nunito(
                            color: Colors.purple.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}