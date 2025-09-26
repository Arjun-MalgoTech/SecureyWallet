import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildGradientIcon(String iconPath, bool isSelected) {
  return ShaderMask(
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: isSelected
            ? [Color(0xFF912ECA), Color(0xFF793CDE)]
            : [Colors.grey, Colors.grey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);
    },
    blendMode: BlendMode.srcIn,
    child: SvgPicture.asset(
      iconPath,
      height: 20,
      width: 20,
      color: Colors.white,
    ),
  );
}

Widget buildGradientLabel(String label, bool isSelected) {
  return ShaderMask(
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: isSelected
            ? [Color(0xFF912ECA), Color(0xFF793CDE)]
            : [Colors.grey, Colors.grey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);
    },
    blendMode: BlendMode.srcIn,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: Colors.white,
      ),
    ),
  );
}
