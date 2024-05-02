import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: _buildRequirementsIcon(), // Always display the icon
      ),
      keyboardType:
          TextInputType.visiblePassword, // Avoid unintentional filtering
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        } else if (!RegExp(
                r"^^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()-])[a-zA-Z0-9!@#$%^&*()-]{8,32}$")
            .hasMatch(value)) {
          return 'Please enter a valid password.';
        }
        return null; // Input is valid
      },
    );
  }

  Widget _buildRequirementsIcon() {
    return IconButton(
      icon: const Icon(Icons.info),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => const RequirementsPopup(),
        );
      },
    );
  }
}

class RequirementsPopup extends StatelessWidget {
  //Temporary
  const RequirementsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'Password must be at least 8 characters long and include:\n'
        '  * Uppercase letter (A-Z)\n'
        '  * Lowercase letter (a-z)\n'
        '  * Number (0-9)\n'
        '  * Special character (@\$!%*?&)',
        textAlign: TextAlign.center,
      ),
    );
  }
}
