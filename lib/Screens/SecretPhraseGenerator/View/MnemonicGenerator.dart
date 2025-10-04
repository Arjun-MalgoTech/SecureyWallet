import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/SecretPhraseGenerator/View/ChooseMnemonic.dart';

class MnemonicGenerator extends StatefulWidget {
  const MnemonicGenerator({super.key});

  @override
  _MnemonicGeneratorState createState() => _MnemonicGeneratorState();
}

class _MnemonicGeneratorState extends State<MnemonicGenerator> {
  late String mnemonicPhrase;

  List<String> get words => mnemonicPhrase.split(' ');

  @override
  void initState() {
    super.initState();
    mnemonicPhrase = bip39.generateMnemonic();
  }

  void copyToClipboard() {
    FlutterClipboard.copy(mnemonicPhrase);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Secret phrase copied'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseMnemonic(mnemonicPhrase)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildWordList(context),
          const SizedBox(height: 30),
          _buildCopyButton(),
          const Spacer(),
          // _buildSecurityNote(),
          _buildContinueButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: AppText("Secret Phrase"),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.info, color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildWordList(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 11,
      runSpacing: 12,
      children: List.generate(
        words.length,
        (idx) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${idx + 1}.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: 0.5,
                ),
              ),
              child: FilterChip(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
                label: Text(
                  words[idx],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                onSelected: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton() {
    return InkWell(
      onTap: copyToClipboard,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_copy_outlined, color: Color(0xFFB4B1B2)),
          SizedBox(width: 10),
          Text('Copy', style: TextStyle(color: Color(0xFFB4B1B2))),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF231D0B),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.info, color: Color(0xFFFCB500)),
            AppText(
              "Never reveal your secret phrase to others and protect\nit in a secure location",
              color: Color(0xFFFCB500),
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, Platform.isIOS ? 30 : 10),
      child: GestureDetector(
        onTap: onContinue,
        child: ReuseElevatedButton(
          width: MediaQuery.of(context).size.width,
          height: 45,
          text: 'Continue',
          textcolor: Colors.black,
          gradientColors: const [Color(0XFF42E695), Color(0XFF3BB2BB)],
        ),
      ),
    );
  }
}
