import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
import 'package:securywallet/Screens/SecretPhraseCheckList/SecretPharseCheckList_View.dart';
import 'package:securywallet/Screens/SecretPhraseGenerator/View/MnemonicGenerator.dart';

class SecureBackup extends StatefulWidget {
  const SecureBackup({super.key});

  @override
  State<SecureBackup> createState() => _SecureBackupState();
}

class _SecureBackupState extends State<SecureBackup> {
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;

  bool get allCheckboxesSelected => checkbox1 && checkbox2 && checkbox3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            signWallet(),
            const SizedBox(height: 10),
            _buildImage(),
            const SizedBox(height: 10),
            _buildImage2(),
            const Spacer(),
            // _buildBackupButton(context),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
      ),
      centerTitle: true,
      title: AppText(
        "Secure Backup",
        color: Theme.of(context).colorScheme.surfaceBright,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget signWallet() {
    return Row(
      children: [
        AppText(
          "How do you sign in to your\nwallet?",
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Center(
      child: GestureDetector(
        onTap: () {
          showGlassDialog(context);
        },

        child: Image.asset(
          "assets/Images/123.png",
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget _buildImage1() {
    return Center(
      child: GestureDetector(
        onTap: () {
          showGlassDialog(context);
        },

        child: Image.asset(
          "assets/Images/2.png",
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget _buildImage2() {
    return Center(
      child: GestureDetector(
        onTap: () {
          showGlassDialog(context);
        },

        child: Image.asset(
          "assets/Images/3.png",
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  // Widget _buildBackupButton(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //
  //
  //       return;
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => SecretPhrasesCheckList()),
  //       );
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20),
  //         color: Colors.white,
  //       ),
  //       width: MediaQuery.of(context).size.width,
  //       height: 40,
  //       child: Center(child: AppText("Continue", color: Colors.black)),
  //     ),
  //   );
  // }

  void showGlassDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Main Content
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildHeaderImage(context),
                              const SizedBox(height: 2),
                              _buildTitleSection(),
                              const SizedBox(height: 12),
                              _buildCheckbox(
                                value: checkbox1,
                                onChanged: (val) =>
                                    setStateDialog(() => checkbox1 = val),
                                text:
                                    "Secury WALLET never keeps a copy of\nyour secret phrase.",
                              ),
                              gradientDivider(),
                              _buildCheckbox(
                                value: checkbox2,
                                onChanged: (val) =>
                                    setStateDialog(() => checkbox2 = val),
                                text:
                                    "For security reasons, do not save your\nsecret phrase in plain text, such as in\nscreenshots,text files, or emails.",
                              ),
                              gradientDivider(),
                              _buildCheckbox(
                                value: checkbox3,
                                onChanged: (val) =>
                                    setStateDialog(() => checkbox3 = val),
                                text:
                                    "Note down your secret phrase and store\nit safely offline!",
                              ),
                              const SizedBox(height: 16),
                              _buildContinueButton(context),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // ✅ Close button (top-right corner)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Gradient Divider widget
  Widget gradientDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0), // invisible at start
            Colors.white.withOpacity(0.3), // bright in center
            Colors.white.withOpacity(0.0), // invisible at end
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        "assets/Images/trust.png",
        height: SizeConfig.height(context, 30),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        AppText(
          "Check that your secret phrase",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        AppText("is safe here", fontSize: 20, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required Function(bool) onChanged,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: value
                      ? const Color(0xFF006B2B)
                      : Theme.of(context).primaryColor,
                  radius: 15,
                  child: Checkbox(
                    value: value,
                    onChanged: (bool? val) => onChanged(val ?? false),
                    activeColor: const Color(0xFF006B2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText(
                    text,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF8B8B8B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: allCheckboxesSelected ? Colors.white : Colors.grey,
        ),
        child: ElevatedButton(
          onPressed: allCheckboxesSelected
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConnectExistingWallet(),
                  ),
                )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Continue',
            style: TextStyle(
              color: allCheckboxesSelected ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
