import 'package:flutter/material.dart';

Widget textEdit({required String hint, required TextEditingController controller}) {
  return TextField(
    controller: controller, // Bind the controller
    obscureText: hint.toLowerCase().contains('password'), // Obscure text for password fields
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFF3366FF), // Background color of the TextField
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70), // Hint text color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border for default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white), // White border when not focused
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white, width: 2), // White border when focused
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    style: const TextStyle(color: Colors.white), // Text color
  );
}
