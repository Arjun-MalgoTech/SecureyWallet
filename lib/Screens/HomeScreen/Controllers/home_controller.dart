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

Widget iconRow(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 26.0, right: 26),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SendAssetsPage(),
                  ),
                );
              },
              child: // Required for ImageFilter
              SvgPicture.asset(
                ConstantImage.arrowup,
              ),
            ),
            SizedBox(height: SizeConfig.height(context, 1)),
            AppText(
              "Send",
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.surfaceBright,
              fontSize: 14,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceiveAssetPage()),
            );
          },
          child: Column(
            children: [
              SvgPicture.asset(ConstantImage.arrowdown),

              SizedBox(height: SizeConfig.height(context, 1)),
              AppText(
                "Receive",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 14,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              SvgPicture.asset(ConstantImage.crevon),

              SizedBox(height: SizeConfig.height(context, 1)),
              AppText(
                "Fund",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 14,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              SvgPicture.asset(ConstantImage.Dollar),

              SizedBox(height: SizeConfig.height(context, 1)),
              AppText(
                "Sell",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
