import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Crypto_Transactions/ReceiveCryptoPage.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class ReceiveAssetPage extends StatefulWidget {
  const ReceiveAssetPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ReceiveAssetPage> createState() => _ReceiveAssetPageState();
}

class _ReceiveAssetPageState extends State<ReceiveAssetPage> {
  LocalStorageService localStorageService = LocalStorageService();
  bool isLoading = true;

  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  void filterCoins(String query) {
    setState(() {
      filteredCoins = localStorageService.assetList.where((coin) {
        return (coin.coinSymbol!.toLowerCase().contains(query.toLowerCase()) ||
            coin.network!.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  bool isTextVisible = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Map<String, List<String>> result = {};
  TextEditingController searchController = TextEditingController();
  List<AssetModel> filteredCoins = [];
  bool listEmpty = false;

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
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
        title: AppText(
          "Receive",

          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: Center(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none, // No border
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).bottomAppBarTheme.color ??
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
                    suffixIcon: searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {
                                localStorageService.assetList;
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : SizedBox(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // No border
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Theme.of(context).bottomAppBarTheme.color ??
                        Color(0xFFD4D4D4), // Color without border
                    filled:
                        true, // Required to fill the TextField background with color
                  ),
                  onChanged: filterCoins,
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
          Column(
            children: [
              SizedBox(
                height: SizeConfig.height(
                    context, localStorageService.assetList.length * 9),
                child: StreamBuilder(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> data =
                          snapshot.data as Map<String, dynamic>;
                      String symbol = data['s'] ?? "";
                      for (var value in localStorageService.assetList) {
                        if (symbol
                            .toLowerCase()
                            .contains(value.coinSymbol!.toLowerCase())) {
                          if (result.containsKey(value.coinSymbol!)) {
                            result[value.coinSymbol!] = [data['c'], data['p']];
                          } else {
                            result.addAll({
                              value.coinSymbol!: [data['c'], data['p']]
                            });
                          }
                        }
                      }
                    }

                    return searchController.text.isNotEmpty
                        ? ListView.builder(
                            itemCount: filteredCoins
                                .length, // Set the number of items to 5
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0, left: 16, right: 16),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),


                                        border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.08),
                                            ],
                                          ),
                                          width: 0.5,
                                        ),// Make it slightly transparent
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            int originalIndex =
                                                localStorageService
                                                    .assetList
                                                    .indexOf(
                                                        filteredCoins[
                                                            index]);
                                            return ReceiveCrypto(
                                              coinData:
                                                  filteredCoins[index],
                                            );
                                          }));
                                        },
                                        leading: Stack(
                                            alignment:
                                                Alignment.bottomRight,
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor:
                                                    Color(0xFF202832),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(30),
                                                  child: Image.network(
                                                    filteredCoins[index]
                                                        .imageUrl!,
                                                    errorBuilder:
                                                        (_, obj, trc) {
                                                      return AppText(
                                                        filteredCoins[
                                                                index]
                                                            .coinSymbol
                                                            .toString()
                                                            .characters
                                                            .first,
                                                        color: Colors
                                                            .white,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              filteredCoins[index]
                                                          .coinType ==
                                                      "2"
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 5),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    30),
                                                        child: Image
                                                            .network(
                                                          localStorageService.allAssetList.indexWhere((v) =>
                                                                      v.gasPriceSymbol ==
                                                                      filteredCoins[index]
                                                                          .gasPriceSymbol) ==
                                                                  -1
                                                              ? ""
                                                              : localStorageService
                                                                  .allAssetList[localStorageService.allAssetList.indexWhere((v) =>
                                                                      v.gasPriceSymbol ==
                                                                      filteredCoins[index].gasPriceSymbol)]
                                                                  .imageUrl!,
                                                          errorBuilder:
                                                              (_, obj,
                                                                  trc) {
                                                            return AppText(
                                                              filteredCoins[
                                                                      index]
                                                                  .gasPriceSymbol
                                                                  .toString(),
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  7,
                                                            );
                                                          },
                                                          height: 15,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ]),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AppText(
                                                  filteredCoins[index]
                                                      .coinSymbol!,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: Theme.of(
                                                          context)
                                                      .colorScheme
                                                      .surfaceBright,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    decoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  10),
                                                      color: Color(
                                                          0xFF262737),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 4.0,
                                                              right:
                                                                  4.0),
                                                      child: AppText(
                                                        filteredCoins[
                                                                index]
                                                            .network!,
                                                        fontSize: 10,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis, // Ensure truncation here too
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    AppText(
                                                      filteredCoins[
                                                              index]
                                                          .coinName!,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight
                                                              .w400,
                                                      color: Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .surfaceBright,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.width(
                                                          context, 4),
                                                ),
                                                result.containsKey(
                                                        filteredCoins[
                                                                index]
                                                            .coinSymbol!)
                                                    ? Row(
                                                        children: [
                                                          AppText(
                                                            double.parse(result[filteredCoins[index].coinSymbol!]![1].toString()) <
                                                                    0
                                                                ? ''
                                                                : '+',
                                                            fontSize:
                                                                12,
                                                            color: double.parse(result[filteredCoins[index].coinSymbol!]![1].toString()) <
                                                                    0
                                                                ? Color(
                                                                    0xFFFD0000)
                                                                : Colors
                                                                    .green,
                                                          ),
                                                          AppText(
                                                            '${double.parse(result[filteredCoins[index].coinSymbol!]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                                            fontSize:
                                                                13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                            color: double.parse(result[filteredCoins[index].coinSymbol!]![1].toString()) <
                                                                    0
                                                                ? Color(
                                                                    0xFFFD0000)
                                                                : Colors
                                                                    .green,
                                                          ),
                                                        ],
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          )
                        : ListView.builder(
                            itemCount: localStorageService.assetList
                                .length, // Set the number of items to 5
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0, left: 16, right: 16),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.08),
                                            ],
                                          ),
                                          width: 0.5,
                                        ),// Make it slightly transparent
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ReceiveCrypto(
                                              coinData:
                                                  localStorageService
                                                      .assetList[index],
                                            );
                                          }));
                                        },
                                        leading: Stack(
                                            alignment:
                                                Alignment.bottomRight,
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor:
                                                    Color(0xFF202832),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(30),
                                                  child: Image.network(
                                                    localStorageService
                                                        .assetList[
                                                            index]
                                                        .imageUrl!,
                                                    errorBuilder:
                                                        (_, obj, trc) {
                                                      return AppText(
                                                        localStorageService
                                                            .assetList[
                                                                index]
                                                            .coinSymbol
                                                            .toString()
                                                            .characters
                                                            .first,
                                                        color: Colors
                                                            .white,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              localStorageService
                                                          .assetList[
                                                              index]
                                                          .coinType ==
                                                      "2"
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 5),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    30),
                                                        child: Image
                                                            .network(
                                                          localStorageService.allAssetList.indexWhere((v) => v.gasPriceSymbol == localStorageService.assetList[index].gasPriceSymbol) ==
                                                                  -1
                                                              ? ""
                                                              : localStorageService
                                                                  .allAssetList[localStorageService.allAssetList.indexWhere((v) =>
                                                                      v.gasPriceSymbol ==
                                                                      localStorageService.assetList[index].gasPriceSymbol)]
                                                                  .imageUrl!,
                                                          errorBuilder:
                                                              (_, obj,
                                                                  trc) {
                                                            return AppText(
                                                              localStorageService
                                                                  .assetList[
                                                                      index]
                                                                  .gasPriceSymbol
                                                                  .toString(),
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  7,
                                                            );
                                                          },
                                                          height: 15,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ]),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AppText(
                                                  localStorageService
                                                      .assetList[index]
                                                      .coinSymbol!,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: Theme.of(
                                                          context)
                                                      .colorScheme
                                                      .surfaceBright,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    decoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  10),
                                                      color: Color(
                                                          0xFF262737),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 4.0,
                                                              right:
                                                                  4.0),
                                                      child: AppText(
                                                        localStorageService
                                                            .assetList[
                                                                index]
                                                            .network!,
                                                        fontSize: 10,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis, // Ensure truncation here too
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AppText(
                                                  localStorageService
                                                      .assetList[index]
                                                      .coinName!,
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: Theme.of(
                                                          context)
                                                      .colorScheme
                                                      .surfaceBright,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
