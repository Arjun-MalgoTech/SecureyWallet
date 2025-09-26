import 'package:flutter/material.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotification extends StatefulWidget {
  final bool notificationStatus;
  const UserNotification({super.key, required this.notificationStatus});

  @override
  State<UserNotification> createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  bool _isSwitchOn = false;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _isSwitchOn = widget.notificationStatus;
    });
    super.initState();
  }

  Future<void> notificationStore(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ApiKeyService.notificationStatus, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          'Preference',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
                decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 0.3),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Allow push notification',
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    AppText(
                      'Get notified when sending a transaction',
                      // fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ],
                ),
                Switch(
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Color(0xFFB982FF),
                  inactiveTrackColor: Colors.grey[350],
                  value: _isSwitchOn,
                  onChanged: (value) {
                    setState(() {
                      _isSwitchOn = value;
                    });
                    notificationStore(_isSwitchOn);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
