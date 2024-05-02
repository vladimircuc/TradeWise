import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/auth/registration_form.dart';
import '../../components/background_container.dart';
import '../../main.dart';

void main() {
  runApp(const MyApp());
}

/// RegisterPage provides a user interface for user registration.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Global key for the form to manage form state and validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background container for a consistent design theme
          const BackgroundContainer(),
          // SingleChildScrollView ensures the form is scrollable when the keyboard is visible
          SingleChildScrollView(
            child: SafeArea(
              // Padding around the content to give it visual space
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                // Column for linearly arranging text and form widgets
                child: Column(
                  children: [
                    // Container to style the registration form area
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.8), // Semi-transparent white background
                        borderRadius: BorderRadius.circular(
                            10.0), // Rounded corners for soft visual edges
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            30.0), // Padding inside the container for content spacing
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the start of the axis
                          children: [
                            // Application title with custom Google Fonts styling
                            Text(
                              "TradeWise",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(
                                    255, 59, 59, 61), // Dark color for contrast
                              ),
                            ),
                            const SizedBox(
                                height: 16), // Spacer for vertical spacing
                            // Page or section title for registration
                            Text(
                              "Registration",
                              style: GoogleFonts.playfair(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    30), // Additional spacer for form fields
                            // The registration form is encapsulated in this widget
                            RegistrationForm(
                              formKey:
                                  _formKey, // Passing the formKey to manage form validation
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
