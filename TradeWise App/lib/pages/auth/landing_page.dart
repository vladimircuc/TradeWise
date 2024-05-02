import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/background_container.dart';
import '../../main.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

/// LandingPage serves as the main entry point for new users,
/// providing options to either log in or register.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background container that might be used for visual flair
          const BackgroundContainer(),
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  children: [
                    // Container for the login and register buttons with a semi-transparent background
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Application title
                            Text(
                              "TradeWise",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 59, 59, 61),
                              ),
                            ),
                            const SizedBox(height: 100), // Spacer

                            // Login button
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to LoginPage with a fade transition
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 500),
                                    child: const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(200, 50),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent[50],
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.playfair(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25), // Spacer

                            // Register button
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to RegisterPage with a fade transition
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 500),
                                    child: const RegisterPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(200, 50),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent[50],
                              ),
                              child: Text(
                                'Register',
                                style: GoogleFonts.playfair(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
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
