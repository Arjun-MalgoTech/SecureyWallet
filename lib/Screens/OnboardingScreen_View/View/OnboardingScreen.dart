import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
import 'package:securywallet/Screens/NotificationScreen/notificationView.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_View.dart';
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
              children: [
                SizedBox(height: SizeConfig.height(context, 13)),
                Row(children: [Image.asset("assets/Images/secury.png")]),

                SizedBox(height: SizeConfig.height(context, 3)),

                Row(
                  children: [
                    AppText(
                      "Welcome to \nSecury Wallet!",
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.height(context, 2)),

                Row(
                  children: [
                    AppText(
                      "By Tapping “Get Started” You Agree And Consent To Our",
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.height(context, 0.2)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: AppText(
                        "Term Of Service",
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF912ECA),
                      ),
                    ),
                    AppText(" And ", fontWeight: FontWeight.w700, fontSize: 12),
                    GestureDetector(
                      onTap: () {},
                      child: AppText(
                        "Privacy Policy",
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF912ECA),
                      ),
                    ),
                  ],
                ),

                Expanded(child: Spacer()),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
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
                          width: SizeConfig.width(context, 90),
                          text: "Create New Wallet",
                          textcolor: Colors.black,
                          gradientColors: [],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SecureBackup();
                              },
                            ),
                          );
                        },
                        child: AppText(
                          "I already have a wallet",
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Button fixed at bottom
        ],
      ),
    );
  }
}
