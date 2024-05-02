import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

void main() {
  runApp(const MyApp());
}

/// HomePage is the main UI component where user registration occurs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller for email input
  final _emailController = TextEditingController();
  // Controller for username input
  final _usernameController = TextEditingController();
  // Controller for password input
  final _passwordController = TextEditingController();
  // Controller for confirming password input
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background decoration with an image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              // Semi-transparent container for form elements
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main title with custom Google Fonts styling
                    Text(
                      "TradeWise",
                      style: GoogleFonts.bodoniModa(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(255, 59, 59, 61),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Registration label
                    const Text(
                      "Registration",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Username input field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Hides password input
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Confirm password input field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true, // Hides password input
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
                    // Additional widgets like submit buttons can be added below
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
