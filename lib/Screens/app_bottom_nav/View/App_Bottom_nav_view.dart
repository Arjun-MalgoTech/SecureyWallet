import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/HomeScreen/HomeScreenView.dart';
import 'package:securywallet/Screens/OnboardingScreen_View/View/OnboardingScreen.dart';
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
    {'icon': 'assets/Images/homepic.svg', 'label': 'Home'},
    {'icon': 'assets/Images/trending.svg', 'label': 'Trending'},
    {'icon': 'assets/Images/exchange.svg', 'label': 'Swap'},
    {'icon': 'assets/Images/comment.svg', 'label': 'Chat'},
    {'icon': 'assets/Images/compass.svg', 'label': 'Discover'},
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
        bottomNavigationBar: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildCustomNavBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      color: Color(0xFF0D0D1A),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          return _buildTabItem(tab['icon'], tab['label'], index);
        }),
      ),
    );
  }

  Widget _buildTabItem(String svgPath, String label, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            child: isSelected
                ? ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Color(0xFFb753d6), Color(0xFFf36bce)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: SvgPicture.asset(
                svgPath,
                color: Colors.white,
              ),
            )
                : SvgPicture.asset(
              svgPath,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
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
        text: "Please Create or Import a Wallet",
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
