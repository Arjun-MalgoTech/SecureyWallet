import 'package:flutter/material.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppView extends StatefulWidget {
  const AboutAppView({super.key});

  @override
  State<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends State<AboutAppView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).indicatorColor,
          ),
        ),
        title: AppText(
          'About',
          color: Theme.of(context).colorScheme.surfaceBright,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 8.0,
                  bottom: 16.0,
                ),
                child: AppText(
                  'About Us',
                  color: Theme.of(context).colorScheme.surfaceBright,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 8.0,
                  bottom: 16.0,
                ),
                child: AppText(
                  'Privacy Policy',
                  color: Theme.of(context).colorScheme.surfaceBright,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launch('https://nvxowallet.com/terms');
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 8.0,
                  bottom: 16.0,
                ),
                child: AppText(
                  'Terms of Use',
                  color: Theme.of(context).colorScheme.surfaceBright,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 16.0),
              child: AppText(
                'Review the app',
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppText(
                'Version\n0.0.8',
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
