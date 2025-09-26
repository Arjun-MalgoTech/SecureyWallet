import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme state manager using ChangeNotifier
class ThemeController with ChangeNotifier {
  final ThemePreferences _preferences = ThemePreferences();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeController() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    _isDarkMode = await _preferences.getTheme();
    print("Theme loaded: $_isDarkMode");
    notifyListeners();
  }

  set isDarkMode(bool value) {
    _isDarkMode = value;
    _preferences.setDarkTheme(value);
    notifyListeners();
  }
}

/// Handles saving and retrieving theme preference from SharedPreferences
class ThemePreferences {
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        "Setting dark theme preference: $value"); // Print the value before storing

    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(THEME_STATUS) ?? true;
  }
}

/// A toggle switch UI widget for light/dark mode
class ThemeToggleSwitch extends StatefulWidget {
  const ThemeToggleSwitch({Key? key}) : super(key: key);

  @override
  State<ThemeToggleSwitch> createState() => _ThemeToggleSwitchState();
}

class _ThemeToggleSwitchState extends State<ThemeToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Switch(
          value: themeController.isDarkMode,
          onChanged: (bool value) {
            setState(() {
              themeController.isDarkMode = value;
            });
          },
          activeColor: Colors.white,
          inactiveThumbColor: Colors.white,
          activeTrackColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.grey[400],
        );
      },
    );
  }
}
