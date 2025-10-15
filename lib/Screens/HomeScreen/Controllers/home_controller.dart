import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Constant_Image.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/HomeScreen/Carousel_Slider/CarouselSlider.dart';
import 'package:securywallet/Screens/Receive_Asset_View/View/ReceiveAssetView.dart';
import 'package:securywallet/Screens/Send_Asset_View/View/SendAssetView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

Widget iconRow(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isTablet = screenWidth > 600;

  // scale icons & text based on device size
  final iconScale = isTablet ? 2.0 : 1.0;
  final textScale = isTablet ? 2.0 : 1.0;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconItem(
          context,
          label: "Send",
          iconWidget: SvgPicture.asset(
            "assets/Images/send5.svg",
            width: 42 * iconScale,
            height: 42 * iconScale,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SendAssetsPage()),
            );
          },
          textScale: textScale,
        ),
        _iconItem(
          context,
          label: "Receive",
          iconWidget: SvgPicture.asset(
            ConstantImage.arrowdown,
            width: 42 * iconScale,
            height: 42 * iconScale,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceiveAssetPage()),
            );
          },
          textScale: textScale,
        ),
        _iconItem(
          context,
          label: "Fund",
          iconWidget: SvgPicture.asset(
            ConstantImage.crevon,
            width: 42 * iconScale,
            height: 42 * iconScale,
          ),
          onTap: () {},
          textScale: textScale,
        ),
        _iconItem(
          context,
          label: "Sell",
          iconWidget: SvgPicture.asset(
            ConstantImage.Dollar,
            width: 42 * iconScale,
            height: 42 * iconScale,
          ),
          onTap: () {},
          textScale: textScale,
        ),
      ],
    ),
  );
}

Widget _iconItem(
    BuildContext context, {
      required String label,
      required Widget iconWidget,
      required VoidCallback onTap,
      required double textScale,
    }) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        iconWidget,
        SizedBox(height: SizeConfig.height(context, 0.5)),
        AppText(
          label,

          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.surfaceBright,
          fontSize: 14 * textScale,
        ),
      ],
    ),
  );
}





