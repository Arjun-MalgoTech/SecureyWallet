import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/HomeScreen/HomeScreenView.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/View/Previous_Home_Screen_View.dart';
import 'package:securywallet/Screens/SwapScreen/View/SwapScreen.dart';
import 'package:securywallet/Screens/User_Chat/View/UserChatSearchView.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/Icon_Ui.dart';
import 'package:securywallet/Screens/smart_web_screen/smart_web_view.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';

class AppBottomNav extends StatefulWidget {
  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentTabIndex = 0;
  DateTime? _lastExitAttempt;
  String _privateKey = '';

  @override
  Widget build(BuildContext context) {
    final localStorage = context.watch<LocalStorageService>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastExitAttempt == null ||
            now.difference(_lastExitAttempt!) > Duration(seconds: 2)) {
          _lastExitAttempt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Press again to exit"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF271952),
        body: _getCurrentScreen(_currentTabIndex, localStorage),
        bottomNavigationBar: _buildBlurredNavBar(),
      ),
    );
  }

  Widget _buildBlurredNavBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      padding: EdgeInsets.only(
        bottom: Platform.isIOS ? 15 : 10,
        top: Platform.isIOS ? 15 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem('assets/Images/home_icon.svg', 'Home', 0),
              _buildTabItem('assets/Images/chat.svg', 'Chat', 1),
              _buildTabItem('assets/Images/swap.svg', 'Swap', 2),
              _buildTabItem('assets/Images/browser.svg', 'Browser', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String icon, String label, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 4, vertical: isSelected ? 6 : 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white30 : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: buildGradientIcon(icon, isSelected),
          ),
          const SizedBox(height: 4),
          buildGradientLabel(label, isSelected),
        ],
      ),
    );
  }

  Widget _getCurrentScreen(int index, LocalStorageService storage) {
    final isLoggedIn = storage.activeWalletData != null;

    switch (index) {
      case 0:
        return isLoggedIn
            ? HomeView(privateKey: _privateKey, dollar: "")
            : PreHome();
      case 1:
        return isLoggedIn ? UserChat() : _buildLoginPrompt();
      case 2:
        return isLoggedIn ? SwapScreen() : _buildLoginPrompt();
      case 3:
        return SmartWebView();
      default:
        return HomeView(privateKey: _privateKey, dollar: "");
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: GradientAppText(
        text: "Please Create or Import an Wallet",
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
