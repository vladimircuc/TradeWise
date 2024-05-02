// ignore_for_file: use_build_context_synchronously

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

/// ForgotPasswordPopup provides a dialog for users to enter their email address
/// and request a password reset link.
class ForgotPasswordPopup extends StatefulWidget {
  const ForgotPasswordPopup({super.key});

  @override
  State<ForgotPasswordPopup> createState() => _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState extends State<ForgotPasswordPopup> {
  final _emailController =
      TextEditingController(); // Controller for the email input field.

  /// Handles the password reset request by calling Firebase's password reset email function.
  void _handleForgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Shows a confirmation snackbar upon successful email submission.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors specific to Firebase authentication issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forgot Password'), // Dialog title
      content: Column(
        mainAxisSize: MainAxisSize
            .min, // Column size is set to minimum to wrap its content
        children: [
          TextField(
            controller:
                _emailController, // Uses the TextEditingController to manage email input
            decoration: const InputDecoration(
                labelText: 'Email'), // Decorates the TextField with a label
            keyboardType: TextInputType
                .emailAddress, // Sets the keyboard type appropriate for email input
          ),
          const SizedBox(
              height:
                  16), // Provides spacing between the email input field and the button row
          Row(
            mainAxisAlignment: MainAxisAlignment
                .end, // Aligns the buttons to the end of the row
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context), // Closes the dialog on press
                child: const Text('Cancel'),
              ),
              const SizedBox(
                  width:
                      16), // Provides spacing between 'Cancel' and 'Submit' buttons
              ElevatedButton(
                onPressed: () => _handleForgotPassword(_emailController
                    .text), // Submits the email for password reset
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
