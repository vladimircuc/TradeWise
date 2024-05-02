import 'package:flutter/material.dart';

/// NotificationButton is a StatelessWidget that creates a customized button.
/// It is designed to trigger a specific action and display a text label.
class NotificationButton extends StatelessWidget {
  /// Constructs a NotificationButton widget.
  ///
  /// [onPressed] is the function to execute when the button is tapped.
  /// [text] is the label displayed on the button.
  const NotificationButton({
    required this.onPressed, // The callback function to execute on button press
    required this.text, // The text label displayed on the button
    super.key,
  });

  final VoidCallback onPressed; // Callback for button press action
  final String text; // Text to be displayed on the button

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding to provide space around the button
      padding: const EdgeInsets.only(right: 55, left: 55, top: 5, bottom: 5),
      child: SizedBox(
        width: MediaQuery.of(context)
            .size
            .width, // Button width is responsive to screen width
        height: 70, // Fixed height for uniformity
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Button background color
              elevation: 5.0, // Shadow intensity under the button
              shape: RoundedRectangleBorder(
                side: BorderSide.none, // No border side
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for aesthetics
              )),
          onPressed:
              onPressed, // Execute the provided callback function on press
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15), // Styling for the button text
          ),
        ),
      ),
    );
  }
}
