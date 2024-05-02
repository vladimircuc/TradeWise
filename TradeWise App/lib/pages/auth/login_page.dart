import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/auth/login_form.dart';
import '../../components/background_container.dart';
import '../../main.dart';

void main() {
  runApp(const MyApp());
}

/// LoginPage provides a user interface for logging into the application.
/// It utilizes a custom form to handle user credentials input.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Global key used to identify the form and manage form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to layer a background container and the form
      body: Stack(
        children: [
          // Reusable background container that might include visual elements or styles
          const BackgroundContainer(),
          // SingleChildScrollView to ensure the form is scrollable on smaller devices
          SingleChildScrollView(
            child: SafeArea(
              // Padding to provide ample space around the form, making it visually appealing
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                // Column to align form and text vertically
                child: Column(
                  children: [
                    // Container for the login form with a semi-transparent background
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // Padding inside the container to space out elements within
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Application title with custom font styling
                            Text(
                              "TradeWise",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 59, 59, 61),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Page or section title
                            Text(
                              "Login",
                              style: GoogleFonts.playfair(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                                height: 30), // Spacer for better layout
                            // LoginForm is a custom widget encapsulating the form fields and logic
                            LoginForm(
                              formKey:
                                  _formKey, // Pass the form key for validation
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
