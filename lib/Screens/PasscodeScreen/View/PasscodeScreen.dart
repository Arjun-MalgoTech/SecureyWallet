import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeBoxUi.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeButtonScreen.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeEntryView.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as error_code;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class PasscodeScreen extends StatefulWidget {
  String name;
  final UserWalletDataModel data;
  final bool? splash;

  PasscodeScreen({
    super.key,
    required this.name,
    required this.data,
    this.splash = false,
  });

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String passcode = '';
  String confirmPasscode = '';
  bool isSettingPasscode = true;

  // Flag to indicate if we are setting or confirming the passcode
  @override
  void initState() {
    super.initState();
    _checkPasscodeSet();
    auth = LocalAuthentication();
    deviceCapability();
    // _getAvailableBiometrics();
    // _authenticateWithBiometrics();
  }

  void _checkPasscodeSet() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');
    if (savedPasscode != null && savedPasscode.isNotEmpty) {
      // print("///////////////////////////////////////////////${widget.name}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasscodeEntryView(
            savedPasscode: savedPasscode,
            click: widget.name,
            data: widget.data,
            splash: widget.splash,
          ),
        ),
      );
    }
  }

  void _handleButtonPress(String value) {
    setState(() {
      if (isSettingPasscode) {
        if (passcode.length < 6) {
          passcode += value;
        }
      } else {
        if (confirmPasscode.length < 6) {
          confirmPasscode += value;
        }
      }
    });
  }

  void _handleDelete() {
    setState(() {
      if (isSettingPasscode) {
        if (passcode.isNotEmpty) {
          passcode = passcode.substring(0, passcode.length - 1);
        }
      } else {
        if (confirmPasscode.isNotEmpty) {
          confirmPasscode = confirmPasscode.substring(
            0,
            confirmPasscode.length - 1,
          );
        }
      }
    });
  }

  void _handleDone() async {
    if (isSettingPasscode) {
      setState(() {
        isSettingPasscode = false;
      });
    } else {
      if (passcode.isEmpty && confirmPasscode.isEmpty) {
        // Show an alert if either passcode or confirmPasscode is empty
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:
                  Theme.of(context).bottomAppBarTheme.color ??
                  Color(0xFFD4D4D4),
              contentPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.8, // Adjust the width as needed
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AppText(
                            "Empty Passcode",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surfaceBright,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            AppText(
                              'Please enter both passcode',
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceBright,
                            ),
                            AppText(
                              'and confirm passcode.',
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceBright,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0XFF55F0D1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 18.0,
                                right: 18.0,
                                top: 4,
                                bottom: 4,
                              ),
                              child: AppText("OK", color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else if (passcode == confirmPasscode) {
        // Passcode is confirmed
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('passcode', passcode);

        // Check if passcode is saved
        final savedPasscode = prefs.getString('passcode');
        if (savedPasscode != null && savedPasscode.isNotEmpty) {
          // Passcode saved successfully
          // print('Passcode saved: $savedPasscode');

          // Clear the passcode fields for re-entering
          setState(() {
            passcode = '';
            confirmPasscode = '';
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AppBottomNav();
              },
            ),
          );
          // print('wdvjhkjnmmmklmd');
          // showModalBottomSheet(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return Container(
          //       color: Theme.of(context).bottomAppBarTheme.color ??
          //           Color(0xFFD4D4D4),
          //       height: 400,
          //       padding: EdgeInsets.all(20.0),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: <Widget>[
          //           GestureDetector(
          //             onTap: () {
          //               Navigator.pop(context);
          //             },
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 Icon(
          //                   Icons.clear,
          //                   color: Theme.of(context).colorScheme.surfaceBright,
          //                 )
          //               ],
          //             ),
          //           ),
          //           Image.asset(
          //             'assets/Images/correct.png',
          //             height: 100,
          //             width: 100,
          //           ),
          //           AppText(
          //             'Welcome! Let’s get started!',
          //             fontSize: 23.0,
          //             fontWeight: FontWeight.bold,
          //             color: Theme.of(context).colorScheme.surfaceBright,
          //           ),
          //           SizedBox(height: 10.0),
          //           AppText(
          //             'Your wallet is ready! Jump in and start your journey.',
          //             fontSize: 13.0,
          //             color: Theme.of(context).colorScheme.surfaceBright,
          //           ),
          //           SizedBox(height: 10.0),
          //           AppText(
          //             'Stay safe on your crypto journey!',
          //             fontSize: 13.0,
          //             color: Theme.of(context).colorScheme.surfaceBright,
          //           ),
          //           SizedBox(height: 50.0),
          //           GestureDetector(
          //             onTap: () {
          //               Navigator.pop(context);
          //             },
          //             child: Container(
          //               height: 44.0,
          //               width: MediaQuery.of(context).size.width,
          //               decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(20),
          //                   gradient: LinearGradient(colors: [
          //                     Color(0xFF912ECA),
          //                     Color(0xFF912ECA),
          //                     Color(0xFF793CDE),
          //                     Color(0xFF793CDE),
          //                   ])),
          //               child: Center(
          //                   child: AppText(
          //                 'Get Started with NVXO Wallet',
          //                 color: Colors.black,
          //               )),
          //             ),
          //           )
          //         ],
          //       ),
          //     );
          //   },
          // );
        } else {
          // Show an alert if passcode saving fails
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Failed to Save Passcode'),
                content: Text(
                  'There was an issue saving the passcode. Please try again.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Passcode mismatch
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:
                  Theme.of(context).bottomAppBarTheme.color ??
                  Color(0xFFD4D4D4),
              contentPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.8, // Adjust the width as needed
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AppText(
                            "Passcode Mismatch",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surfaceBright,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            AppText(
                              'The passcode do not match.',
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceBright,
                            ),
                            AppText(
                              'Please try again.',
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceBright,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFFB982FF),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 18.0,
                                right: 18.0,
                                top: 4,
                                bottom: 4,
                              ),
                              child: AppText("OK", color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    }
  }

  bool isDeviceSupport = false;
  List<BiometricType>? availableBiometrics;
  LocalAuthentication? auth;

  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    List<Widget> passcodeDigitBoxes = [];

    for (int i = 0; i < 6; i++) {
      passcodeDigitBoxes.add(
        PasscodeBoxUi(
          digit: isSettingPasscode
              ? (i < passcode.length ? '*' : '')
              : (i < confirmPasscode.length ? '*' : ''),
          isCorrect: isSettingPasscode,
          boxColor: Colors.grey,
          colorCheck: false,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();

        // Reset to "Create Passcode" screen if pressed back
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          if (!isSettingPasscode) {
            // If currently in the confirmation phase, navigate back to the create passcode phase
            setState(() {
              isSettingPasscode = true;
              passcode = '';
              confirmPasscode = '';
            });
            return false; // Prevent default back behavior
          }
        }
        return false; // Allow back action if not in the confirmation step
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(''),
          // leading: Icon(Icons.arrow_back,color: Color(0xFF363738),),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              isSettingPasscode ? 'Create Passcode' : 'Confirm Passcode',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: passcodeDigitBoxes,
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                  label: '1',
                  onPressed: () => _handleButtonPress('1'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '2',
                  onPressed: () => _handleButtonPress('2'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '3',
                  onPressed: () => _handleButtonPress('3'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                  label: '4',
                  onPressed: () => _handleButtonPress('4'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '5',
                  onPressed: () => _handleButtonPress('5'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '6',
                  onPressed: () => _handleButtonPress('6'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                  label: '7',
                  onPressed: () => _handleButtonPress('7'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '8',
                  onPressed: () => _handleButtonPress('8'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '9',
                  onPressed: () => _handleButtonPress('9'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Platform.isIOS
                    ? PasscodeButton(
                        label: '',
                        backgroundColor: Colors.transparent,
                        labelColor: Theme.of(context).colorScheme.surfaceBright,
                      )
                    : GestureDetector(
                        onTap: () {
                          // _authenticateWithBiometrics();
                        },
                        child: Icon(
                          Icons.fingerprint,
                          size: 50.0,
                          color: Theme.of(context).colorScheme.surfaceBright,
                        ),
                      ),
                PasscodeButton(
                  label: '0',
                  onPressed: () => _handleButtonPress('0'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                  label: '00',
                  onPressed: _handleDelete,
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                  isDeleteButton: true,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: ReuseElevatedButton(
                onTap: _handleDone,
                width: MediaQuery.sizeOf(context).width,
                height: 45,
                text: 'Next',
                textcolor: Colors.black,
                gradientColors: [Color(0XFF70A2FF), Color(0XFF54F0D1)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deviceCapability() async {
    final bool isCapable = await auth!.canCheckBiometrics;
    isDeviceSupport = isCapable || await auth!.isDeviceSupported();
  }
}
