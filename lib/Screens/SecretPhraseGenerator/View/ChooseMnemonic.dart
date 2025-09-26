import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:provider/provider.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';

class ChooseMnemonic extends StatefulWidget {
  final String originalMnemonicPhrase;

  ChooseMnemonic(this.originalMnemonicPhrase);

  @override
  _ChooseMnemonicState createState() => _ChooseMnemonicState();
}

class _ChooseMnemonicState extends State<ChooseMnemonic> {
  VaultStorageService vaultStorageService = VaultStorageService();
  late List<List<String>> rows;
  late List<String?> selectedWords;
  TextEditingController textEditingController = TextEditingController();
  String privateKeyHex = '';
  String walletAddress = '';

  String mnemonicPhrase = "";

  @override
  void initState() {
    super.initState();
    // getStorageService.init();
    rows = splitAndShuffleRows(widget.originalMnemonicPhrase);
    selectedWords = List.generate(rows.length, (index) => null);
  }

  List<List<String>> splitAndShuffleRows(String phrase) {
    List<String> words = phrase.split(' ');
    List<List<String>> rows = [];

    for (int i = 0; i < words.length; i += 3) {
      List<String> row = words.sublist(i, i + 3);
      row.shuffle();
      rows.add(row);
    }

    return rows;
  }

  void selectWord(String word, int rowIndex) {
    setState(() {
      if (selectedWords[rowIndex] == null || selectedWords[rowIndex] != word) {
        selectedWords[rowIndex] = word;
      } else {
        selectedWords[rowIndex] = null;
      }
    });
  }

  bool isOrderSame() {
    final List<String> originalWords = widget.originalMnemonicPhrase.split(' ');

    // Indices of the words to be checked
    List<int> selectedIndices = [0, 3, 6, 9];

    if (selectedIndices.length != selectedWords.length) {
      return false;
    }

    for (int i = 0; i < selectedIndices.length; i++) {
      int selectedIndex = selectedIndices[i];
      if (originalWords[selectedIndex] != selectedWords[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> generatePrivateKeyAndAddressFromMnemonic() async {
    final mnemonic = widget.originalMnemonicPhrase;
    mnemonicPhrase = mnemonic;
    if (bip39.validateMnemonic(mnemonic)) {
      final seed = bip39.mnemonicToSeed(mnemonic);
      final root = bip32.BIP32.fromSeed(seed);
      final child =
          root.derivePath("m/44'/60'/0'/0/0"); // Ethereum derivation path
      final privateKey = child.privateKey;

      final privateKeyHex = HEX.encode(privateKey!);

      final rpcUrl = 'https://mainnet.infura.io/v3/your_infura_project_id';
      final httpClient = Client();
      final ethClient = Web3Client(rpcUrl, httpClient);

      final credentials =
          await ethClient.credentialsFromPrivateKey(privateKeyHex);
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

  LocalStorageService localStorageService = LocalStorageService();
  bool isLoading = false;
  List<AssetModel> coinData = [];
  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool allWordsSelected = selectedWords.every((word) => word != null);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText("Confirm Secret Phrase"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              color: Colors.transparent,
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).indicatorColor)),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              AppText(
                'Please select the correct seed phrase from the options\nbelow.',
                textAlign: TextAlign.center,
                fontSize: 12,
                color: Colors.grey[500],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rows.asMap().entries.map((entry) {
                    int rowIndex = entry.key;
                    List<String> row = entry.value;

                    // Add a heading for each row
                    Widget heading = Padding(
                      padding: const EdgeInsets.only(
                        top: 32.0,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Word #${rowIndex * 3 + 1}', // Adjust the formula based on your requirements
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceBright, // Change the color as needed
                            ),
                          ),
                        ],
                      ),
                    );

                    // Create a row with FilterChips
                    Widget rowWithChips = Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(row.length, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: selectedWords[rowIndex] == row[index]
                                  ? Color(
                                      0xFFB982FF) // Change color when selected
                                  : Colors.white30.withOpacity(0.2),
                            ),
                            width: 100,
                            child: FilterChip(
                              side: BorderSide(
                                color: selectedWords[rowIndex] == row[index]
                                    ? Color(0xFFB982FF)
                                    : Colors
                                        .transparent, // Change color when selected
                              ),
                              backgroundColor: selectedWords[rowIndex] ==
                                      row[index]
                                  ? Color(0xFFB982FF)
                                  : Colors
                                      .transparent, // Change color when selected
                              label: Text(
                                '${row[index]}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                ),
                              ),
                              onSelected: (bool value) {
                                selectWord(row[index], rowIndex);
                              },
                            ),
                          );
                        }),
                      ),
                    );

                    // Wrap heading and rowWithChips in a column
                    return Column(
                      children: [heading, rowWithChips],
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 44.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            colors: allWordsSelected
                                ? [
                                    Color(0xFF912ECA),
                                    Color(0xFF912ECA),
                                    Color(0xFF793CDE),
                                    Color(0xFF793CDE),
                                  ]
                                : [Colors.grey, Colors.grey])),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Show the loader
                        });
                        await Future.delayed(Duration(milliseconds: 100));
                        if (selectedWords.every((word) => word != null) &&
                            isOrderSame() &&
                            allWordsSelected) {
                          setState(() {
                            isLoading = true; // Show the loader
                          });
                          await generatePrivateKeyAndAddressFromMnemonic();

                          UserWalletDataModel walletDataModel =
                              UserWalletDataModel(
                                  walletName: "Wallet 1 (Main)",
                                  walletAddress: walletAddress,
                                  mnemonic: mnemonicPhrase,
                                  privateKey: privateKeyHex);
                          localStorageService.creatingNewWallet = true;
                          await vaultStorageService.addWalletToList(
                              ApiKeyService.nvWalletList,
                              walletDataModel.toJson());
                          _updatePrintedValue();
                          if (privateKeyHex.isNotEmpty && mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Provider.of<LocalStorageService>(context,
                                      listen: false)
                                  .getData();
                            });
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppBottomNav(),
                                ),
                                (Route<dynamic> route) =>
                                    false, // Replace 'false' with your condition
                              );

                              // Show the bottom sheet when the screen loads
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    color: Theme.of(context)
                                            .bottomAppBarTheme
                                            .color ??
                                        Color(0xFFD4D4D4),
                                    height: 250,
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.clear,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceBright,
                                              )
                                            ],
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/Images/correct.png',
                                          height: 60,
                                          width: 60,
                                        ),
                                        SizedBox(height: 10.0),
                                        AppText(
                                          'Your Wallet Is Ready.',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                        ),
                                        SizedBox(height: 10.0),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            height: 44.0,
                                            width:
                                                SizeConfig.width(context, 25),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xFF912ECA),
                                                  Color(0xFF912ECA),
                                                  Color(0xFF793CDE),
                                                  Color(0xFF793CDE),
                                                ])),
                                            child: Center(
                                                child: AppText(
                                              'Start',
                                              color: Colors.black,
                                            )),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          } else {}
                        } else {
                          setState(() {
                            isLoading = false; // Show the loader
                          });
                          allWordsSelected
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Theme.of(context).primaryColorLight ??
                                              Color(0xFFD4D4D4),
                                      title: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/Images/fail.png',
                                            height: 30,
                                            width: 30,
                                          ),
                                          AppText(
                                            'Incorrect',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceBright,
                                            fontSize: 20,
                                          ),
                                        ],
                                      )),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AppText(
                                            'Selections not matched.\nPlease try again.',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceBright,
                                            fontSize: 16,
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        ReuseElevatedButton(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 45,
                                          text: 'Try again',
                                          textcolor: Colors.black,
                                          gradientColors: [
                                            Color(0XFF42E695),
                                            Color(0XFF3BB2BB)
                                          ],
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : SizedBox();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent),
                      child: isLoading
                          ? Center(
                              child: Transform.scale(
                              scale: 0.5, // Reduces the size by half
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ))
                          : AppText(
                              'Confirm',
                              color: Colors.black,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
