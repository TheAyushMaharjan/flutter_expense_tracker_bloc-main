import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../widgets/NavbarWidget.dart';
import 'CreateUserPage.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(); // For email input
  final _passwordController = TextEditingController(); // For password input
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of Firebase Auth
  String? _errorMessage; // To hold error messages

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email text field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password text field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Display error message if any
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            // Login button
            // Login button
            // Login button
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage = null; // Reset error message before attempting login
                });

                try {
                  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );

                  // Navigate to HomePage after successful login
                  if (userCredential.user != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const NavbarWidget()),
                          (Route<dynamic> route) => false, // Remove all previous routes
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    // Provide more specific error messages based on Firebase errors
                    if (e.code == 'user-not-found') {
                      _errorMessage = 'No user found for that email.';
                    } else if (e.code == 'wrong-password') {
                      _errorMessage = 'Wrong password provided for that user.';
                    } else {
                      _errorMessage = 'Login failed. Please check your credentials.';
                    }
                  });
                  print('Error: $e'); // Print the error for debugging
                } catch (e) {
                  setState(() {
                    _errorMessage = 'An unexpected error occurred. Please try again.';
                  });
                  print('Error: $e'); // Print the error for debugging
                }
              },
              child: const Text('Login'),
            ),


            const SizedBox(height: 16),

            // Create New User button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateUserPage()),
                );
              },
              child: const Text('Create New User'),
            ),
          ],
        ),
      ),
    );
  }
}
