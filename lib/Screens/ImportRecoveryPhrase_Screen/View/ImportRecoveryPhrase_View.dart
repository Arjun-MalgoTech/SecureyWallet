import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/QRView/QRView_Android.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:hex/hex.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

import '../MnemonicSecretPhrase/MnemonicSecretWords.dart' show mnemonicSecretWords;

class RestoreWalletFromPhrase extends StatefulWidget {
  const RestoreWalletFromPhrase({super.key});

  @override
  State<RestoreWalletFromPhrase> createState() =>
      _RestoreWalletFromPhraseState();
}

class _RestoreWalletFromPhraseState extends State<RestoreWalletFromPhrase> {
  final TextEditingController mnemonicController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LocalStorageService localStorageService = LocalStorageService();
  final VaultStorageService vaultStorageService = VaultStorageService();
  String privateKeyHex = '';
  String walletAddress = '';
  List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    final fetchLocalDataVM = context.watch<LocalStorageService>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLabel('Wallet Name'),
              _buildWalletNameInput(context),
              _buildLabel('Seed Phrase'),
              _buildSeedPhraseInput(context),
              _buildSeedPhraseNote(),
              _buildRecoverWalletButton(context, fetchLocalDataVM),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: AppText(
        'Multi-coin wallet',
        color: Theme.of(context).colorScheme.surfaceBright,
      ),
      centerTitle: true,
      leading: BackButton(color: Theme.of(context).indicatorColor),
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code, color: Theme.of(context).indicatorColor),
          onPressed: _scanQRCode,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [AppText(text, color: Color(0xFFB7B7B7))],
      ),
    );
  }

  Widget _buildWalletNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: nameController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.surfaceBright,
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          hintText: "Wallet 1 (Main)",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white24.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceBright,
              width: 0.3,
            ),
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSeedPhraseInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: mnemonicController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateMnemonic,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surfaceBright,
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
            maxLines: 4,
            onChanged: _updateSuggestions,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white24.withOpacity(0.1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 45, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  width: 0.3,
                ),
              ),
              suffixIcon: TextButton(
                onPressed: _pasteFromClipboard,
                child: AppText(
                  "PASTE",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB982FF),
                ),
              ),
              border: OutlineInputBorder(),
            ),
          ),
          if (suggestions.isNotEmpty) _buildSuggestionsList(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      constraints: BoxConstraints(maxHeight: 40),
      margin: const EdgeInsets.only(top: 15),
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () => _selectSuggestion(suggestions[index]),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Color(0xFFB982FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: AppText(suggestions[index], color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeedPhraseNote() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: AppText(
          "Usually 12 words, but sometimes 18 or 24, each\nseparated by a single space.",
          fontSize: 13,
          color: Color(0xFFB7B7B7),
        ),
      ),
    );
  }

  Widget _buildRecoverWalletButton(
      BuildContext context, LocalStorageService fetchVM) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            await _generateKeysAndSave(context, fetchVM);
          }
        },
        child: ReuseElevatedButton(
          width: MediaQuery.of(context).size.width,
          height: 45,
          text: 'Recover Wallet',
          textcolor: Colors.black,
          gradientColors: [Color(0XFF42E695), Color(0XFF3BB2BB)],
        ),
      ),
    );
  }

  String? _validateMnemonic(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Secret Phrases is required';
    final words = value.trim().split(' ');
    if ((words.length == 12 || words.length == 18 || words.length == 24) &&
        value.endsWith(' ')) return 'Mnemonic should not end with a space';
    if (!(words.length == 12 || words.length == 18 || words.length == 24)) {
      return 'Mnemonic should be 12, 18, or 24 words';
    }
    return null;
  }

  void _updateSuggestions(String input) {
    final lastWord = input.trim().split(' ').last;
    setState(() {
      suggestions = mnemonicSecretWords
          .where((word) => word.startsWith(lastWord))
          .take(10)
          .toList();
    });
  }

  void _selectSuggestion(String suggestion) {
    final words = mnemonicController.text.trim().split(' ');
    if (words.isNotEmpty) words[words.length - 1] = suggestion;
    setState(() {
      mnemonicController.text = '${words.join(' ')} ';
      suggestions.clear();
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      mnemonicController.text = data!.text!.trim();
    }
  }

  Future<void> _scanQRCode() async {
    mnemonicController.clear();
    FocusScope.of(context).unfocus();

    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QRView(),
    ));

    if (result != null && result['barcode'] != null) {
      mnemonicController.text = result['barcode'];
    }
  }

  Future<void> _generateKeysAndSave(
      BuildContext context, LocalStorageService fetchVM) async {
    final mnemonic = mnemonicController.text.trim();

    if (!bip39.validateMnemonic(mnemonic)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid Mnemonic')));
      return;
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/0");
    final privateKey = HEX.encode(child.privateKey!);

    final ethClient = Web3Client(
        'https://mainnet.infura.io/v3/your_infura_project_id', Client());
    final credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    final address = await credentials.extractAddress();

    final wallet = UserWalletDataModel(
      walletName: nameController.text.isNotEmpty
          ? nameController.text
          : "Wallet 1 (Main)",
      walletAddress: address.hexEip55,
      mnemonic: mnemonic,
      privateKey: privateKey,
    );

    await vaultStorageService.addWalletToList(
        ApiKeyService.nvWalletList, wallet.toJson());
    fetchVM.creatingNewWallet = true;
    fetchVM.getData();

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => AppBottomNav()), (route) => false);
  }
}
