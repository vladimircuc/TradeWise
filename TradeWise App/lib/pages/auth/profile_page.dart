import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

/// ProfilePage displays the current user's email and provides an option to log out.
class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Retrieve the current authenticated user from FirebaseAuth
  final user = FirebaseAuth.instance.currentUser!;

  /// Signs the user out and navigates back to the landing page.
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut(); // Initiates the sign out process
    Navigator.pushReplacementNamed(
        context, '/landing'); // Redirects to the landing page after sign out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Logout button in the AppBar
          IconButton(
            onPressed: () =>
                signUserOut(context), // Calls signUserOut method when pressed
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        // Displaying the user's email in the center of the screen
        child: Text("Logged In As: ${user.email!}"),
      ),
    );
  }
}
