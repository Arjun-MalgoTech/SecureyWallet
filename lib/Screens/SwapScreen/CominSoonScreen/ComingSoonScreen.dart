import 'package:flutter/material.dart';

class ComingSoon extends StatefulWidget {
  const ComingSoon({Key? key}) : super(key: key);

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        child: const Text(
          'COMING SOON',
          style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black),
        ),
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.2174, 0.5403, 0.8528],
          colors: [
            Color(0xFF912ECA),
            Color(0xFF912ECA),
            Color(0xFF793CDE),
            Color(0xFF793CDE),
          ],
        ).createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
      ),
    );
  }
}
