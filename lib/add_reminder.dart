import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine_care/services/localNotication.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final _medicineNameController = TextEditingController();
  String frequency = "EveryDay";
  bool isNotificationOn = false;
  List<Map<String, dynamic>> schedule = [
    {'label': 'After Breakfast', 'dosage': 1.0},
    {'label': 'After Lunch', 'dosage': 1.0},
    {'label': 'After Dinner', 'dosage': 1.0},
  ];
  List<TimeOfDay> reminderTimes = [];
  final List<Map<String, dynamic>> upcomingMedications = [];

  void _updateSchedule(String label, double dosage) => setState(() => schedule.add({'label': label, 'dosage': dosage}));
  void _deleteSchedule(int index) => setState(() => schedule.removeAt(index));
  void _deleteTime(int index) => setState(() => reminderTimes.removeAt(index));

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) setState(() => reminderTimes.add(pickedTime));
  }

  Future<void> _showScheduleDialog() async {
    final labelController = TextEditingController();
    final dosageController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Add Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(labelController, 'Label'),
            const SizedBox(height: 10),
            _buildTextField(dosageController, 'Dosage', TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final label = labelController.text;
              final dosage = double.tryParse(dosageController.text);
              if (label.isNotEmpty && dosage != null) {
                _updateSchedule(label, dosage);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_medicineNameController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated.')));
        return;
      }
      final userId = user.uid;
      final medicineData = {
        'name': _medicineNameController.text,
        'frequency': frequency,
        'schedule': schedule,
        'notificationTimes': reminderTimes.map((time) => '${time.hour}:${time.minute}').toList(),
        'createdAt': Timestamp.now(),
      };
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('medications').add(medicineData);
        _medicineNameController.clear();
        schedule = [
          {'label': 'After Breakfast', 'dosage': 1.0},
          {'label': 'After Lunch', 'dosage': 1.0},
          {'label': 'After Dinner', 'dosage': 1.0},
        ];
        final List<String> notificationTimes = reminderTimes.map((time) => '${time.hour}:${time.minute}').toList();
        LocalNotification.scheduleNotificationsFromStringList(notificationTimes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication reminder saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reminder: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Medicine Name'),
              _buildTextField(_medicineNameController, 'Enter medicine name'),
              _sectionTitle('Frequency'),
              _buildDropdown(['EveryDay', 'Every Week', 'Every Month']),
              _sectionTitle('Schedule'),
              _buildScheduleList(),
              _sectionTitle('Notification'),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: isNotificationOn,
                onChanged: (value) => setState(() => isNotificationOn = value),
              ),
              _sectionTitle('Notification Time'),
              _buildTimeList(),
              Center(child: ElevatedButton(onPressed: _submitForm, child: const Text('Submit'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? type]) {
    return TextField(controller: controller, keyboardType: type, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  }

  Widget _buildDropdown(List<String> items) {
    return DropdownButtonFormField(
      value: frequency,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) => setState(() => frequency = value!),
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildScheduleList() {
    return Column(
      children: [
        ...schedule.asMap().entries.map((e) => ListTile(
          title: Text(e.value['label']),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSchedule(e.key)),
        )),
        TextButton.icon(onPressed: _showScheduleDialog, icon: const Icon(Icons.add), label: const Text('Add Schedule')),
      ],
    );
  }

  Widget _buildTimeList() {
    return Column(
      children: [
        ...reminderTimes.asMap().entries.map((e) => ListTile(
          title: Text(e.value.format(context)),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTime(e.key)),
        )),
        TextButton.icon(onPressed: _pickTime, icon: const Icon(Icons.add), label: const Text('Add Time')),
      ],
    );
  }
}