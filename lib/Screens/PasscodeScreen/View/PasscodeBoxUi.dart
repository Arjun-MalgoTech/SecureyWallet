import 'package:flutter/material.dart';

class PasscodeBoxUi extends StatelessWidget {
  final String digit;
  final bool isCorrect;
  final bool colorCheck;
  final Color? boxColor;

  PasscodeBoxUi(
      {required this.digit,
        required this.isCorrect,
        required this.colorCheck,
        this.boxColor});
  List<String> enteredPasscodeDigits = List.filled(6, '');
  @override
  Widget build(BuildContext context) {
    // print("++++++++++ ${colorCheck ?? ";;;;;;;;"}");

    return Container(
      width: 40, // Adjust the width as needed
      height: 40, // Make it a square box
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: boxColor ??
              Colors
                  .transparent, // Use the border color passed to the widget, or default to black
          width: 1, // Set the width of the border
        ),
        color: Theme.of(context)
            .primaryColorLight, // Use the color passed to the widget
        // Set border color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 14, right: 8),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
        ),
      ),
    );
  }
}