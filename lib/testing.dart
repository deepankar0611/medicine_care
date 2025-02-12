import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabaseClient;

import 'edit_profile.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  String name = "User";
  String dob = "";
  String gender = "";
  String bloodType = "";
  String profileImageUrl = "";
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  /// Fetch user profile data from Firestore
  void _fetchProfile() async {
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        name = data['name'] ?? "User";
        dob = data['dob'] ?? "";
        gender = data['gender'] ?? "";
        bloodType = data['bloodType'] ?? "";
        profileImageUrl = data['profileImageUrl'] ?? "";
      });
    }
  }

  /// Pick an image and upload to Supabase Storage
  Future<void> _uploadProfileImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final File file = File(pickedFile.path);
      final String fileName = 'profile_pictures/$userId-${basename(file.path)}';

      // Convert File to Uint8List
      final Uint8List fileBytes = await file.readAsBytes();

      final supabase = supabaseClient.Supabase.instance.client;

      // Upload to Supabase Storage
      await supabase.storage.from('profile_pictures').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const supabaseClient.FileOptions(upsert: true),
      );

      // Get the public URL of the uploaded image
      final String publicUrl = supabase.storage.from('profile_pictures').getPublicUrl(fileName);

      // Update Firestore with the new Supabase image URL
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageUrl': publicUrl,
      });

      setState(() {
        profileImageUrl = publicUrl;
        _isUploading = false;
      });

      print("Profile image updated successfully in Supabase Storage!");
    } catch (e) {
      print("Error uploading image: $e");
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.purple),
                    onPressed: () async {
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            userId: userId!,
                            name: name,
                            dob: dob,
                            gender: gender,
                            bloodType: bloodType,
                          ),
                        ),
                      );

                      if (updatedData != null && mounted) {
                        setState(() {
                          name = updatedData['name'] ?? name;
                          dob = updatedData['dob'] ?? dob;
                          gender = updatedData['gender'] ?? gender;
                          bloodType = updatedData['bloodType'] ?? bloodType;
                        });
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('assets/logo.png') as ImageProvider,
                          ),
                          GestureDetector(
                            onTap: _uploadProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple.withOpacity(0.8),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (_isUploading) const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Date of Birth: $dob", style: GoogleFonts.poppins(fontSize: 16)),
                      Text("Gender: $gender", style: GoogleFonts.poppins(fontSize: 16)),
                      Text("Blood Type: $bloodType", style: GoogleFonts.poppins(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
