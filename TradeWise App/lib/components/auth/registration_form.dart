// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../../models/user_model.dart';
import '../../pages/auth/landing_page.dart';
import 'error_dialog.dart';
import 'passwordfield.dart';

class RegistrationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey; // Pass the form key from the parent page

  const RegistrationForm({
    super.key,
    required this.formKey,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      createUserData();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/nav');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      authError(context, e);
    }
  }

  void createUserData() async {
    try {
      final User? user = auth.currentUser;
      if (user == null) {
        throw Exception(
          "User not logged in",
        );
      }

      final usersCollection = firestore.collection('Users');
      final uid = user.uid;
      final email = user.email!;
      final name = _usernameController.text;

      final userData = UserModel(
        uid: uid,
        name: name,
        email: email,
        balance: 0,
        totalProfit: 0,
        learnProgress: 0.0,
      );

      await userData
          .createUser(usersCollection); // Await the completion of the creation

      Navigator.pop(context);
    } on Exception catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => ErrorDialog(errorMessage: error.toString()),
      );
    } //finally {}
  }

  // ... other methods for handling form input, validation, and submission

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Create a GlobalKey for your Form
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
              return null; // Input is valid
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(controller: _passwordController),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space buttons evenly
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent[50],
                  surfaceTintColor: Colors.blueAccent[50],
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signUserUp();
                  }
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.playfair(
                    fontSize: 18.0, // Set desired font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent[50],
                  surfaceTintColor: Colors.blueAccent[50],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 500),
                      child: const LandingPage(), //returns to previous page
                    ),
                  );
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.playfair(
                    fontSize: 18.0, // Set desired font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> authError(BuildContext context, FirebaseException error) async {
    print(error.code);
    // Create a user-friendly error message based on the error code
    String errorMessage = "";
    switch (error.code) {
      case "invalid-email":
        errorMessage = "Please enter a valid email address.";
        break;
      case "weak-password":
        errorMessage =
            "Your password is too weak. Please create a stronger password.";
        break;
      case "email-already-in-use":
        errorMessage =
            "The email address is already in use by another account.";
        break;
      case "user-not-found":
        errorMessage = "The email address could not be found.";
        break;
      case "invalid-credential":
        errorMessage = "Invalid email or password combination.";
        break;
      case "too-many-requests":
        errorMessage =
            "Too many requests have been made to the server. Please try again later.";
        break;
      default:
        errorMessage =
            "An error occurred during authentication. Please try again later.";
    }

    //Create Alert Dialog using error message
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDialog(errorMessage: errorMessage),
    );
  }
}
