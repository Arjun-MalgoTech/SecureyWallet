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
            Color(0xFF912ECA),
            Color(0xFF912ECA),
            Color(0xFF793CDE),
            Color(0xFF793CDE),
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontFamily: 'LexendDeca',
          fontWeight: fontWeight ?? FontWeight.w300,
        ),
      ),
    );
  }
}
