import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/HomeScreen/HomeScreenView.dart';
import 'package:securywallet/Screens/OnboardingScreen_View/View/OnboardingScreen.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/View/Previous_Home_Screen_View.dart';
import 'package:securywallet/Screens/SwapScreen/View/SwapScreen.dart';
import 'package:securywallet/Screens/User_Chat/View/UserChatSearchView.dart';
import 'package:securywallet/Screens/smart_web_screen/smart_web_view.dart';
import 'package:securywallet/TrendingScreen/trendingView.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';

class AppBottomNav extends StatefulWidget {
  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentTabIndex = 0;
  DateTime? _lastExitAttempt;
  String _privateKey = '';

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.trending_up, 'label': 'Trending'},
    {'icon': Icons.swap_horiz, 'label': 'Swap'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Chat'},
    {'icon': Icons.explore, 'label': 'Discover'},
  ];

  @override
  Widget build(BuildContext context) {
    final localStorage = context.watch<LocalStorageService>();

    return WillPopScope(
      onWillPop: () async {
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
          return false;
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _getCurrentScreen(_currentTabIndex, localStorage),
        bottomNavigationBar: _buildCustomNavBar(),
      ),
    );
  }

  // Custom Bottom Nav with gradient selected icon & label
  Widget _buildCustomNavBar() {
    return Container(
      color: Color(0xFF0D0D1A),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          return _buildTabItem(tab['icon'], tab['label'], index);
        }),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) =>
                      LinearGradient(
                        colors: [Color(0xFFb753d6), Color(0xFFf36bce)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Icon(icon, color: Colors.white, size: 28),
                )
              : Icon(icon, color: Colors.white70, size: 28),

          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) =>
                      LinearGradient(
                        colors: [Colors.white, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
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
            : Onboard();
      case 1:
        return isLoggedIn ? TrendingTokens() : _buildLoginPrompt();
      case 2:
        return isLoggedIn ? SwapScreen() : _buildLoginPrompt();
      case 3:
        return isLoggedIn ? UserChat() : _buildLoginPrompt();
      case 4:
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
