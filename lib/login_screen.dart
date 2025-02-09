import 'package:flutter/material.dart';
import 'package:medicine_care/chnagePassword.dart';
import 'package:medicine_care/home_page.dart';
import 'package:medicine_care/signup_screen.dart';
import 'package:medicine_care/widget_section.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> login() async {
      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Refresh the user's details to ensure we have the latest emailVerified status
        await userCredential.user?.reload();
        User? updatedUser = FirebaseAuth.instance.currentUser;

        // Check if the email is verified
        if (updatedUser != null && !updatedUser.emailVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                const HomePage()), // Replace with your actual home screen widget
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify your email to log in.')),
          );
          return;
        }
          // Email is verified; navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                const HomePage()), // Replace with your actual home screen widget
          );
      } catch (e) {
        // Handle errors during login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }






    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FA), // Light blue background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo Section
                Padding(
                  padding: EdgeInsets.only(top: screenWidth * 0.1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/png/login.png', // Replace with your logo's asset path
                        height: screenWidth * 0.7,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Login Card
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3366FF), // Blue background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sign up to get started",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Address TextField
                      textEdit(hint: 'Email', controller: emailController),

                      const SizedBox(height: 15),
                      // Password TextField
                      textEdit(hint: 'Password', controller: passwordController),

                      const SizedBox(height: 20),
                      // Login Button
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // // Call the login function when the button is pressed
                            // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                            //   // Show a message to the user
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text('Please enter both email and password'),
                            //     ),
                            //   );
                            //   return;
                            // }
                            //
                            // try {
                            //   // Call the login function
                            //   await FirebaseAuth.instance.signInWithEmailAndPassword(
                            //     email: emailController.text.trim(),
                            //     password: passwordController.text.trim(),
                            //   );
                            //
                            //   // Navigate to the next page or show success message
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text('Login successful!'),
                            //     ),
                            //   );
                            //
                            //   // Navigate to your home page or dashboard
                            //   // Replace `HomePage()` with your actual home screen widget
                            //   Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(builder: (context) => const HomePage()),
                            //   );
                            // } catch (e) {
                            //   // Handle login errors and show them to the user
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text('Error: ${e.toString()}'),
                            //     ),
                            //   );
                            // }
                            login();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3366FF),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Forgot Password
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChangePassword()),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            // Create Account
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                                );
                              },
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
