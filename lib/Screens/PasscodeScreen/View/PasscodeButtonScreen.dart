import 'dart:io';

import 'package:flutter/material.dart';

class PasscodeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final double borderRadius;
  final Color labelColor;
  final bool isDeleteButton;
  final bool isFingerPrintButton;

  PasscodeButton({
    required this.label,
    this.onPressed,
    this.backgroundColor = Colors.purple,
    this.borderRadius = 50.0,
    required this.labelColor,
    this.isDeleteButton = false,
    this.isFingerPrintButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: isFingerPrintButton && Platform.isIOS ? null : onPressed,
          child: Container(
            width: isDeleteButton
                ? borderRadius * 1.5
                : borderRadius * 1.5, // Adjust width for delete button
            height: isDeleteButton
                ? borderRadius * 1.5
                : borderRadius * 1.5, // Adjust height for delete button
            child: Center(
              child: isDeleteButton
                  ? Icon(
                      Icons.backspace,
                      size: 24,
                      color: labelColor,
                    )
                  : isFingerPrintButton && Platform.isIOS
                      ? SizedBox()
                      : isFingerPrintButton
                          ? Icon(
                              Icons.fingerprint,
                              size: 40,
                              color: labelColor,
                            )
                          : Text(
                              label,
                              style: TextStyle(
                                  fontSize: 30,
                                  color: labelColor,
                                  fontWeight: FontWeight.w300),
                            ),
            ),
          ),
        ),
      ),
    );
  }
}
