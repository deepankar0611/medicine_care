import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine_care/add_reminder.dart';
import 'package:medicine_care/login_screen.dart';
import 'package:medicine_care/testing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime today;
  late int currentDayIndex;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentDayIndex = today.weekday - 1;
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _deleteMedication(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(docId)
          .delete();
    }
  }

  Stream<List<DocumentSnapshot>> _getUserMedications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('medications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'User',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Testing()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today, ${DateFormat('d MMM yyyy').format(today)}',
              style: TextStyle(fontSize: 16 * textScale),
            ),
            SizedBox(height: size.height * 0.02),
            _buildWeekCalendar(size, textScale),
            SizedBox(height: size.height * 0.03),
            Text(
              'Upcoming Medications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * textScale),
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(child: _buildMedicationList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminder()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekCalendar(Size size, double textScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = today.add(Duration(days: index - currentDayIndex));
        final dayName = DateFormat('E').format(date);
        final bool isToday = index == currentDayIndex;
        return Expanded(
          child: Column(
            children: [
              Text(
                dayName,
                style: TextStyle(fontSize: 12 * textScale, color: Colors.grey),
              ),
              SizedBox(height: size.height * 0.005),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentDayIndex = index;
                    today = DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1));
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.02),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.red.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isToday ? Colors.red : Colors.black,
                      fontSize: 14 * textScale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMedicationList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getUserMedications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No medications found.'));
        }

        final medications = snapshot.data!;

        return ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            final name = medication['name'];
            final frequency = medication['frequency'];
            final times = (medication['notificationTimes'] as List).join(', ');
            final docId = medication.id;

            return _medicationCard(name, frequency, times, docId);
          },
        );
      },
    );
  }

  Widget _medicationCard(String name, String frequency, String times, String docId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Frequency: $frequency\nTimes: $times'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteMedication(docId),
        ),
      ),
    );
  }
}