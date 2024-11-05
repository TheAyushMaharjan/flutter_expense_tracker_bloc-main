import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_fonts/google_fonts.dart';
import 'loginpage.dart'; // Import LoginPage for navigation

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user
    final user = FirebaseAuth.instance.currentUser;

    // Extract the email, or set a default if the user is null
    String displayName = user?.email ?? 'No User'; // Fallback if user is null
    String shortEmail = displayName.length > 6 ? displayName.substring(0, 6) : displayName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Name: $shortEmail', // Display the shortened email
          style: GoogleFonts.roboto( // Change to your preferred font
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut(); // Logout from Firebase
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to LoginPage
                  );
                } catch (e) {
                  print('Error logging out: $e'); // Handle errors if necessary
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
