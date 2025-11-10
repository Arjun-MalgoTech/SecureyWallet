import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
import 'package:securywallet/Screens/ImportRecoveryPhrase_Screen/View/ImportRecoveryPhrase_View.dart';
import 'package:securywallet/Screens/SecretPhraseGenerator/View/MnemonicGenerator.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_2_View.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_View.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/Screens/userWalletsPage_View/Backup_Vault_View/View/BackUpVaultView.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class UserWalletPage extends StatefulWidget {
  const UserWalletPage({super.key});

  @override
  State<UserWalletPage> createState() => _UserWalletPageState();
}

class _UserWalletPageState extends State<UserWalletPage> {
  String privateKey = '';
  String dollar = '';

  VaultStorageService vaultStorageService = VaultStorageService();
  LocalStorageService localStorageService = LocalStorageService();
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocalStorageService>(context, listen: false).getData();
    });
    super.initState();
  }

  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;

  bool get allCheckboxesSelected => checkbox1 && checkbox2 && checkbox3;

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          "Wallets",
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.transparent,
            child: Icon(Icons.arrow_back, color: Color(0xFFB7B7B7)),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              showBottomSheet(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(Icons.add, color: Color(0xFFB7B7B7)),
            ),
          ),
          SizedBox(width: SizeConfig.width(context, 5)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppText("Multi-coin wallets", color: Color(0xFFB7B7B7)),
            ),
            Expanded(
              child: localStorageService.walletListData.isEmpty
                  ? SizedBox()
                  : ListView.builder(
                      itemCount: localStorageService.walletListData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await vaultStorageService.selectedWallet(
                                localStorageService.walletListData[index]
                                    .toJson(),
                              );
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => AppBottomNav(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).primaryColorLight,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 16.0,
                                          top: 16.0,
                                          bottom: 16.0,
                                          right: 16.0,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.black,
                                              radius: 20,
                                              child: Image.asset('assets/Images/secury.png'),
                                            ),
                                            localStorageService
                                                        .activeWalletData!
                                                        .walletAddress ==
                                                    localStorageService
                                                        .walletListData[index]
                                                        .walletAddress
                                                ? Container(
                                                    height: 13,
                                                    width: 13,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.green,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        child: AppText(
                                          localStorageService
                                                      .walletListData[index]
                                                      .walletName
                                                      .toString()
                                                      .length >
                                                  13
                                              ? '${localStorageService.walletListData[index].walletName.toString()}'
                                              : localStorageService
                                                    .walletListData[index]
                                                    .walletName
                                                    .toString(),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceBright,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: IconButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceBright,
                                          onPressed: () {
                                            print(
                                              'mnemonic::::${localStorageService.walletListData[index].mnemonic}',
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return WalletBackUp(
                                                    data: localStorageService
                                                        .walletListData[index],
                                                  );
                                                },
                                              ),
                                            ).then((result) {
                                              if (result != null) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      Provider.of<
                                                            LocalStorageService
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .getData();
                                                    });
                                                setState(() {
                                                  localStorageService
                                                          .walletListData[index]
                                                          .walletName =
                                                      result['savedText'];
                                                });
                                              }
                                            });
                                          },
                                          icon: Container(
                                            height: 40,
                                            color: Colors.transparent,
                                            child: Icon(Icons.more_vert),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      builder: (BuildContext context) {
        return Container(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Center(
                        child: AppText(
                          "Create wallet",
                          color: Theme.of(context).colorScheme.surfaceBright,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.surfaceBright,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  "assets/Images/coinwallet.png",
                  height: SizeConfig.height(context, 24),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SecureBackup2();
                            },
                          ),
                        );
                      },

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF3D353C),
                        radius: 20,
                        child: Icon(Icons.add, color: Color(0xFFB982FF)),
                      ),
                      title: AppText(
                        "Create New Wallet",
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                      subtitle: AppText(
                        "Secret Phrase",
                        fontWeight: FontWeight.w300,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SecureBackup();
                            },
                          ),
                        );
                      },

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF3D353c),
                        radius: 20,
                        child: Icon(
                          Icons.arrow_downward,
                          color: Color(0xFFB982FF),
                        ),
                      ),
                      title: AppText(
                        "Access Existing Wallet",
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                      subtitle: AppText(
                        "Recover, Import, or View-Only Access",
                        fontWeight: FontWeight.w300,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                                    "Secury WALLET never keeps a copy of your\nsecret phrase.",
                              ),
                              gradientDivider(),
                              _buildCheckbox(
                                value: checkbox2,
                                onChanged: (val) =>
                                    setStateDialog(() => checkbox2 = val),
                                text:
                                    "For security reasons, do not save your secret\nphrase in plain text, such as in screenshots, \ntext files, or emails.",
                              ),
                              gradientDivider(),
                              _buildCheckbox(
                                value: checkbox3,
                                onChanged: (val) =>
                                    setStateDialog(() => checkbox3 = val),
                                text:
                                    "Note down your secret phrase and store it\nsafely offline!",
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
