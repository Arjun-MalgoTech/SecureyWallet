import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/btc_generator.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAssetAddress extends StatefulWidget {
  final UserWalletDataModel userData;
  dynamic address;

  AllAssetAddress({
    Key? key,
    required this.userData,
    this.address,
  }) : super(key: key);

  @override
  State<AllAssetAddress> createState() => _AllAssetAddressState();
}

class _AllAssetAddressState extends State<AllAssetAddress> {
  LocalStorageService localStorageService = LocalStorageService();
  List<AssetModel> assetData = [];
  Map<String, String> addresses = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    assetData.addAll(CoinListConfig.coinModelList);

    _loadAddresses();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _generateAddresses() async {
    final mnemonic = widget.userData.mnemonic;
    final walletId = widget.userData.privateKey;
    addresses['btc'] = btcMainnet(mnemonic);
    addresses['tbtc'] = btcTestnet(mnemonic);
    // addresses['tdoge'] =
    //     assetAddressGenerate.generateAddress('tDOGE', mnemonic);
    // addresses['doge'] = assetAddressGenerate.generateAddress('DOGE', mnemonic);
    // addresses['ltc'] = assetAddressGenerate.generateAddress('LTC', mnemonic);
    // addresses['tltc'] = assetAddressGenerate.generateAddress('tLTC', mnemonic);
    addresses['trx'] = assetAddressGenerate.generateAddress('TRX', mnemonic);
    addresses['ttrx'] = assetAddressGenerate.generateAddress('TRX', mnemonic);
    addresses['sol'] = assetAddressGenerate.generateAddress('SOL', mnemonic);
    addresses['tsol'] = assetAddressGenerate.generateAddress('SOL', mnemonic);
    // addresses['kava'] = assetAddressGenerate.generateAddress('KAVA', mnemonic);
    // addresses['dot'] = assetAddressGenerate.generateAddress('DOT', mnemonic);
    // addresses['tdot'] = assetAddressGenerate.generateAddress('DOT', mnemonic);
    addresses['xrp'] = assetAddressGenerate.generateAddress('XRP', mnemonic);
    addresses['txrp'] = assetAddressGenerate.generateAddress('XRP', mnemonic);

    await _saveAddresses(walletId);
  }

  Future<void> _saveAddresses(String walletId) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in addresses.entries) {
      await prefs.setString('$walletId-${entry.key}', entry.value);
    }
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final walletId = widget.userData.privateKey;

    for (var coin in CoinListConfig.coinModelList) {
      final address =
          prefs.getString('$walletId-${coin.coinSymbol!.toLowerCase()}');
      if (address != null) {
        addresses[coin.coinSymbol!.toLowerCase()] = address;
      }
    }

    if (addresses.isEmpty) {
      await _generateAddresses();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _filterData(String query) {
    setState(() {
      assetData.clear();
      if (query.isEmpty) {
        assetData.addAll(CoinListConfig.coinModelList);
      } else {
        assetData.addAll(CoinListConfig.coinModelList
            .where((element) =>
                element.coinSymbol!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                element.coinName!.toLowerCase().contains(query.toLowerCase()))
            .toList());
        assetData = assetData.toSet().toList();
      }
    });
  }

  Future<void> _clearAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final walletId = widget.userData.privateKey;
    for (var coin in CoinListConfig.coinModelList) {
      await prefs.remove('$walletId-${coin.coinSymbol!.toLowerCase()}');
    }
  }

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    String EthAddress = "${widget.address}";

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
        ),
        title: AppText(
          'Your addresses',
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.purpleAccent[100],
            ))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    child: Center(
                      child: TextField(
                        onChanged: _filterData,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).bottomAppBarTheme.color ??
                                      Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            size: 16,
                          ),
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(30),
                          ),
                          fillColor: Theme.of(context)
                                  .bottomAppBarTheme
                                  .color ??
                              const Color(0xFFD4D4D4), // Color without border
                          filled:
                              true, // Required to fill the TextField background with color
                        ),
                        style: TextStyle(
                          decorationThickness: 0.0,
                          fontFamily: 'LexendDeca',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surfaceBright,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: assetData.isEmpty
                      ? Center(
                          child: GradientAppText(
                              text: "No data found", fontSize: 16))
                      : ListView.builder(
                          itemCount: assetData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final coinSymbol =
                                assetData[index].coinSymbol!.toLowerCase();
                            final address = addresses[coinSymbol] ?? EthAddress;

                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: const Color(0xFF202832),
                                    child: Image.network(
                                        assetData[index].imageUrl!,
                                        errorBuilder: (_, obj, trc) {
                                      return AppText(
                                        assetData[index]
                                            .coinSymbol
                                            .toString()
                                            .characters
                                            .first,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      );
                                    })),
                              ),
                              title: AppText(
                                assetData[index].coinSymbol!,
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                              ),
                              subtitle: AppText(
                                address,
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                fontSize: 14,
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: address));
                                  Utils.snackBar("Copied to clipboard");
                                },
                                child: Icon(
                                  Icons.copy,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
