import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_care/home_page.dart';

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
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (userId != null) {
      _fetchProfile();
    }
  }

  /// Fetch user profile data from Firestore
  void _fetchProfile() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? "User";
        dob = doc['dob'] ?? "";
        gender = doc['gender'] ?? "";
        bloodType = doc['bloodType'] ?? "";
      });
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

                      /// **Check if data was updated and refresh the UI**
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
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
