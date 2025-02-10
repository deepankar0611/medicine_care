import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String name;
  final String dob;
  final String gender;
  final String bloodType;

  EditProfilePage({
    required this.userId,
    required this.name,
    required this.dob,
    required this.gender,
    required this.bloodType,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  String selectedGender = "Male"; // Default Gender
  String selectedBloodType = "A+"; // Default Blood Type

  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> bloodTypeOptions = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    dobController = TextEditingController(text: widget.dob);
    selectedGender = widget.gender.isNotEmpty ? widget.gender : "Male";
    selectedBloodType = widget.bloodType.isNotEmpty ? widget.bloodType : "A+";
  }

  /// Opens a Date Picker and updates the DOB field
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  void _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'name': nameController.text,
      'dob': dobController.text,
      'gender': selectedGender,
      'bloodType': selectedBloodType,
    }, SetOptions(merge: true));

    Navigator.pop(context, {
      'name': nameController.text,
      'dob': dobController.text,
      'gender': selectedGender,
      'bloodType': selectedBloodType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: "Date of Birth"),
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),

            /// Gender Dropdown
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(labelText: "Gender"),
              items: genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            /// Blood Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedBloodType,
              decoration: const InputDecoration(labelText: "Blood Type"),
              items: bloodTypeOptions.map((String bloodType) {
                return DropdownMenuItem<String>(
                  value: bloodType,
                  child: Text(bloodType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBloodType = value!;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}