import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import '../../pages/auth/landing_page.dart';
import 'error_dialog.dart';
import 'forgot_password.dart';

// ignore_for_file: use_build_context_synchronously

/// LoginForm is a StatefulWidget that handles user authentication.
class LoginForm extends StatefulWidget {
  /// The formKey is used to identify and validate the form.
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.formKey,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Initiates user sign-in using Firebase Authentication.
  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pop(context); // Close the progress dialog
      Navigator.pushReplacementNamed(
          context, '/nav'); // Navigate to the main page
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the progress dialog on error
      authError(context, e); // Handle the error by displaying a dialog
    }
  }

  /// Displays an error dialog when authentication fails.
  Future<void> authError(BuildContext context, FirebaseException error) async {
    String errorMessage =
        "An error occurred during authentication. Please try again later.";
    // Custom error messages based on Firebase Auth exception codes
    switch (error.code) {
      case "user-not-found":
        errorMessage = "No user found for that email.";
        break;
      case "wrong-password":
        errorMessage = "Wrong password provided for that user.";
        break;
      case "invalid-email":
        errorMessage = "The email address is not valid.";
        break;
      default:
        break;
    }

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(errorMessage: errorMessage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey, // Use the form key passed from the parent widget
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address.';
              } else if (!RegExp(
                      r"^[a-zA-Z0-9.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                  .hasMatch(value)) {
                return 'Please enter a valid email address format.';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      const ForgotPasswordPopup(),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    signUserIn();
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  duration: const Duration(milliseconds: 500),
                  child: const LandingPage(),
                ),
              );
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
