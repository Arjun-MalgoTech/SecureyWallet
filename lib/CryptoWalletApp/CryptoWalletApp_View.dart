import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/ColorHandlers/Apptheme.dart';
import 'package:securywallet/Crypto_Utils/Wallet_Theme/App_Theme.dart';
import 'package:securywallet/Screens/Launch_Screen/LaunchScreen_View.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class CryptoWalletApp extends StatefulWidget {
  CryptoWalletApp({super.key});

  @override
  State<CryptoWalletApp> createState() => _CryptoWalletAppState();
}

class _CryptoWalletAppState extends State<CryptoWalletApp> {
  late FlutterLocalNotificationsPlugin _notificationPlugin;
  NotificationAppLaunchDetails? _notificationDetails;

  @override
  void initState() {
    super.initState();
    // _setupNotifications();
    // _requestIosNotificationPermissions();
    fetchFcmToken();
    // iOS specific
  }

  String? token;

  fetchFcmToken() async {
    token = await FirebaseMessaging.instance.getToken();

    print("fetchFcmToken : $token");
  }

  // // iOS Notification Permission
  // Future<void> _requestIosNotificationPermissions() async {
  //   final iosPlugin = _notificationPlugin
  //       .resolvePlatformSpecificImplementation<
  //         IOSFlutterLocalNotificationsPlugin
  //       >();
  //
  //   await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  // }
  //
  // // Notifications Setup
  // void _setupNotifications() {
  //   _notificationPlugin = FlutterLocalNotificationsPlugin();
  //
  //   const androidSettings = AndroidInitializationSettings(
  //     '@drawable/ic_notification',
  //   );
  //
  //   final initSettings = InitializationSettings(
  //     android: androidSettings,
  //     iOS: const DarwinInitializationSettings(),
  //   );
  //
  //   _notificationPlugin.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       final payloadData = response.payload;
  //       if (payloadData != null) {
  //         _openPayloadUrl(payloadData);
  //       }
  //     },
  //   );
  //
  //   final launchedFromNotification =
  //       _notificationDetails?.didNotificationLaunchApp ?? false;
  //
  //   if (launchedFromNotification) {
  //     final String? payload =
  //         _notificationDetails!.notificationResponse?.payload;
  //     if (payload != null) {
  //       _openPayloadUrl(payload);
  //     }
  //   }
  // }
  //
  // Future<void> _openPayloadUrl(String url) async {
  //   if (!await launchUrl(Uri.parse(url))) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  ThemeController themeChangeProvider = ThemeController();

  @override

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return GetMaterialApp(
            title: 'SECURY WALLET',
            debugShowCheckedModeBanner: false,
            theme: themeController.isDarkMode
                ? Apptheme.darkThemeData
                : Apptheme.lightThemeData,
            themeMode: themeController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: LaunchScreen(),
          );
        },
      ),
    );
  }

}
