import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Launch_Screen/LaunchScreen_View.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_2_View.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_View.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FlutterLocalNotificationsPlugin _notificationPlugin;
  NotificationAppLaunchDetails? _notificationDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _requestIosNotificationPermissions() async {
    final iosPlugin = _notificationPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _setupNotifications() {
    _notificationPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: const DarwinInitializationSettings(),
    );

    _notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payloadData = response.payload;
        if (payloadData != null) {
          _openPayloadUrl(payloadData);
        }
      },
    );

    final launchedFromNotification =
        _notificationDetails?.didNotificationLaunchApp ?? false;

    if (launchedFromNotification) {
      final String? payload =
          _notificationDetails!.notificationResponse?.payload;
      if (payload != null) {
        _openPayloadUrl(payload);
      }
    }
  }

  Future<void> _openPayloadUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: AppText(
          "Create New Wallet",
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          /// Background image
          Align(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Image.asset("assets/Images/bell2.png", height: 300, width: 300),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                AppText(
                  "Keep up with the market!",
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),

                SizedBox(height: SizeConfig.height(context, 1)),

                AppText(
                  "Turn on notifications to keep track of prices and ",
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0XFFB4B1B2),
                ),

                AppText(
                  "receive transaction updates.",
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0XFFB4B1B2),
                ),

                Expanded(child: Spacer()),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                        bottom: 20,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          _setupNotifications();
                          await _requestIosNotificationPermissions();

                          var status = await Permission.notification.request();

                          if (status.isGranted) {
                            // ✅ User pressed Allow
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecureBackup2(),
                              ),
                            );
                          } else {
                            // ❌ User pressed Don’t Allow
                            showDialog(
                              context: context,

                              builder: (ctx) => AlertDialog(
                                backgroundColor: Color(0xFF27292C),
                                title: Center(
                                  child: AppText("Enable Notifications"),
                                ),

                                content: AppText(
                                  "Turn on notifications from Settings to continue.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                    },
                                    child: AppText("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      openAppSettings(); // opens device settings for app
                                      Navigator.pop(ctx);
                                    },
                                    child: AppText("Open Settings"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },

                        child: ReuseElevatedButton(
                          height: SizeConfig.height(context, 7),
                          width: SizeConfig.width(context, 100),
                          text: "Enable Notifications",
                          textcolor: Colors.black,
                          gradientColors: [],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecureBackup2(),
                            ),
                          );
                        },
                        child: AppText(
                          "Skip, I’ll do it later",
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
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

class NotificationPermissionService {
  static Future<void> checkAndRequestNotificationPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.notification.request().isGranted) {
        print("✅ Notification permission granted");
      }
    }
  }
}
