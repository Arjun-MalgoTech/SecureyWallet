import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: SizeConfig.height(context, 5),
          ),
          Image.asset(
            "assets/Images/launch.png",
          ),
          SizedBox(
            height: SizeConfig.height(context, 5),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Color(0xFF912ECA),
                    Color(0xFF912ECA),
                    Color(0xFF793CDE),
                    Color(0xFF793CDE),
                  ], // Default (no gradient)
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              blendMode:
                  BlendMode.srcIn, // Ensures the gradient applies correctly
              child: Row(
                children: [
                  AppText(
                    "YOUR ONE-STOP \n WEB3 WALLET",
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return AppBottomNav();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32),
                child: ReuseElevatedButton(
                  height: SizeConfig.height(context, 7),
                  width: SizeConfig.width(context, 100),
                  text: "Get Started",
                  textcolor: Colors.black,
                  gradientColors: [],
                ),
              )),
          SizedBox(
            height: SizeConfig.height(context, 5),
          ),
          AppText(
            "By Tapping “Get Started” You Agree And Consent To Our",
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  launch('https://nvxowallet.com/terms');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppText(
                    "Term Of Service",
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF912ECA),
                  ),
                ),
              ),
              AppText(
                " And ",
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              GestureDetector(
                onTap: () {
                  launch('https://nvxowallet.com/privacy-policy');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppText(
                    "Privacy Policy",
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF912ECA),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
