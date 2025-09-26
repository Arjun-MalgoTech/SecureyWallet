import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Constant_Image.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/HomeScreen/Carousel_Slider/CarouselSlider.dart';
import 'package:securywallet/Screens/Receive_Asset_View/View/ReceiveAssetView.dart';
import 'package:securywallet/Screens/Send_Asset_View/View/SendAssetView.dart';
import 'package:url_launcher/url_launcher.dart';

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
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF262737)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    ConstantImage.imgArrowRightLightBlueA200,
                    color: Color(0XFFB982FF),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.height(context, 2),
            ),
            AppText(
              "Send",
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surfaceBright,
              fontSize: 12,
            )
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
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF262737)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    ConstantImage.downarrow,
                    color: Color(0XFFB982FF),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.height(context, 2),
              ),
              AppText(
                "Receive",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 12,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            launch('https://www.bitnevex.com/');
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF262737)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    ConstantImage.buy,
                    color: Color(0XFFB982FF),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.height(context, 2),
              ),
              AppText(
                "Buy",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 12,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            launch('https://www.bitnevex.com/');
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF262737)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    ConstantImage.earn,
                    color: Color(0XFFB982FF),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.height(context, 2),
              ),
              AppText(
                "Earn",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget boyImage() {
  return Image.asset(
    "assets/Images/boy.png",
  );
}

Widget bannerImage(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
    child: CarouselAdSlider(
      [
        GestureDetector(
          onTap: () {
            launch('https://www.bitnevex.com/');
          },
          child: Image.asset('assets/Images/newban2.jpg',
              width: SizeConfig.width(context, 100), fit: BoxFit.fill),
        ),
        GestureDetector(
          onTap: () {
            launch('https://nvxowallet.com/');
          },
          child: Image.asset('assets/Images/newnavban.png',
              width: SizeConfig.width(context, 100), fit: BoxFit.fill),
        ),
      ],
    ),
  );
}
