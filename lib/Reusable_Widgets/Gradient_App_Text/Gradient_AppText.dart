import 'package:flutter/material.dart';

class GradientAppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;

  const GradientAppText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.2174, 0.5403, 0.8528],
          colors: [
            Color(0xFF6b9dfe),
            Color(0xFF7e5ef8),
            Color(0xFF893cf5),
            Color(0xFFf962c9),
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontFamily: 'BricolageGrotesque',
          fontWeight: fontWeight ?? FontWeight.w300,
        ),
      ),
    );
  }
}
