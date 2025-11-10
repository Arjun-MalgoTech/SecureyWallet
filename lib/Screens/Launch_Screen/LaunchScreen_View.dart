import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Wallet_Theme/App_Theme.dart';
import 'package:securywallet/Screens/OnboardingScreen_View/View/OnboardingScreen.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeScreen.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  LocalStorageService localStorageService = LocalStorageService();
  VaultStorageService vaultStorageService = VaultStorageService();
  ThemeController themeChangeProvider = ThemeController();

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // initialize video controller
    _controller = VideoPlayerController.asset("assets/GIF/secury6.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(false); // play once
        _controller.play();
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocalStorageService>(context, listen: false).getData();
    });

    _navigateBasedOnPasscode();
  }

  void _navigateBasedOnPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');
    final isPasscodeSet = savedPasscode != null && savedPasscode.isNotEmpty;

    if (localStorageService.isLoading == false) {
      // wait until video finishes or fallback to fixed delay
      Future.delayed(Duration(seconds: Platform.isIOS ? 3 : 4), () async {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return isPasscodeSet &&
                      localStorageService.activeWalletData != null
                  ? PasscodeScreen(
                      name: '',
                      data: localStorageService.activeWalletData!,
                      splash: true,
                    )
                  : Onboard();
            },
          ),
        );

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   NotificationPermissionService.checkAndRequestNotificationPermission();
        // });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    themeChangeProvider = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
