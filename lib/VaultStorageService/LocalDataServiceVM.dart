import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalance.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/StaticAssetList.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalStorageService with ChangeNotifier {
  dynamic userBalance = 0.0;
  FocusNode focusNode = FocusNode();

  void foucus(BuildContext context) {
    FocusScope.of(context).unfocus();
    print("Focus cleared????????????????????????");
    focusNode.unfocus(); // Ensure focus node is cleared

    notifyListeners();
  }

  UserWalletDataModel? activeWalletData;
  List<UserWalletDataModel> walletListData = [];
  List<AssetModel> assetList = [];
  List<AssetModel> allAssetList = [];
  bool isLoading = false;
  bool creatingNewWallet = false; // Flag for creating new wallet

  // Replace GetStorage instance with Hive box
  Box? walletBox;
  Box? coinBox;

  VaultStorageService vaultStorageService = VaultStorageService();

  // Constructor to initialize Hive boxes
  LocalStorageService() {
    initializeBoxes();
  }

  setLoading(bool loader) {
    isLoading = loader;
    notifyListeners();
  }

  Future<void> initializeBoxes() async {
    walletBox = await Hive.openBox('walletBox');
    coinBox = await Hive.openBox('coinBox');
  }

  void addAssetDatas(AssetModel coin) {
    assetList.add(coin);
    storeAssetDataList(assetList.map((e) => e.toJson()).toList());
  }

  updateWalletListFromJson(List data) {
    walletListData = data
        .map((e) => UserWalletDataModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  setActiveWalletData(UserWalletDataModel data) {
    activeWalletData = data;
    notifyListeners();
  }

  updateCoinList(List<AssetModel> data) {
    assetList = data;
    getAllCoinData();
    notifyListeners();
  }

  getData() async {
    setLoading(true);

    // Example of fetching selected wallet data from Hive
    var selectedList = await vaultStorageService.fetchSelectedList();
    if (selectedList != null) {
      setActiveWalletData(selectedList);
    }

    // Read wallet data from Hive
    updateWalletListFromJson(await vaultStorageService.getWalletList());

    List list = fetchStoredData();
    List<AssetModel> coins = list
        .map((e) => AssetModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (creatingNewWallet) {
      assetList = mandatoryAssets(coins);
      creatingNewWallet =
          false; // Reset the flag after ensuring mandatory coins

    } else {
      if (coins.isNotEmpty && coins[0].rpcURL == "https://nvxscan.com/") {
        coins.removeAt(0);

        coins.insert(
            0,
            AssetModel.fromJson({
              "rpcURL": "https://www.nvxoscan.com/",
              "explorerURL": "https://nvxoexplorer.com/",
              "coinSymbol": "NVXO",
              "coinName": "NVXO Chain",
              "imageUrl":
                  "https://firebasestorage.googleapis.com/v0/b/nvwallet-5ec7e.appspot.com/o/images%2FAsset%2064x.png?alt=media&token=1e803128-1a39-4bc0-8f32-abf2bca83263",
              "balanceFetchAPI": "",
              "sendAmountAPI": "",
              "address": "",
              "coinType": "1",
              "tokenAddress": "",
              "tokenDecimal": "",
              "network": "NVXO Chain",
              "gasPriceSymbol": "NVXO",
            }));
      }
      assetList = coins;
    }

    storeAssetDataList(assetList.map((e) => e.toJson()).toList());
    getAllCoinData();
    setLoading(false);
  }

  List<String> assetBalance1 = [];



  // Future<void> fetchAndStoreTrendingTokens(String network) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("https://api.coingecko.com/api/v3/search/trending"),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final List<dynamic> coins = data['coins'];
  //
  //       List<AssetModel> trendingAssets = coins.map((c) {
  //         final token = c['item'];
  //         // Map network selection if needed
  //         final rpcURLs = {
  //           "ETH": "https://mainnet.infura.io/v3/${apiKeyService.infuraKey}",
  //           "BNB": "https://bsc-dataseed.binance.org",
  //           "SOL": "https://api.mainnet-beta.solana.com",
  //           "TRX": "https://api.trongrid.io",
  //         };
  //
  //         return AssetModel(
  //           coinName: token['name'] ?? '',
  //           coinSymbol: token['symbol']?.toUpperCase() ?? '',
  //           imageUrl: token['thumb'] ??
  //               "https://s2.coinmarketcap.com/static/img/coins/64x64/1.png",
  //           tokenAddress: "",
  //           network: network,
  //           coinType: "2", // Treat as token type
  //           rpcURL: rpcURLs[network] ?? rpcURLs["BNB"]!,
  //           gasPriceSymbol: network,
  //         );
  //       }).toList();
  //
  //       // Merge trending tokens with existing assetList without duplicates
  //       for (var asset in trendingAssets) {
  //         if (!assetList.any(
  //                 (e) => e.coinSymbol == asset.coinSymbol && e.network == asset.network)) {
  //           assetList.add(asset);
  //         }
  //       }
  //
  //       // Save updated list to Hive
  //       await storeAssetDataList(assetList.map((e) => e.toJson()).toList());
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print("Error fetching trending tokens: $e");
  //   }
  // }


  Future<void> fetchCoinBalance() async {
    var data = await assetBalance.fetchBalances(assetList, activeWalletData!);
    assetBalance1 = [];
    assetBalance1 = data;
    notifyListeners();
  }

  List<AssetModel> mandatoryAssets(List<AssetModel> coins) {
    for (var mandatoryCoin in mandatoryCoinList) {
      if (!coins
          .any((coin) => coin.coinSymbol == mandatoryCoin['coinSymbol'])) {
        coins.add(AssetModel.fromJson(mandatoryCoin));
      }
    }

    if (coins.isNotEmpty && coins[0].rpcURL == "https://nvxscan.com/") {
      coins.removeAt(0);

      coins.insert(
          0,
          AssetModel.fromJson({
            "rpcURL": "https://www.nvxoscan.com/",
            "explorerURL": "https://nvxoexplorer.com/",
            "coinSymbol": "NVXO",
            "coinName": "NVXO Chain",
            "imageUrl":
                "https://firebasestorage.googleapis.com/v0/b/nvwallet-5ec7e.appspot.com/o/images%2FAsset%2064x.png?alt=media&token=1e803128-1a39-4bc0-8f32-abf2bca83263",
            "balanceFetchAPI": "",
            "sendAmountAPI": "",
            "address": "",
            "coinType": "1",
            "tokenAddress": "",
            "tokenDecimal": "",
            "network": "NVXO Chain",
            "gasPriceSymbol": "NVXO",
          }));
    }

    return coins;
  }

  removeMapValue(AssetModel data, BuildContext context) async {
    List list = fetchStoredData();

    list.removeWhere((element) =>
        element['rpcURL'] == data.rpcURL &&
        element['explorerURL'] == data.explorerURL &&
        element['coinSymbol'] == data.coinSymbol &&
        element['coinName'] == data.coinName &&
        element['tokenAddress'] == data.tokenAddress &&
        element['address'] == data.address &&
        element['gasPriceSymbol'] == data.gasPriceSymbol &&
        element['imageUrl'] == data.imageUrl);

    await storeAssetDataList(list);
    updateCoinList(list.map((e) => AssetModel.fromJson(e)).toList());
  }

  Future<void> storeAssetDataList(List coinList) async {
    await coinBox?.put(
      activeWalletData != null
          ? '${activeWalletData!.walletAddress}_coinList'
          : 'coinList',
      coinList,
    );
    notifyListeners();
  }

  bool isExistingAddress(List dataList, Map data) {
    for (var map in dataList) {
      if (map["coinType"] == "1") {
        if (map["rpcURL"] == data["rpcURL"]) {
          return true;
        }
      } else if (map["coinType"] == "3") {
        if (map["explorerURL"] == data["explorerURL"]) {
          return true;
        }
      }
    }
    return false;
  }

  bool isManagedAddressExists(List dataList, Map data) {
    for (var map in dataList) {
      if (map["coinSymbol"] == data["coinSymbol"] &&
          map["coinName"] == data["coinName"]) {
        return true;
      }
    }
    return false;
  }

  bool tokenExists(List dataList, Map data) {
    for (var map in dataList) {
      if (map["rpcURL"] == data["rpcURL"] &&
          map["tokenAddress"] == data["tokenAddress"]) {
        return true;
      }
    }
    return false;
  }

  void openCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).bottomAppBarTheme.color ?? Color(0xFFD4D4D4),
          contentPadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppText(
                        "Chain Added Successfully!",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText(
                      message,
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (builder) => AppBottomNav(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.pinkAccent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 4, bottom: 4),
                          child: AppText(
                            "OK",
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
      },
    );
  }

  Future<bool> addAssetData(
      Map<String, String> map, BuildContext context) async {
    List list = fetchStoredData();
    if (!isExistingAddress(list, map)) {
      list.add(map);
      await storeAssetDataList(list);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<LocalStorageService>(context, listen: false).getData();
      });
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true; // Indicate that the coin was added successfully
    } else {
      Navigator.pop(context);
      Utils.snackBarErrorMessage("Coin is already added");
      return false; // Indicate that the coin was not added
    }
  }

  Future<bool> manageWalletCoins(
      Map<String, String> map, BuildContext context) async {
    List list = fetchStoredData();
    if (!isManagedAddressExists(list, map)) {
      list.add(map);
      await storeAssetDataList(list);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<LocalStorageService>(context, listen: false).getData();
      });
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true; // Indicate that the coin was added successfully
    } else {
      Navigator.pop(context);
      Utils.snackBarErrorMessage("Coin is already added");
      return false; // Indicate that the coin was not added
    }
  }

  getAllCoinData() {
    var appCoins = CoinListConfig.coinModelList
        .where((element) => element.coinType == "1" || element.coinType == "3")
        .toList();
    var userCoins =
        assetList.where((element) => element.coinType == "1").toList();
    var combinedList = [...appCoins, ...userCoins];

    allAssetList = combinedList.fold<List<AssetModel>>([], (unique, element) {
      if (!unique.any((e) => e.coinType == "1" && e.rpcURL == element.rpcURL)) {
        unique.add(element);
      }
      return unique;
    });

    notifyListeners();
  }

  Future<bool> addTokenData(
      Map<String, String> map, BuildContext context) async {
    List list = fetchStoredData();
    print(map);
    if (!tokenExists(list, map)) {
      list.add(map);
      await storeAssetDataList(list);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<LocalStorageService>(context, listen: false).getData();
      });
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true; // Indicate that the coin was added successfully
    } else {
      Navigator.pop(context);
      Utils.snackBarErrorMessage("Token is already added");
      return false; // Indicate that the coin was not added
    }
  }

  List fetchStoredData() {
    return coinBox?.get(
          activeWalletData != null
              ? '${activeWalletData!.walletAddress}_coinList'
              : 'coinList',
          defaultValue: [],
        ) ??
        [];
  }
}
