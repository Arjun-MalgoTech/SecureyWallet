import 'package:flutter/material.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/SecretPhraseCheckList/SecretPharseCheckList_View.dart';


class SecureBackup extends StatefulWidget {
  const SecureBackup({super.key});

  @override
  State<SecureBackup> createState() => _SecureBackupState();
}

class _SecureBackupState extends State<SecureBackup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 84),
            _buildImage(),
            const SizedBox(height: 100),
            _buildTitleSection(),
            const SizedBox(height: 100),
            _buildBackupButton(context),
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

  Widget _buildImage() {
    return Center(
      child: Image.asset("assets/Images/backup_file.png"),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        GradientAppText(
          text: "Secure Your Recovery Phrase",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          "Ensure Your Security—Back Up Your Seed Phrase Now",
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: const Color(0xFF8B8B8B),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackupButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecretPhrasesCheckList()),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white24,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
        child: AppText(
          "Manual Backup",
          color: const Color(0xFFB982FF),
        ),
      ),
    );
  }
}
