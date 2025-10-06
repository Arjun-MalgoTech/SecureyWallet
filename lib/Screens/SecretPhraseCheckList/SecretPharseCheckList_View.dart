import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/SecretPhraseGenerator/View/MnemonicGenerator.dart';

class SecretPhrasesCheckList extends StatefulWidget {
  const SecretPhrasesCheckList({super.key});

  @override
  State<SecretPhrasesCheckList> createState() => _SecretPhrasesCheckListState();
}

class _SecretPhrasesCheckListState extends State<SecretPhrasesCheckList> {
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;

  bool get allCheckboxesSelected => checkbox1 && checkbox2 && checkbox3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(context),
            const SizedBox(height: 2),
            _buildTitleSection(),
            const SizedBox(height: 12),
            _buildCheckbox(
              value: checkbox1,
              onChanged: (val) => setState(() => checkbox1 = val),
              text: "Secury WALLET never keeps a copy of your secret\nphrase.",
            ),
            _buildCheckbox(
              value: checkbox2,
              onChanged: (val) => setState(() => checkbox2 = val),
              text:
                  "For security reasons, do not save your secret\nphrase in plain text, such as in screenshots, \ntext files, or emails.",
            ),
            _buildCheckbox(
              value: checkbox3,
              onChanged: (val) => setState(() => checkbox3 = val),
              text:
                  "Note down your secret phrase and store it\nsafely offline!",
            ),
            const SizedBox(height: 16),
            _buildContinueButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
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
          "Check that your secret phrase is  ",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        AppText("safe here", fontSize: 20, fontWeight: FontWeight.bold),
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).primaryColorLight,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
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
          gradient: LinearGradient(
            colors: allCheckboxesSelected
                ? [Color(0xFF912ECA), Color(0xFF793CDE)]
                : [Colors.grey, Colors.grey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ElevatedButton(
          onPressed: allCheckboxesSelected
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MnemonicStepperScreen(),
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
