import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/AssetManager_View/ImportAsset_View/View/ImportAssetTabView.dart';
import 'package:securywallet/Screens/AssetManager_View/MultiChainTokens/MultiChainTokens_View.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class AssetManager extends StatefulWidget {
  const AssetManager({super.key});

  @override
  State<AssetManager> createState() => _AssetManagerState();
}

class _AssetManagerState extends State<AssetManager> {
  LocalStorageService localStorageService = LocalStorageService();

  bool isswitch = false;
  List<AssetModel> coinData = [];
  List<bool> switchValues = [];

  @override
  void initState() {
    super.initState();
    coinData.addAll(CoinListConfig.coinModelList);
    coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assetTx = Provider.of<AssetTransactionAPI>(context, listen: false);
      final local = Provider.of<LocalStorageService>(context, listen: false);
      assetTx.getBalance(local.assetList, local.activeWalletData!.privateKey);
    });
  }

  void _filterData(String query) {
    setState(() {
      coinData.clear();
      if (query.isEmpty) {
        coinData.addAll(CoinListConfig.coinModelList);
        coinData
            .removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
      } else {
        coinData.addAll(CoinListConfig.coinModelList
            .where((element) =>
                element.coinSymbol!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                element.coinName!.toLowerCase().contains(query.toLowerCase()))
            .toList());
        coinData = coinData.toSet().toList();
        coinData
            .removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
      }
    });
  }

  TextEditingController searchController = TextEditingController();
  void clearSearch() {
    searchController.clear();
    setState(() {
      coinData = CoinListConfig.coinModelList;
      coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
    });
  }

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (v, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<LocalStorageService>(context, listen: false).getData();
          Provider.of<LocalStorageService>(context, listen: false)
              .fetchCoinBalance();
        });
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          title: AppText(
            'Manage Crypto',
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
          centerTitle: true,
          actions: [
            InkWell(
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ImportAssetTab();
                  }));
                },
                icon: Container(
                  color: Colors.transparent,
                  child: Icon(
                    Icons.add,
                  ),
                ),
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
            SizedBox(
              width: SizeConfig.width(context, 5),
            ),
          ],
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
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MultiChainTokens();
                }));
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFF262737),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 3, bottom: 3, left: 8, right: 6),
                        child: Row(
                          children: [
                            AppText(
                              'All Network',
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            Icon(
                              Icons.arrow_drop_down_sharp,
                              color: Colors.white70,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: coinData.isEmpty
                  ? Center(
                      child:
                          GradientAppText(text: "No data found", fontSize: 16))
                  : ListView.builder(
                      itemCount: coinData.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool isExisting = localStorageService.assetList.any(
                            (element) =>
                                element.coinName!.toLowerCase() ==
                                coinData[index]
                                    .coinName
                                    .toString()
                                    .toLowerCase());

                        int existingIndex = localStorageService.assetList
                            .indexWhere((element) =>
                                element.coinName!.toLowerCase() ==
                                coinData[index]
                                    .coinName
                                    .toString()
                                    .toLowerCase());
                        return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF202832),
                                  child: Image.network(
                                    coinData[index].imageUrl!,
                                    errorBuilder: (_, obj, trc) {
                                      return AppText(
                                        coinData[index]
                                            .coinSymbol
                                            .toString()
                                            .characters
                                            .first,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      );
                                    },
                                  )),
                            ),
                            title: Row(
                              children: [
                                AppText(
                                  coinData[index].coinSymbol!,
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(0xFF262737),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4.0, right: 4.0),
                                      child: AppText(
                                        coinData[index].network!,
                                        fontSize: 10,
                                        overflow: TextOverflow
                                            .ellipsis, // Ensure truncation here too
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: AppText(
                              coinData[index].coinName!,
                              fontSize: 13,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                            ),
                            trailing: Transform.scale(
                              scale:
                                  0.8, // Adjust this value to make the switch smaller or larger
                              child: Switch(
                                value: isExisting,
                                activeColor: Colors
                                    .purple, // Active color when the switch is on
                                inactiveThumbColor:
                                    Colors.white, // Color of the thumb when off
                                activeTrackColor: Color(
                                    0xFFB982FF), // Active track color when the switch is on
                                inactiveTrackColor: Colors.grey[
                                    350], // Track color when the switch is off
                                onChanged: (bool newValue) {
                                  showLoaderDialog(context);
                                  Future.delayed(Duration(seconds: 1), () {
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
                                      if (coinData[index].coinType == "1") {
                                        localStorageService.manageWalletCoins({
                                          "rpcURL": coinData[index].rpcURL!,
                                          "explorerURL":
                                              coinData[index].explorerURL!,
                                          "coinSymbol":
                                              coinData[index].coinSymbol!,
                                          "coinName": coinData[index].coinName!,
                                          "imageUrl": coinData[index].imageUrl!,
                                          "balanceFetchAPI":
                                              coinData[index].balanceFetchAPI!,
                                          "sendAmountAPI":
                                              coinData[index].sendAmountAPI!,
                                          "address": "",
                                          "coinType": "1",
                                          "tokenAddress": "",
                                          "tokenDecimal": "",
                                          "network": coinData[index].network!,
                                          "gasPriceSymbol":
                                              coinData[index].gasPriceSymbol!
                                        }, context);
                                      } else if (coinData[index].coinType ==
                                          "2") {
                                      } else if (coinData[index].coinType ==
                                          "3") {
                                        localStorageService.manageWalletCoins({
                                          "rpcURL": coinData[index].rpcURL!,
                                          "explorerURL":
                                              coinData[index].explorerURL!,
                                          "coinSymbol":
                                              coinData[index].coinSymbol!,
                                          "coinName": coinData[index].coinName!,
                                          "imageUrl": coinData[index].imageUrl!,
                                          "balanceFetchAPI":
                                              coinData[index].balanceFetchAPI!,
                                          "sendAmountAPI":
                                              coinData[index].sendAmountAPI!,
                                          "address": assetAddressGenerate
                                              .generateAddress(
                                                  coinData[index].coinSymbol!,
                                                  localStorageService
                                                      .activeWalletData!
                                                      .mnemonic),
                                          "coinType": "3",
                                          "tokenAddress": "",
                                          "tokenDecimal": "",
                                          "network": coinData[index].network!,
                                          "gasPriceSymbol":
                                              coinData[index].gasPriceSymbol!
                                        }, context);
                                      }

                                      // WidgetsBinding.instance
                                      //     .addPostFrameCallback((_) async {
                                      //   final assetTx =
                                      //       Provider.of<AssetTransactionAPI>(
                                      //           context,
                                      //           listen: false);
                                      //   final local =
                                      //       Provider.of<LocalStorageService>(
                                      //           context,
                                      //           listen: false);
                                      //   await assetTx.getBalance(
                                      //       local.assetList,
                                      //       local.activeWalletData!.privateKey);
                                      // });

                                      ///old
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) async {
                                        Provider.of<LocalStorageService>(
                                                context,
                                                listen: false)
                                            .getData();
                                        Provider.of<LocalStorageService>(
                                                context,
                                                listen: false)
                                            .fetchCoinBalance();
                                        Provider.of<AssetTransactionAPI>(
                                                context,
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
                            ));
                      },
                    ),
            ),
          ],
        ),
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
                  // SizedBox(
                  //   height: AppSize.height(context, 9),
                  //   width: AppSize.height(context, 10),
                  //   child: const CircularProgressIndicator(
                  //     strokeWidth: 8.0,
                  //     color: Color(0xFFFF56A9),
                  //   ),
                  // ),
                  // SizedBox(height: 20),
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
