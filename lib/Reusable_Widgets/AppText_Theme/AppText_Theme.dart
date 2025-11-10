import 'package:flutter/material.dart';

class AppText extends StatefulWidget {
  final String data;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const AppText(
      this.data, {
        Key? key,
        this.fontWeight = FontWeight.normal,
        this.fontSize = 16,
        this.color,
        this.decoration,
        this.textAlign,
        this.style,
        this.overflow,
        this.letterSpacing,
      }) : super(key: key);

  @override
  State<AppText> createState() => _AppTextState();
}

class _AppTextState extends State<AppText> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / 375).clamp(1.0, 1.3);
    final adjustedFontSize = (widget.fontSize ?? 16) * scaleFactor;

    return Text(
      widget.data,
      textAlign: widget.textAlign ?? TextAlign.left,
      style: widget.style ??
          TextStyle(
            decoration: widget.decoration,
            color:
            widget.color ?? Theme.of(context).colorScheme.surfaceBright,
            fontFamily: 'BricolageGrotesque',
            fontSize: adjustedFontSize,
            letterSpacing: widget.letterSpacing,
            overflow: widget.overflow,
            fontWeight: widget.fontWeight,
          ),
      overflow: widget.overflow,
    );
  }
}
