import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalance.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/Crypto_Transactions/SendCryptoPage.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class SendAssetsPage extends StatefulWidget {
  const SendAssetsPage({Key? key}) : super(key: key);

  @override
  State<SendAssetsPage> createState() => _SendAssetsPageState();
}

class _SendAssetsPageState extends State<SendAssetsPage> {
  LocalStorageService localStorageService = LocalStorageService();
  bool _isTextFieldEnabled = false; // Initially disabled
  Timer? _timer;
  bool balanceLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      balanceLoading = true;
      await _refresh();
      balanceLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer
    super.dispose();
  }

  var allBalance1;
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  Future<void> _refresh() async {
    await localStorageService.fetchCoinBalance();
    fetchOverallBalances(localStorageService.assetBalance1);
    _isTextFieldEnabled = true;
    setState(() {});
  }

  List<AssetBalanceModel> overallBalances = [];

  Future<void> fetchOverallBalances(List<String>? data) async {
    var balances = data;

    overallBalances = List.generate(localStorageService.assetList.length, (
      index,
    ) {
      return AssetBalanceModel(
        coin: localStorageService.assetList[index], // Coin name
        balance: balances![index], // Corresponding balance
      );
    });
  }

  void filterCoins(String query) {
    setState(() {
      filteredCoins = localStorageService.assetList.where((coin) {
        return coin.coinSymbol != null &&
            (coin.coinSymbol!.toLowerCase().contains(query.toLowerCase()) ||
                coin.network!.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });

    List<String> filtered = [];
    for (var item in filteredCoins) {
      int i = overallBalances.indexWhere((e) => e.coin == item);
      filtered.add(overallBalances[i].balance);
    }
    setState(() {
      allBalance1 = filtered;
    });
  }

  bool isTextVisible = true;

  Map<String, List<String>> result = {};
  TextEditingController searchController = TextEditingController();
  List<AssetModel> filteredCoins = [];

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
            Future.delayed(Duration(milliseconds: 200), () {
              FocusScope.of(context).unfocus();
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).indicatorColor,
            ),
          ),
        ),
        title: AppText(
          "Send",
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0XFF0a0d11),
                        borderRadius: BorderRadius.circular(14),
                        border: GradientBoxBorder(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        enabled: _isTextFieldEnabled,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 20.0,
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
                                    setState(() {
                                      searchController.clear();
                                    });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceBright,
                                  ),
                                )
                              : SizedBox(),

                          border: InputBorder.none,
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: SizeConfig.height(
                    context,
                    localStorageService.assetList.length * 9,
                  ), // Adjust height as needed
                  child: balanceLoading
                      ? Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: CircularProgressIndicator(
                                  color: Colors.purpleAccent[100],
                                ),
                              ),
                            ],
                          ),
                        )
                      : StreamBuilder(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data as Map<String, dynamic>;
                              String symbol = data['s'] ?? "";
                              for (var value in localStorageService.assetList) {
                                if (symbol.toLowerCase().contains(
                                  value.coinSymbol!.toLowerCase(),
                                )) {
                                  if (result.containsKey(value.coinSymbol!)) {
                                    result[value.coinSymbol!] = [
                                      data['c'],
                                      data['p'],
                                    ];
                                  } else {
                                    result.addAll({
                                      value.coinSymbol!: [data['c'], data['p']],
                                    });
                                  }
                                }
                              }
                            }

                            return searchController.text.isNotEmpty
                                ? filteredCoins.isEmpty
                                      ? const Column(
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 150.0,
                                                ),
                                                child: GradientAppText(
                                                  text: "No data found",
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          itemCount: filteredCoins.length,
                                          // Set the number of items to the filtered list length
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 5.0,
                                                left: 16,
                                                right: 16,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: GradientBoxBorder(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.3),
                                                        Colors.white
                                                            .withOpacity(0.05),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    width: 0.5,
                                                  ), // Make it slightly transparent
                                                ),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return SendCryptoPage(
                                                            assetData:
                                                                filteredCoins[index],
                                                            balance:
                                                                (allBalance1 !=
                                                                        null &&
                                                                    index <
                                                                        allBalance1
                                                                            .length
                                                                ? allBalance1[index]
                                                                : "0.00000000"),
                                                            walletData:
                                                                localStorageService
                                                                    .activeWalletData!,
                                                            ethAddress: "",
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  leading: Stack(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor: Color(
                                                          0xFF202832,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                          child: Image.network(
                                                            filteredCoins[index]
                                                                .imageUrl!,
                                                            errorBuilder: (_, obj, trc) {
                                                              return AppText(
                                                                filteredCoins[index]
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
                                                                  const EdgeInsets.only(
                                                                    left: 5,
                                                                  ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      30,
                                                                    ),
                                                                child: Image.network(
                                                                  localStorageService.allAssetList.indexWhere(
                                                                            (
                                                                              v,
                                                                            ) =>
                                                                                v.gasPriceSymbol ==
                                                                                filteredCoins[index].gasPriceSymbol,
                                                                          ) ==
                                                                          -1
                                                                      ? ""
                                                                      : localStorageService
                                                                            .allAssetList[localStorageService.allAssetList.indexWhere(
                                                                              (
                                                                                v,
                                                                              ) =>
                                                                                  v.gasPriceSymbol ==
                                                                                  filteredCoins[index].gasPriceSymbol,
                                                                            )]
                                                                            .imageUrl!,
                                                                  errorBuilder: (_, obj, trc) {
                                                                    return AppText(
                                                                      filteredCoins[index]
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
                                                    ],
                                                  ),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          AppText(
                                                            filteredCoins[index]
                                                                .coinSymbol!,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceBright,
                                                            overflow: TextOverflow
                                                                .ellipsis, // This ensures truncation if needed
                                                          ),
                                                          SizedBox(width: 10),

                                                          // Use Flexible instead of Expanded
                                                          Flexible(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    color: Color(
                                                                      0xFF262737,
                                                                    ),
                                                                  ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0,
                                                                    ),
                                                                child: AppText(
                                                                  filteredCoins[index]
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
                                                          result.containsKey(
                                                                filteredCoins[index]
                                                                    .coinSymbol!,
                                                              )
                                                              ? AppText(
                                                                  "\$${double.parse(result[filteredCoins[index].coinSymbol!]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).colorScheme.surfaceBright,
                                                                )
                                                              : AppText(
                                                                  filteredCoins[index]
                                                                              .coinType ==
                                                                          '2'
                                                                      ? "Token"
                                                                      : "Crypto",
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).colorScheme.surfaceBright,
                                                                ),
                                                          SizedBox(
                                                            width:
                                                                SizeConfig.width(
                                                                  context,
                                                                  4,
                                                                ),
                                                          ),
                                                          result.containsKey(
                                                                filteredCoins[index]
                                                                    .coinSymbol!,
                                                              )
                                                              ? Row(
                                                                  children: [
                                                                    AppText(
                                                                      double.parse(
                                                                                result[filteredCoins[index].coinSymbol!]![1].toString(),
                                                                              ) <
                                                                              0
                                                                          ? ''
                                                                          : '+',
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          double.parse(
                                                                                result[filteredCoins[index].coinSymbol!]![1].toString(),
                                                                              ) <
                                                                              0
                                                                          ? Color(
                                                                              0xFFFD0000,
                                                                            )
                                                                          : Colors.green,
                                                                    ),
                                                                    AppText(
                                                                      '${double.parse(result[filteredCoins[index].coinSymbol!]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color:
                                                                          double.parse(
                                                                                result[filteredCoins[index].coinSymbol!]![1].toString(),
                                                                              ) <
                                                                              0
                                                                          ? Color(
                                                                              0xFFFD0000,
                                                                            )
                                                                          : Colors.green,
                                                                    ),
                                                                  ],
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    // Ensure the column takes minimum space
                                                    children: [
                                                      AppText(
                                                        isTextVisible
                                                            ? (double.tryParse(
                                                                            allBalance1[index],
                                                                          ) !=
                                                                          null &&
                                                                      double.tryParse(
                                                                            allBalance1[index],
                                                                          )! >
                                                                          0
                                                                  ? double.tryParse(
                                                                          allBalance1[index],
                                                                        )!
                                                                        .toStringAsFixed(
                                                                          6,
                                                                        )
                                                                        .replaceAll(
                                                                          RegExp(
                                                                            r"([.]*0+)(?!.*\d)",
                                                                          ),
                                                                          "",
                                                                        ) // Remove trailing zeros
                                                                  : "0")
                                                            : "****",
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceBright,
                                                      ),
                                                      result.containsKey(
                                                            filteredCoins[index]
                                                                .coinSymbol!,
                                                          )
                                                          ? AppText(
                                                              isTextVisible
                                                                  ? "\$${(double.parse(result[filteredCoins[index].coinSymbol!]![0].toString()) * double.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index] : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                                                  : '****',
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .surfaceBright,
                                                            )
                                                          : SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                : ListView.builder(
                                    itemCount: localStorageService
                                        .assetList
                                        .length, // Set the number of items to 5
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 5.0,
                                          left: 16,
                                          right: 16,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: GradientBoxBorder(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.3),
                                                  Colors.white.withOpacity(
                                                    0.05,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              width: 0.5,
                                            ), // Make it slightly transparent
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              // print(
                                              //     'snapshotData:::${snapshotData!.hasData && index < snapshotData!.data!.length ? snapshotData!.data![index] : "0.0"}');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return SendCryptoPage(
                                                      assetData:
                                                          localStorageService
                                                              .assetList[index],
                                                      balance:
                                                          (index <
                                                              localStorageService
                                                                  .assetBalance1
                                                                  .length
                                                          ? localStorageService
                                                                .assetBalance1[index]
                                                          : "0.0"),
                                                      walletData:
                                                          localStorageService
                                                              .activeWalletData!,
                                                      ethAddress: "",
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            leading: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Color(
                                                    0xFF202832,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                    child: Image.network(
                                                      localStorageService
                                                          .assetList[index]
                                                          .imageUrl!,
                                                      errorBuilder: (_, obj, trc) {
                                                        return AppText(
                                                          localStorageService
                                                              .assetList[index]
                                                              .coinSymbol
                                                              .toString()
                                                              .characters
                                                              .first,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                localStorageService
                                                            .assetList[index]
                                                            .coinType ==
                                                        "2"
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 5,
                                                            ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                          child: Image.network(
                                                            localStorageService
                                                                        .allAssetList
                                                                        .indexWhere(
                                                                          (v) =>
                                                                              v.gasPriceSymbol ==
                                                                              localStorageService.assetList[index].gasPriceSymbol,
                                                                        ) ==
                                                                    -1
                                                                ? ""
                                                                : localStorageService
                                                                      .allAssetList[localStorageService
                                                                          .allAssetList
                                                                          .indexWhere(
                                                                            (
                                                                              v,
                                                                            ) =>
                                                                                v.gasPriceSymbol ==
                                                                                localStorageService.assetList[index].gasPriceSymbol,
                                                                          )]
                                                                      .imageUrl!,
                                                            errorBuilder: (_, obj, trc) {
                                                              return AppText(
                                                                localStorageService
                                                                    .assetList[index]
                                                                    .gasPriceSymbol
                                                                    .toString(),
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 7,
                                                              );
                                                            },
                                                            height: 15,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
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
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surfaceBright,
                                                      overflow: TextOverflow
                                                          .ellipsis, // This ensures truncation if needed
                                                    ),
                                                    SizedBox(width: 10),

                                                    // Use Flexible instead of Expanded
                                                    Flexible(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          color: Color(
                                                            0xFF262737,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 4.0,
                                                                right: 4.0,
                                                              ),
                                                          child: AppText(
                                                            localStorageService
                                                                .assetList[index]
                                                                .network!,
                                                            fontSize: 10,
                                                            overflow: TextOverflow
                                                                .ellipsis, // Ensure truncation here too
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    result.containsKey(
                                                          localStorageService
                                                              .assetList[index]
                                                              .coinSymbol!,
                                                        )
                                                        ? AppText(
                                                            "\$${double.parse(result[localStorageService.assetList[index].coinSymbol!]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceBright,
                                                          )
                                                        : AppText(
                                                            localStorageService
                                                                        .assetList[index]
                                                                        .coinType ==
                                                                    '2'
                                                                ? "Token"
                                                                : "Crypto",
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceBright,
                                                          ),
                                                    SizedBox(
                                                      width: SizeConfig.width(
                                                        context,
                                                        4,
                                                      ),
                                                    ),
                                                    result.containsKey(
                                                          localStorageService
                                                              .assetList[index]
                                                              .coinSymbol!,
                                                        )
                                                        ? Row(
                                                            children: [
                                                              AppText(
                                                                double.parse(
                                                                          result[localStorageService.assetList[index].coinSymbol!]![1]
                                                                              .toString(),
                                                                        ) <
                                                                        0
                                                                    ? ''
                                                                    : '+',
                                                                fontSize: 12,
                                                                color:
                                                                    double.parse(
                                                                          result[localStorageService.assetList[index].coinSymbol!]![1]
                                                                              .toString(),
                                                                        ) <
                                                                        0
                                                                    ? Color(
                                                                        0xFFFD0000,
                                                                      )
                                                                    : Colors
                                                                          .green,
                                                              ),
                                                              AppText(
                                                                '${double.parse(result[localStorageService.assetList[index].coinSymbol!]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    double.parse(
                                                                          result[localStorageService.assetList[index].coinSymbol!]![1]
                                                                              .toString(),
                                                                        ) <
                                                                        0
                                                                    ? Color(
                                                                        0xFFFD0000,
                                                                      )
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
                                            trailing: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              // Ensure the column takes minimum space
                                              children: [
                                                AppText(
                                                  isTextVisible
                                                      ? (index <
                                                                localStorageService
                                                                    .assetBalance1
                                                                    .length
                                                            ? double.tryParse(
                                                                            localStorageService.assetBalance1[index],
                                                                          ) !=
                                                                          null &&
                                                                      double.tryParse(
                                                                            localStorageService.assetBalance1[index],
                                                                          )! >
                                                                          0
                                                                  ? double.tryParse(
                                                                          localStorageService
                                                                              .assetBalance1[index],
                                                                        )!
                                                                        .toStringAsFixed(
                                                                          6,
                                                                        )
                                                                        .replaceAll(
                                                                          RegExp(
                                                                            r"([.]*0+)(?!.*\d)",
                                                                          ),
                                                                          "",
                                                                        ) // Remove trailing zeros
                                                                  : "0"
                                                            : "0")
                                                      : "****",
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surfaceBright,
                                                ),
                                                result.containsKey(
                                                      localStorageService
                                                          .assetList[index]
                                                          .coinSymbol!,
                                                    )
                                                    ? AppText(
                                                        isTextVisible
                                                            ? "\$${(double.parse(result[localStorageService.assetList[index].coinSymbol!]![0].toString()) * double.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index] : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                                            : '****',
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceBright,
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                          },
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
