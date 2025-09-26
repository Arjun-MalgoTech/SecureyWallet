import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';

class AssetJson extends StatefulWidget {
  final String jsonFileName;

  const AssetJson({Key? key, required this.jsonFileName}) : super(key: key);

  @override
  _AssetJsonState createState() => _AssetJsonState();
}

class _AssetJsonState extends State<AssetJson> {
  AssetModel? coinData;
  @override
  void initState() {
    super.initState();
    loadJson();
  }

  List<dynamic>? jsonData = [];
  List<dynamic>? filteredData = []; // Change the type to List<dynamic>?

  Future<void> loadJson() async {
    String data = await rootBundle.loadString(
        "assets/JsonFile/${widget.jsonFileName.toLowerCase()}tokens");

    setState(() {
      jsonData = json.decode(data) as List<dynamic>;
      filteredData = jsonData; // Parse as List
    });
  }

  void _filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredData = jsonData;
      });
      return;
    }
    setState(() {
      filteredData = jsonData!.where((token) {
        String name = token['name'].toString().toLowerCase();
        String symbol = token['symbol'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            symbol.contains(query.toLowerCase());
      }).toList();
    });
  }

  TextEditingController searchController = TextEditingController();
  void clearSearch() {
    searchController.clear();
    setState(() {
      filteredData = jsonData;
    });
  }

  LocalStorageService localStorageService = LocalStorageService();
  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Container(
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
        ),
        title: AppText("Manage Crypto"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: Center(
                child: TextField(
                  controller: searchController,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).bottomAppBarTheme.color ??
                            Color(0xFFD4D4D4),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      size: 16,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              clearSearch();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ))
                        : SizedBox(),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Theme.of(context).bottomAppBarTheme.color ??
                        Color(0xFFD4D4D4),
                    filled: true,
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
            child: jsonData == null
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.red,
                  ))
                : searchController.text.isEmpty
                    ? ListView.builder(
                        itemCount: jsonData!.length,
                        itemBuilder: (context, index) {
                          final token = jsonData![index];
                          bool isExisting = localStorageService.assetList.any(
                              (element) =>
                                  element.coinName!.toLowerCase() ==
                                      token['name'].toString().toLowerCase() &&
                                  element.gasPriceSymbol!.toLowerCase() ==
                                      token['gasPriceSymbol']
                                          .toString()
                                          .toLowerCase());
                          int existingIndex = localStorageService.assetList
                              .indexWhere((element) =>
                                  element.coinName!.toLowerCase() ==
                                      token['name'].toString().toLowerCase() &&
                                  element.gasPriceSymbol!.toLowerCase() ==
                                      token['gasPriceSymbol']
                                          .toString()
                                          .toLowerCase());
                          // Get each token from the list
                          return ListTile(
                            leading: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white70,
                                  backgroundImage:
                                      NetworkImage(token['logoURI']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.black38,
                                    backgroundImage: NetworkImage(
                                      token["networkimage"],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            title: AppText(
                              token['name'],
                            ),
                            subtitle: AppText(token['symbol']),
                            trailing: Switch(
                              value: isExisting,
                              activeColor: Colors.white,
                              inactiveThumbColor: Colors.white,
                              activeTrackColor: Color(0xFFB982FF),
                              inactiveTrackColor: Colors.grey[350],
                              onChanged: (bool newValue) {
                                showLoaderDialog(context);
                                Future.delayed(Duration(seconds: 1), () async {
                                  if (isExisting) {
                                    localStorageService.removeMapValue(
                                        localStorageService
                                            .assetList[existingIndex],
                                        context);
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      isExisting = newValue;
                                    });
                                    String coinAddress = "";
                                    if (token["network"] == "TRON" ||
                                        token["network"] == "Solana") {
                                      print('suscess');
                                      coinAddress = await assetAddressGenerate
                                          .generateAddress(
                                              token["gasPriceSymbol"],
                                              localStorageService
                                                  .activeWalletData!.mnemonic);
                                    }
                                    print('//$coinAddress');
                                    await localStorageService.addTokenData({
                                      "rpcURL": token["rpcurl"],
                                      "explorerURL": token["explorerURL"],
                                      "coinSymbol": token["symbol"],
                                      "coinName": token["name"],
                                      "imageUrl": token["logoURI"],
                                      "balanceFetchAPI": "",
                                      "sendAmountAPI": "",
                                      "address": coinAddress,
                                      "coinType": "2",
                                      "tokenAddress": token["address"],
                                      "tokenDecimal": token["decimal"],
                                      "network": token["network"],
                                      "gasPriceSymbol": token["gasPriceSymbol"]
                                    }, context);

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) async {
                                      Provider.of<LocalStorageService>(context,
                                              listen: false)
                                          .getData();
                                      Provider.of<LocalStorageService>(context,
                                              listen: false)
                                          .fetchCoinBalance();
                                      Provider.of<AssetTransactionAPI>(context,
                                              listen: false)
                                          .getBalance(
                                              localStorageService.assetList,
                                              localStorageService
                                                  .activeWalletData!
                                                  .privateKey);
                                    });
                                  }
                                });
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: filteredData!.length,
                        itemBuilder: (context, index) {
                          final token = filteredData![index];
                          bool isExisting = localStorageService.assetList.any(
                              (element) =>
                                  element.coinName!.toLowerCase() ==
                                      token['name'].toString().toLowerCase() &&
                                  element.gasPriceSymbol!.toLowerCase() ==
                                      token['gasPriceSymbol']
                                          .toString()
                                          .toLowerCase());
                          int existingIndex = localStorageService.assetList
                              .indexWhere((element) =>
                                  element.coinName!.toLowerCase() ==
                                      token['name'].toString().toLowerCase() &&
                                  element.gasPriceSymbol!.toLowerCase() ==
                                      token['gasPriceSymbol']
                                          .toString()
                                          .toLowerCase());
                          // Get each token from the list
                          return ListTile(
                            leading: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black38,
                                  backgroundImage:
                                      NetworkImage(token['logoURI']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.black38,
                                    backgroundImage: NetworkImage(
                                      token["networkimage"],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            title: AppText(
                              token['name'],
                            ),
                            subtitle: AppText(token['symbol']),
                            trailing: Switch(
                              value: isExisting,
                              activeColor: Colors.white,
                              inactiveThumbColor: Colors.white,
                              activeTrackColor: Color(0xFFB982FF),
                              inactiveTrackColor: Colors.grey[350],
                              onChanged: (bool newValue) {
                                showLoaderDialog(context);
                                Future.delayed(Duration(seconds: 1), () async {
                                  if (isExisting) {
                                    localStorageService.removeMapValue(
                                        localStorageService
                                            .assetList[existingIndex],
                                        context);
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      isExisting = newValue;
                                    });
                                    String coinAddress = "";
                                    if (token["network"] == "TRON" ||
                                        token["network"] == "Solana") {
                                      print('suscess');
                                      coinAddress = await assetAddressGenerate
                                          .generateAddress(
                                              token["gasPriceSymbol"],
                                              localStorageService
                                                  .activeWalletData!.mnemonic);
                                    }
                                    print('//$coinAddress');
                                    await localStorageService.addTokenData({
                                      "rpcURL": token["rpcurl"],
                                      "explorerURL": token["explorerURL"],
                                      "coinSymbol": token["symbol"],
                                      "coinName": token["name"],
                                      "imageUrl": token["logoURI"],
                                      "balanceFetchAPI": "",
                                      "sendAmountAPI": "",
                                      "address": coinAddress,
                                      "coinType": "2",
                                      "tokenAddress": token["address"],
                                      "tokenDecimal": token["decimal"],
                                      "network": token["network"],
                                      "gasPriceSymbol": token["gasPriceSymbol"]
                                    }, context);

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) async {
                                      Provider.of<LocalStorageService>(context,
                                              listen: false)
                                          .getData();
                                      Provider.of<LocalStorageService>(context,
                                              listen: false)
                                          .fetchCoinBalance();
                                      Provider.of<AssetTransactionAPI>(context,
                                              listen: false)
                                          .getBalance(
                                              localStorageService.assetList,
                                              localStorageService
                                                  .activeWalletData!
                                                  .privateKey);
                                    });
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).shadowColor,
            content: SizedBox(
              height: SizeConfig.height(context, 7),
              width: SizeConfig.height(context, 5),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GradientAppText(
                    text: "Loading...",
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
