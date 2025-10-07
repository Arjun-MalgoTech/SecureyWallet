import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/SecretPhraseGenerator/View/ChooseMnemonic.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

// class MnemonicGenerator extends StatefulWidget {
//   const MnemonicGenerator({super.key});
//
//   @override
//   _MnemonicGeneratorState createState() => _MnemonicGeneratorState();
// }
//
// class _MnemonicGeneratorState extends State<MnemonicGenerator> {
//   late String mnemonicPhrase;
//
//   List<String> get words => mnemonicPhrase.split(' ');
//
//   @override
//   void initState() {
//     super.initState();
//     mnemonicPhrase = bip39.generateMnemonic();
//   }
//
//   void copyToClipboard() {
//     FlutterClipboard.copy(mnemonicPhrase);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Secret phrase copied'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   void onContinue() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChooseMnemonic(mnemonicPhrase)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: _buildAppBar(context),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(height: 40),
//           _buildWordList(context),
//           const SizedBox(height: 30),
//           _buildCopyButton(),
//           const Spacer(),
//           // _buildSecurityNote(),
//           _buildContinueButton(context),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       title: AppText("Secret Phrase"),
//       centerTitle: true,
//       leading: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: const Icon(Icons.arrow_back, color: Colors.white),
//       ),
//       actions: const [
//         Padding(
//           padding: EdgeInsets.only(right: 8.0),
//           child: Icon(Icons.info, color: Colors.transparent),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWordList(BuildContext context) {
//     return Wrap(
//       alignment: WrapAlignment.spaceAround,
//       spacing: 11,
//       runSpacing: 12,
//       children: List.generate(
//         words.length,
//         (idx) => Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '${idx + 1}.',
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 15,
//                 color: Theme.of(context).colorScheme.surfaceBright,
//               ),
//             ),
//             const SizedBox(width: 5),
//             Container(
//               width: 130,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14),
//                 border: GradientBoxBorder(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0.3),
//                       Colors.white.withOpacity(0.05),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   width: 0.5,
//                 ),
//               ),
//               child: FilterChip(
//                 side: BorderSide.none,
//                 backgroundColor: Colors.transparent,
//                 label: Text(
//                   words[idx],
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 15,
//                     color: Theme.of(context).colorScheme.surfaceBright,
//                   ),
//                 ),
//                 onSelected: (_) {},
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCopyButton() {
//     return InkWell(
//       onTap: copyToClipboard,
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.file_copy_outlined, color: Color(0xFFB4B1B2)),
//           SizedBox(width: 10),
//           Text('Copy', style: TextStyle(color: Color(0xFFB4B1B2))),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSecurityNote() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: const Color(0xFF231D0B),
//         ),
//         padding: const EdgeInsets.all(8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             const Icon(Icons.info, color: Color(0xFFFCB500)),
//             AppText(
//               "Never reveal your secret phrase to others and protect\nit in a secure location",
//               color: Color(0xFFFCB500),
//               fontSize: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContinueButton(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(10, 10, 10, Platform.isIOS ? 30 : 10),
//       child: GestureDetector(
//         onTap: onContinue,
//         child: ReuseElevatedButton(
//           width: MediaQuery.of(context).size.width,
//           height: 45,
//           text: 'Continue',
//           textcolor: Colors.black,
//           gradientColors: const [Color(0XFF42E695), Color(0XFF3BB2BB)],
//         ),
//       ),
//     );
//   }
// }

class MnemonicStepperScreen extends StatefulWidget {
  const MnemonicStepperScreen({super.key});

  @override
  State<MnemonicStepperScreen> createState() => _MnemonicStepperScreenState();
}

class _MnemonicStepperScreenState extends State<MnemonicStepperScreen> {
  int currentStep = 0;

  late String mnemonicPhrase;

  List<String> get words => mnemonicPhrase.split(' ');

  // For step 2
  List<String> allWords = [];
  List<String> selectedWords = [];
  bool isLoading = false;

  VaultStorageService vaultStorageService = VaultStorageService();
  LocalStorageService localStorageService = LocalStorageService();

  String privateKeyHex = '';
  String walletAddress = '';

  @override
  void initState() {
    super.initState();
    mnemonicPhrase = bip39.generateMnemonic();
    allWords = mnemonicPhrase.split(' ');
    allWords.shuffle(Random());
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

  void selectWord(String word) {
    setState(() {
      if (selectedWords.contains(word)) {
        selectedWords.remove(word);
      } else {
        if (selectedWords.length < 12) {
          selectedWords.add(word);
        }
      }
    });
  }

  bool get isCorrectOrder {
    final original = mnemonicPhrase.split(' ');
    if (selectedWords.length != original.length) return false;
    for (int i = 0; i < original.length; i++) {
      if (selectedWords[i] != original[i]) return false;
    }
    return true;
  }

  Future<void> generatePrivateKeyAndAddressFromMnemonic() async {
    final mnemonic = mnemonicPhrase;
    mnemonicPhrase = mnemonic;
    if (bip39.validateMnemonic(mnemonic)) {
      final seed = bip39.mnemonicToSeed(mnemonic);
      final root = bip32.BIP32.fromSeed(seed);
      final child = root.derivePath("m/44'/60'/0'/0/0");
      final privateKey = child.privateKey;

      final privateKeyHex = HEX.encode(privateKey!);

      final rpcUrl = 'https://mainnet.infura.io/v3/your_infura_project_id';
      final httpClient = Client();
      final ethClient = Web3Client(rpcUrl, httpClient);

      final credentials = await ethClient.credentialsFromPrivateKey(
        privateKeyHex,
      );
      final address = await credentials.extractAddress();

      // Save to Get Storage
      setState(() {
        this.privateKeyHex = privateKeyHex;
        this.walletAddress = address.hexEip55;
      });
    } else {
      setState(() {
        this.privateKeyHex = 'Invalid Mnemonic';
        this.walletAddress = '';
      });
    }
  }

  String printedValue = "";
  String hexString = "0xb1a2bc2ec500000";

  void _updatePrintedValue() {
    int decimalValue = int.parse(hexString.substring(2), radix: 16);
    double balance = decimalValue / 1e18;
    // print(balance);
    String newValue = balance.toString();
    setState(() {
      printedValue = newValue;
    });
  }



  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    final allSelected = selectedWords.length == 12;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: currentStep == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => currentStep = 0),
              ),
        title: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Step progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: currentStep >= 0 ? 1 : 0,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: Colors.white,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: currentStep == 1 ? 1 : 0,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: Colors.white,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppText(
                  "${currentStep + 1}/2",
                  color: Colors.white,
                  fontSize: 13,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Step content
            Expanded(
              child: currentStep == 0
                  ? _buildStep1()
                  : _buildStep2(allSelected),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 STEP 1: Generate Mnemonic
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "Select your Secret Phrase",
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        const SizedBox(height: 8),
        AppText(
          "This 12-word secret phrase is the only way to\naccess and recover your wallet. Write it down\nand keep it in a safe place.",
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.32,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F131A),
            borderRadius: BorderRadius.circular(16),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              width: 0.7,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              words.length,
                  (index) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal:6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: const Color(0xFF141922),
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    width: 0.5,
                  ),
                ),
                child: AppText(
                  "${index + 1}. ${words[index]}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: InkWell(
            onTap: copyToClipboard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copy, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 6),
                AppText(
                  "Copy to clipboard",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B2C09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AppText(
            "Do not share your secret phrase with anyone.\nSaving it to cloud storage is at your own risk.\nWe are not liable for any loss or security breach\nresulting from this action. Store it securely.",

              color: Color(0xFFF9B732),
              fontSize: 12,
fontWeight: FontWeight.w400,

            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => currentStep = 1),
          child: ReuseElevatedButton(
            width: MediaQuery.of(context).size.width * 0.9,
            height: SizeConfig.height(context, 6),
            text: 'Continue',
            textcolor: Colors.black,
            gradientColors: const [Color(0XFF42E695), Color(0XFF3BB2BB)],
          ),
        ),
        SizedBox(height: Platform.isIOS ? 30 : 30),
      ],
    );
  }

  // 🔹 STEP 2: Confirm Mnemonic
  Widget _buildStep2(bool allSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirm your Secret Phrase",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "To confirm your secret phrase, kindly select each word exactly in the order it was given to you.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedWords
              .map(
                (word) => Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xFF141922),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    "${allWords.indexOf(word) + 1}. $word",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F131A),
            borderRadius: BorderRadius.circular(14),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              width: 0.6,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allWords.map((word) {
              final isSelected = selectedWords.contains(word);
              return GestureDetector(
                onTap: () => selectWord(word),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: isSelected ? Colors.white : const Color(0xFF141922),
                    border: Border.all(color: Colors.grey.withOpacity(0.4),width: 0.6)
                  ),
                  child: Text(
                    "${allWords.indexOf(word) + 1}. $word",
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: allSelected ?() async {

            if (selectedWords.length == 12 && isCorrectOrder) {
              setState(() => isLoading = true);

              await generatePrivateKeyAndAddressFromMnemonic();

              final wallet = UserWalletDataModel(
                walletName: "Main Wallet 1",
                walletAddress: walletAddress,
                mnemonic: mnemonicPhrase,
                privateKey: privateKeyHex,
              );
              localStorageService.creatingNewWallet = true;

              await vaultStorageService.addWalletToList(
                ApiKeyService.nvWalletList,
                wallet.toJson(),
              );
              _updatePrintedValue();

              if (privateKeyHex.isNotEmpty && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<LocalStorageService>(context, listen: false).getData();
                });
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AppBottomNav()),
                        (Route<dynamic> route) =>
                    false, // Replace 'false' with your condition
                  );
                }
              }
            }
            else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFFD4D4D4),
                    title: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/Images/fail.png', height: 30, width: 30),
                          const SizedBox(width: 6),
                          const Text(
                            'Incorrect',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    content: const Text(
                      'Selections not matched.\nPlease try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    actions: <Widget>[
                      ReuseElevatedButton(
                        width: double.infinity,
                        height: 45,
                        text: 'Try again',
                        textcolor: Colors.black,
                        gradientColors: const [Color(0XFF42E695), Color(0XFF3BB2BB)],
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            }
          } : null,
          child: ReuseElevatedButton(
            width: MediaQuery.of(context).size.width,
            height: SizeConfig.height(context, 6),
            text: 'Continue',
            textcolor: allSelected
                ? Colors.black
                : Colors.black.withOpacity(0.4),
            gradientColors: allSelected
                ? [const Color(0XFF42E695), const Color(0XFF3BB2BB)]
                : [Colors.grey, Colors.grey],
          ),
        ),
        SizedBox(height: Platform.isIOS ? 30 : 30),
      ],
    );
  }
}
