import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Custom_Icon_Widget/Custom_Icon_Widget.dart';
import 'package:securywallet/Screens/About_App_Screen/About_App_View.dart';
import 'package:securywallet/Screens/App_Drawer/User_Notification.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/WalletConnectFunctions/WalletConnectPage.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  WalletConnectionRequest? walletConnectionRequest;
  AppDrawer({super.key, this.walletConnectionRequest});

  Widget _divider() {
    return const Divider(
      thickness: 0.5,
      color: Color(0xFF404040),
      height: 0,
    );
  }

  void _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest?.initializeContext(context);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: SizeConfig.height(context, 4)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  const SizedBox(width: 100),
                  AppText(
                    'Settings',
                    color: Theme.of(context).colorScheme.surfaceBright,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            _divider(),
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var status =
                    prefs.getBool(ApiKeyService.notificationStatus) ?? true;
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UserNotification(notificationStatus: status),
                    ),
                  );
                }
              },
              child: CustomIconWidget(
                iconData: Icons.settings,
                text: "Preferences",
              ),
            ),
            if (localStorageService.activeWalletData != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WalletConnectPage(
                        selectedWalletData:
                            localStorageService.activeWalletData!,
                      ),
                    ),
                  );
                },
                child: CustomIconWidget(
                  image: Image.asset(
                    "assets/Images/connectwallet.png",
                    height: 25,
                    errorBuilder: (_, __, ___) => AppText(
                      'w',
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  text: "Wallet Connect",
                ),
              ),
            _divider(),
            InkWell(
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'info@Bitnevexapp.io',
                  query: 'subject=Support Request',
                );
                try {
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    throw 'Could not launch $emailLaunchUri';
                  }
                } catch (e) {
                  debugPrint('Error launching email: $e');
                }
              },
              child: CustomIconWidget(
                iconData: Icons.headphones,
                text: "Support",
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AboutAppView())),
              child: CustomIconWidget(
                iconData: Icons.security,
                text: "About",
              ),
            ),
            _divider(),
            SizedBox(height: SizeConfig.height(context, 1)),
            _socialLink(
              context,
              icon: SvgPicture.asset("assets/Images/x.svg",
                  height: 14,
                  width: 14,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'x',
              url: 'https://x.com/bitnevex?t=VIifapquj4B4pb83b3tY7g&s=09',
            ),
            _socialLink(
              context,
              icon: Image.asset("assets/Images/insta.png",
                  height: 16,
                  width: 16,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'Instagram',
              url:
                  'https://www.instagram.com/bitnevex?utm_source=qr&igsh=MW8xYjZvazlxOTF0YQ==',
            ),
            _socialLink(
              context,
              icon: SvgPicture.asset("assets/Images/telegram.svg",
                  height: 16,
                  width: 16,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'Telegram',
              url: 'https://t.me/bitnevex',
            ),
            _socialLink(
              context,
              icon: SvgPicture.asset("assets/Images/discord.svg",
                  height: 20,
                  width: 20,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'Discord',
              url: 'https://discord.gg/GSkPd2Ve',
            ),
            _socialLink(
              context,
              icon: SvgPicture.asset("assets/Images/youtube.svg",
                  height: 14,
                  width: 14,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'Youtube',
              url: 'http://www.youtube.com/@bitnevex',
            ),
            _socialLink(
              context,
              icon: Image.asset("assets/Images/tiktok.png",
                  height: 23,
                  width: 23,
                  color: Theme.of(context).colorScheme.surfaceBright),
              text: 'TikTok',
              url: 'https://www.tiktok.com/@bitn3v3x?_t=8sNAN9uLUsJ&_r=1',
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialLink(BuildContext context,
      {required Widget icon, required String text, required String url}) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            icon,
            SizedBox(width: SizeConfig.width(context, 4)),
            AppText(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
