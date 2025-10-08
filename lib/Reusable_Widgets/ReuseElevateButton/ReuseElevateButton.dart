import 'package:flutter/material.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseContainer/ReuseContainer.dart';

class ReuseElevatedButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final FontWeight? fontWeight;
  final VoidCallback? onTap;
  final double? borderWidth;
  final TextStyle? style;
  final Color? buttonColor;
  Color? textcolor;
  final double? fontSize;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>?
  gradientColors; // Updated: Accept a list of colors for gradient

  ReuseElevatedButton({
    Key? key,
    required this.text,
    this.width,
    this.height,
    this.onTap,
    this.fontWeight,
    this.borderRadius,
    this.borderWidth,
    this.textcolor,
    this.style,
    this.buttonColor,
    this.fontSize,
    this.gradientColors, // Updated: Added gradientColors parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ReuseContainer(
        height: height ?? 50,
        width: width ?? 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 0.3,
              spreadRadius: 0.5,
              color: Theme.of(context).dividerColor,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).canvasColor,
            width: borderWidth ?? 0,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(40),
          color: buttonColor ?? Colors.white,
        ),
        child: Center(
          child: AppText(
            text,
            color: textcolor ?? Colors.white,

            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
