import 'package:flutter/material.dart';
import 'dart:async';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Mnemonic_Backup_View/View/MnemonicBackup.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeBoxUi.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeButtonScreen.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as error_code;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class PasscodeEntryView extends StatefulWidget {
  final String savedPasscode;
  final String click;
  final UserWalletDataModel data;
  bool? splash;

  PasscodeEntryView({
    super.key,
    required this.savedPasscode,
    required this.click,
    required this.data,
    this.splash = false,
  });

  @override
  _PasscodeEntryViewState createState() => _PasscodeEntryViewState();
}

class _PasscodeEntryViewState extends State<PasscodeEntryView> {
  List<String> enteredPasscodeDigits =
      List.filled(6, ''); // List to store each digit of the passcode
  String passcode = '';
  bool isPasscodeEntered = false;
  LocalStorageService localStorageService = LocalStorageService();
  LocalAuthentication auth = LocalAuthentication();
  bool isDeviceSupport = false;
  List<BiometricType>? availableBiometrics;

  int failedAttempts = 0;
  bool isDelayActive = false;
  int remainingDelaySeconds = 0;
  final int maxFailedAttempts = 5;
  final int delayDurationSeconds = 60; // 60 seconds
  final String _failedAttemptsKey = 'failed_attempts';
  final String _delayStartTimeKey = 'delay_start_time';

  List<Color> boxColors = List.filled(6, Colors.transparent);

  @override
  void initState() {
    super.initState();
    _restoreState();
    deviceCap();
  }

  void _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;

    // Restore the delay timer if it was active
    if (failedAttempts >= maxFailedAttempts) {
      int delayStartTime = prefs.getInt(_delayStartTimeKey) ?? 0;
      int elapsedSeconds =
          (DateTime.now().millisecondsSinceEpoch - delayStartTime) ~/ 999;

      if (elapsedSeconds < delayDurationSeconds) {
        remainingDelaySeconds = delayDurationSeconds - elapsedSeconds;
        _startDelayTimer(remainingDelaySeconds);
      } else {
        // Reset if delay has already passed
        _resetDelayTimer();
      }
    }
  }

  void _handleButtonPress(String value) {
    for (int i = 0; i < enteredPasscodeDigits.length; i++) {
      if (enteredPasscodeDigits[i].isEmpty) {
        setState(() {
          enteredPasscodeDigits[i] = value;
          passcode = enteredPasscodeDigits.join();
          if (passcode.length == 6) {
            isPasscodeEntered =
                true; // Set isPasscodeEntered to true when passcode length reaches 6
            _checkPasscode();
          } else {
            boxColors = List.filled(6, Colors.transparent);
          }
        });
        break;
      }
    }
  }

  void _checkPasscode() {
    final enteredPasscode = enteredPasscodeDigits.join('');
    if (enteredPasscode == widget.savedPasscode) {
      _resetDelayTimer(); // Reset the delay timer if passcode is correct
      // _navigateToHomePage();
    } else {
      failedAttempts++;
      if (failedAttempts >= maxFailedAttempts) {
        _startDelayTimer(delayDurationSeconds);
      }

      // Incorrect passcode logic
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          enteredPasscodeDigits = List.filled(6, ''); // Clear entered digits
          passcode = ''; // Clear passcode
        });
      });
    }
  }

  void _handleDelete() {
    for (int i = enteredPasscodeDigits.length - 1; i >= 0; i--) {
      if (enteredPasscodeDigits[i].isNotEmpty) {
        setState(() {
          enteredPasscodeDigits[i] = '';
          passcode = enteredPasscodeDigits.join(); // Update passcode
        });
        break;
      }
    }
  }

  void _startDelayTimer(int duration) {
    setState(() {
      isDelayActive = true;
      remainingDelaySeconds = duration;
    });

    // Save the start time of the delay
    final startTime = DateTime.now().millisecondsSinceEpoch;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_failedAttemptsKey, failedAttempts);
      prefs.setInt(_delayStartTimeKey, startTime);
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingDelaySeconds--;
      });

      if (remainingDelaySeconds <= 0) {
        _resetDelayTimer();
        timer.cancel();
      }
    });
  }

  void _resetDelayTimer() {
    setState(() {
      isDelayActive = false;
      remainingDelaySeconds = 0;
      failedAttempts = 0; // Reset failed attempts after delay expires
    });

    // Clear stored failed attempts and delay start time
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_failedAttemptsKey);
      prefs.remove(_delayStartTimeKey);
    });
  }

  VaultStorageService vaultStorageService = VaultStorageService();
  void navHomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    if (widget.click == 'wallet_backup') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MnemonicBackup(
                  userWallet: widget.data,
                )),
      );
    } else if (widget.click == 'send') {
      Navigator.pop(context);
    } else if (widget.click == 'send1') {
      Navigator.pop(context, true);
    } else if (widget.click == '123') {
      Map data = widget.data.toJson();
      await vaultStorageService.removeData(data);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => AppBottomNav()),
          (route) => false);
    }
  }

  void deviceCap() async {
    final bool isCapable = await auth.canCheckBiometrics;
    isDeviceSupport = isCapable || await auth.isDeviceSupported();
  }

  void handleDone(BuildContext context) {
    final enteredPasscode = enteredPasscodeDigits.join('');
    if (enteredPasscode == widget.savedPasscode) {
      navHomeScreen();
    } else if (enteredPasscode.isEmpty) {
      Utils.snackBarErrorMessage("Please Enter Passcode");
    } else {
      Utils.snackBarErrorMessage("Passcode Incorrect");
    }
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    List<Widget> passcodeDigitBoxes = [];
    bool isPasscodeCorrect = passcode == widget.savedPasscode;
    List<Color> boxColors = List.filled(6,
        Theme.of(context).primaryColor); // Initially set all box colors to gray
    if (isPasscodeEntered) {
      if (isPasscodeCorrect) {
        boxColors = List.filled(6, Color(0xFFB982FF));
      } else if (passcode.length != 6) {
        boxColors = List.filled(6, Colors.transparent);
      } else {
        boxColors = List.filled(6, Colors.red);
      }
    }
    for (int i = 0; i < 6; i++) {
      passcodeDigitBoxes.add(PasscodeBoxUi(
        digit: i < passcode.length ? '*' : '',
        boxColor: boxColors[i],
        isCorrect: false,
        colorCheck: false,
      ));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(''),
        leading: widget.splash!
            ? null
            : GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).indicatorColor)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Enter Passcode',
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.surfaceBright,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: passcodeDigitBoxes,
            ),
            SizedBox(height: 10),
            if (isDelayActive)
              Column(
                children: [
                  Text(
                    'The application will be unlocked',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'after : ${remainingDelaySeconds % 60} seconds',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                  label: '1',
                  onPressed: () =>
                      isDelayActive ? null : _handleButtonPress('1'),
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                ),
                PasscodeButton(
                    label: '2',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('2'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                    label: '3',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('3'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                    label: '4',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('4'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                    label: '5',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('5'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                    label: '6',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('6'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                    label: '7',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('7'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                    label: '8',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('8'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                    label: '9',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('9'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PasscodeButton(
                  label: 'F',
                  onPressed: () {
                    _getAvailableBiometrics();
                  },
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                  isFingerPrintButton: true,
                ),
                PasscodeButton(
                    label: '0',
                    onPressed: () =>
                        isDelayActive ? null : _handleButtonPress('0'),
                    backgroundColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.surfaceBright),
                PasscodeButton(
                  label: 'D',
                  onPressed: _handleDelete,
                  backgroundColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.surfaceBright,
                  isDeleteButton: true,
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.height(context, 2),
            ),
            widget.click == 'send1' ||
                    widget.click == '123' ||
                    widget.click == 'wallet_backup'
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20, bottom: Platform.isIOS ? 16 : 0),
                    child: ReuseElevatedButton(
                      onTap: () => isDelayActive ? null : handleDone(context),
                      width: MediaQuery.sizeOf(context).width,
                      height: 45,
                      text: 'Confirm',
                      textcolor: Colors.black,
                      gradientColors: [Color(0XFF70A2FF), Color(0XFF54F0D1)],
                    ))
                : Padding(
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20, bottom: Platform.isIOS ? 16 : 0),
                    child: ReuseElevatedButton(
                      onTap: () => isDelayActive ? null : handleDone(context),
                      width: MediaQuery.sizeOf(context).width,
                      height: 45,
                      text: 'Continue',
                      textcolor: Colors.black,
                      gradientColors: [Color(0XFF70A2FF), Color(0XFF54F0D1)],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _getAvailableBiometrics() async {
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      print("bioMetric: $availableBiometrics");

      if (availableBiometrics!.contains(BiometricType.strong) ||
          availableBiometrics!.contains(BiometricType.fingerprint)) {
        final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'NVXO WALLET',
            options: const AuthenticationOptions(
                biometricOnly: true, stickyAuth: true),
            authMessages: const <AuthMessages>[
              IOSAuthMessages(
                cancelButton: 'Pin',
              ),
              AndroidAuthMessages(
                signInTitle: 'Authentication required',
                cancelButton: 'Pin',
              ),
            ]);
        if (!didAuthenticate) {
          // exit(0);
        } else if (didAuthenticate) {
          navHomeScreen();
        }
      } else if (availableBiometrics!.contains(BiometricType.weak) ||
          availableBiometrics!.contains(BiometricType.face)) {
        final bool didAuthenticate = await auth.authenticate(
            localizedReason:
                'Unlock your screen with PIN, pattern, password, face, or fingerprint',
            options: const AuthenticationOptions(stickyAuth: true),
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'Unlock Ideal Group',
                cancelButton: 'No thanks',
              ),
              IOSAuthMessages(
                cancelButton: 'No thanks',
              ),
            ]);
        if (!didAuthenticate) {
          // exit(0);
        } else if (didAuthenticate) {
          navHomeScreen();
        }
      }
    } on PlatformException catch (e) {
      // availableBiometrics = <BiometricType>[];
      if (e.code == error_code.passcodeNotSet) {
        exit(0);
      }
      print("error: $e");
    }
  }
}
