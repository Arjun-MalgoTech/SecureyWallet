import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Crypto_Utils/Wallet_Theme/App_Theme.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';


class CustomIconWidget extends StatelessWidget {
  IconData? iconData;
  final String text;
  final Color? textColor;
  final double? fontSize;
  Widget? image;

  CustomIconWidget(
      {this.iconData,
      required this.text,
      this.textColor,
      this.fontSize,
      this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.height(context, 8),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                image ??
                    Icon(
                      iconData,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      size: 20,
                    ),
                SizedBox(
                  width: SizeConfig.height(context, 2),
                ),
                AppText(
                  text,
                  fontFamily: 'LexendDeca',
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.surfaceBright,
                  fontSize: fontSize ?? 16,
                ),
              ],
            ),
            // Switch for dark mode
            if (text == "Dark Mode") ThemeToggleSwitch()
          ],
        ),
      ),
    );
  }
}
