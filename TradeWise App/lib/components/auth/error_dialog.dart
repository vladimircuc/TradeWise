import 'package:flutter/material.dart';

/// ErrorDialog is a StatelessWidget that creates a modal dialog to display error messages.
/// It is designed to be used throughout the application to show errors in a consistent format.
class ErrorDialog extends StatelessWidget {
  /// The error message to display within the dialog.
  final String errorMessage;

  /// Constructs an ErrorDialog widget.
  ///
  /// [errorMessage] is the message that will be displayed inside the dialog.
  const ErrorDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Defines the shape of the dialog with rounded corners.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),

      // The title of the dialog styled to indicate an error.
      title: const Text(
        "Error",
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),

      // The content of the dialog which is the error message passed to the widget.
      content: Text(errorMessage),

      // A list of actions, typically buttons, to provide mechanisms for user interaction.
      actions: [
        // A text button that closes the dialog. The 'OK' button allows the user to dismiss the dialog.
        TextButton(
          onPressed: () =>
              Navigator.pop(context), // This will close the dialog when tapped.
          style: ButtonStyle(
            // Setting the foreground color for the button.
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
