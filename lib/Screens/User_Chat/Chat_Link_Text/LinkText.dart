import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatLinkText extends StatelessWidget {
  final String text; // The input text to display

  const ChatLinkText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      buildLinkText(text),
      style: TextStyle(color: Colors.white, fontSize: 16), // Default text style
    );
  }

  // This method builds the TextSpan with links and normal text
  TextSpan buildLinkText(String text) {
    final RegExp linkRegExp = RegExp(
      r"(https?:\/\/[^\s]+)", // Regular expression to detect links
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    text.splitMapJoin(
      linkRegExp,
      onMatch: (match) {
        spans.add(
          TextSpan(
            text: match[0],
            style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = match[0]!;
                // print(url);
                try {
                  await launchUrl(Uri.parse(url));
                } on Exception catch (e) {
                  print("Could not launch: $e");
                  rethrow;
                }
              },
          ),
        );
        return match[0]!;
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return nonMatch;
      },
    );

    return TextSpan(children: spans);
  }
}
