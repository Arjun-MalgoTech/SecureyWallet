import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/NotificationScreen/notificationView.dart';
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
      body: Stack(
        children: [
          /// Background image
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/Images/back.png",
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          /// Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig.height(context, 13)),
                Image.asset("assets/Images/secury.png"),

                SizedBox(height: SizeConfig.height(context, 3)),

                AppText(
                  "Welcome to \nSecury Wallet!",
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                ),

                SizedBox(height: SizeConfig.height(context, 2)),

                AppText(
                  "By Tapping “Get Started” You Agree And Consent To Our",
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                    AppText(" And ", fontWeight: FontWeight.w700, fontSize: 12),
                    GestureDetector(
                      onTap: () {},
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
          ),

          /// Button fixed at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NotificationScreen();
                      },
                    ),
                  );
                },
                child: ReuseElevatedButton(
                  height: SizeConfig.height(context, 7),
                  width: SizeConfig.width(context, 100),
                  text: "Get Started",
                  textcolor: Colors.black,
                  gradientColors: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
