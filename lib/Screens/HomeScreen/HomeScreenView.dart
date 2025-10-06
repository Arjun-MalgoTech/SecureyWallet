import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalance.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Constant_Image.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Crypto_Utils/Wallet_Theme/App_Theme.dart';
import 'package:securywallet/QRView/QRView_Android.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/App_Drawer/App_Drawer_View.dart';
import 'package:securywallet/Screens/AssetManager_View/View/AssetManagerView.dart';
import 'package:securywallet/Screens/Crypto_Transactions/TransactionReceipt/TransactionReceipt.dart';
import 'package:securywallet/Screens/HomeScreen/AllAssetAddress_View/AllAssetAddressView.dart';
import 'package:securywallet/Screens/HomeScreen/Controllers/home_controller.dart';
import 'package:securywallet/Screens/NftFlow/nftScreen.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeScreen.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/SwapScreen/CominSoonScreen/ComingSoonScreen.dart';
import 'package:securywallet/Screens/Transaction_Action_Screen/View/Transaction_Action_view.dart';
import 'package:securywallet/Screens/userWalletsPage_View/View/UserWalletsPageView.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {
  final String dollar;
  final String privateKey;

  const HomeView({super.key, required this.dollar, required this.privateKey});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabviewController;
  String savedText = '';
  late Timer _timer;
  late Timer _timer2;

  ValueNotifier<String> usdTotal = ValueNotifier<String>('574.89');

  LocalStorageService localStorageService = LocalStorageService();

  var overAllBalance;
  WebSocketChannel channel = IOWebSocketChannel.connect(
    'wss://stream.binance.com:9443/ws',
  );

  bool isPasscodeSet = false;

  void _checkPasscodeSet() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');
    if (savedPasscode == null) {
      // Passcode is set
      setState(() {
        isPasscodeSet = true;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PasscodeScreen(
              name: "",
              data: localStorageService.activeWalletData!,
            );
          },
        ),
      );
      setState(() {
        isPasscodeSet = false;
      });
    }
  }

  WalletConnectionRequest walletSessionRequest = WalletConnectionRequest();

  getxAPI() async {
    var nvxTicker = await assetBalance.nvxAPIUSDTPrice("NVXO_USDT");
    if (!_streamController.isClosed) {
      _streamController.add(nvxTicker);
    }
    var usdTicker = await assetBalance.getTetherPriceAPI("USDT_USDT");
    if (!_streamController.isClosed) {
      _streamController.add(usdTicker);
    }
  }

  bool isConnected = true;
  late AnimationController _controller;
  bool _isRefreshing = false;
  bool balanceLoading = false;
  late TabController _tabController;
  bool _isTextFieldEnabled = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    getxAPI();
    _checkPasscodeSet();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      balanceLoading = true;
      Provider.of<LocalStorageService>(context, listen: false).getData();
      Future.delayed(Duration(milliseconds: 500), () async {
        await _refresh();
        balanceLoading = false;
      });
      Future.delayed(Duration(seconds: 10), () async {
        if (localStorageService.activeWalletData != null) {
          await _refresh();
        } else {
          // Handle the case where selectedWalletData is null
          print('Selected wallet data is null, cannot refresh balances.');
        }
      });
      Future.delayed(Duration(milliseconds: 900), () {
        walletSessionRequest.walletInitailize(
          walletData: localStorageService.activeWalletData,
        );
        walletSessionRequest.initialize();
        walletSessionContextInit();
      });
      _subscribeToPairs();
    });

    tabviewController = TabController(length: 2, vsync: this);
    channel.stream.listen((message) async {
      Map<String, dynamic> data = jsonDecode(message);

      if (!_streamController.isClosed) {
        _streamController.add(data);
        _updateUSDT();
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _updateSubscribe);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Set the duration of one full rotation
    );
  }

  walletSessionContextInit() {
    _timer2 = Timer.periodic(Duration(seconds: 1), (Timer t) {
      walletSessionRequest.initializeContext(context);
    });
  }

  void _updateUSDT() async {
    usdTotal.value = multiplyCalculation(
      result,
      localStorageService.assetBalance1,
    ).toStringAsFixed(CoinListConfig.usdtDecimal);
  }

  void _updateSubscribe(Timer timer) {
    if (usdtPair.length != localStorageService.assetList.length) {
      usdtPair = [];
      _subscribeToPairs();
    }
  }

  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  List<String> usdtPair = [];

  void _subscribeToPairs() {
    for (var coin in localStorageService.assetList) {
      usdtPair.add("${coin.coinSymbol!.toLowerCase()}usdt@ticker");
    }
    channel.sink.add(
      jsonEncode({"method": "SUBSCRIBE", "params": usdtPair, "id": 1}),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    channel.sink.close();
    _controller.dispose();
    _streamController.close();
    searchController.dispose();
    _timer.cancel();
    _timer2.cancel();
    super.dispose();
  }

  num multiplyCalculation(Map mapValues, List listValues) {
    num sum = 0;
    for (int i = 0; i < listValues.length; i++) {
      sum +=
          double.parse(listValues[i]) *
          double.parse(
            i >= localStorageService.assetList.length
                ? "0"
                : mapValues.containsKey(
                    "${localStorageService.assetList[i].coinSymbol}USDT",
                  )
                ? "${mapValues["${localStorageService.assetList[i].coinSymbol}USDT"][0]}"
                : "0",
          );
    }
    return sum;
  }

  bool isTextVisible = true;

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
      if (i >= 0) {
        filtered.add(overallBalances[i].balance);
      } else {
        filtered.add("0");
      }
    }
    setState(() {
      overAllBalance = filtered;
    });
  }

  Future<void> _refresh() async {
    try {
      setState(() {
        _isRefreshing = true;
      });
      _controller.repeat();
      getxAPI();
      await localStorageService.fetchCoinBalance();
      _isTextFieldEnabled = true;
      fetchOverallBalances(localStorageService.assetBalance1);
      _controller.stop();

      setState(() {
        _isRefreshing = false;
      });
    } catch (e) {
      _controller.stop();

      setState(() {
        _isRefreshing = false;
      });
    }
  }

  ThemeController themeController = ThemeController();

  TextEditingController searchController = TextEditingController();
  List<AssetModel> filteredCoins = [];

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    themeController = context.watch<ThemeController>();
    walletSessionRequest = context.watch<WalletConnectionRequest>();
    walletSessionRequest.initializeContext(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(
      //   leading: Padding(
      //     padding: const EdgeInsets.only(left: 16.0),
      //     child: Image.asset("assets/Images/scan4.png"),
      //   ),
      //   centerTitle: true,
      //   title: InkWell(
      //     onTap: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) {
      //             return const UserWalletPage();
      //           },
      //         ),
      //       );
      //       FocusScope.of(context).unfocus();
      //     },
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         AppText(
      //           localStorageService.activeWalletData!.walletName
      //                       .toString()
      //                       .length >
      //                   16
      //               ? '${localStorageService.activeWalletData!.walletName.toString().substring(0, 16)}...'
      //               : localStorageService.activeWalletData!.walletName
      //                     .toString(),
      //           fontFamily: 'Poppins',
      //           fontWeight: FontWeight.w600,
      //           fontSize: 17,
      //         ),
      //         Icon(
      //           Icons.arrow_drop_down_outlined,
      //           color: Theme.of(context).colorScheme.surfaceBright,
      //           size: 26,
      //         ),
      //       ],
      //     ),
      //   ),
      //   actions: [
      //     // Row(
      //     //   children: [
      //     //     GestureDetector(
      //     //       onTap: () {
      //     //         Future.delayed(Duration(milliseconds: 500), () {
      //     //           Navigator.push(
      //     //             context,
      //     //             MaterialPageRoute(builder: (context) => QRView()),
      //     //           );
      //     //         });
      //     //         FocusScope.of(
      //     //           context,
      //     //         ).unfocus(); // Unfocus to dismiss the keyboard
      //     //       },
      //     //       child: Container(
      //     //         color: Colors.transparent,
      //     //         child: Padding(
      //     //           padding: const EdgeInsets.all(8.0),
      //     //           child: SvgPicture.asset(
      //     //             ConstantImage.imgPrinter,
      //     //             width: 20,
      //     //             height: 20,
      //     //             semanticsLabel: 'Acme Logo',
      //     //             color: Color(0XFFB982FF),
      //     //           ),
      //     //         ),
      //     //       ),
      //     //     ),
      //     //     InkWell(
      //     //       child: IconButton(
      //     //         onPressed: () {
      //     //           Navigator.push(
      //     //             context,
      //     //             MaterialPageRoute(builder: (context) => AssetManager()),
      //     //           ).then((v) {});
      //     //         },
      //     //         icon: Container(
      //     //           color: Colors.transparent,
      //     //           child: Image.asset(
      //     //             "assets/Images/asset.png",
      //     //             width: 25,
      //     //             height: 25,
      //     //           ),
      //     //         ),
      //     //         color: Theme.of(context).colorScheme.surfaceBright,
      //     //       ),
      //     //     ),
      //     //   ],
      //     // ),
      //     Image.asset("assets/Images/search1.png"),
      //     SizedBox(width: 20),
      //   ],
      // ),
      key: _scaffoldKey,
      drawer: AppDrawer(walletConnectionRequest: walletSessionRequest),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh, // Trigger the refresh action
          child: localStorageService.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent[100],
                  ),
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset("assets/Images/scan4.png"),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const UserWalletPage();
                                },
                              ),
                            );
                            FocusScope.of(context).unfocus();
                          },
                          child: Row(
                            children: [
                              AppText(
                                localStorageService.activeWalletData!.walletName
                                            .toString()
                                            .length >
                                        16
                                    ? '${localStorageService.activeWalletData!.walletName.toString().substring(0, 16)}...'
                                    : localStorageService
                                          .activeWalletData!
                                          .walletName
                                          .toString(),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                              Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceBright,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AssetManager(),
                                ),
                              ).then((v) {});
                            },
                            icon: Container(
                              color: Colors.transparent,
                              child: Image.asset(
                                "assets/Images/asset.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                            color: Theme.of(context).colorScheme.surfaceBright,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Image Centered
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/Images/1.png",
                                  fit: BoxFit.contain,
                                  width: screenWidth,
                                ),
                              ),

                              // Foreground Content
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: screenHeight * 0.02),

                                  // Balance Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: usdTotal,
                                        builder: (context, value, child) {
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "\$574.89",
                                              style: TextStyle(
                                                fontFamily: 'LexendDeca',
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surfaceBright,
                                                fontSize:
                                                    screenWidth *
                                                    0.09, // responsive font
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      // Example of toggle icon (optional)
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     setState(() {
                                      //       isTextVisible = !isTextVisible;
                                      //     });
                                      //   },
                                      //   child: Icon(
                                      //     isTextVisible ? Icons.visibility : Icons.visibility_off,
                                      //     color: Theme.of(context).colorScheme.surfaceBright,
                                      //     size: screenWidth * 0.06,
                                      //   ),
                                      // ),
                                    ],
                                  ),

                                  // Percentage text
                                  Text(
                                    "\$11.32 (+1.46%)",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          screenWidth *
                                          0.032, // responsive font
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.055),

                                  // Bottom icon row (buttons)
                                  iconRow(context),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: SizeConfig.height(context, 2)),
                    // bannerImage(context),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Row(
                        children: [
                          AppText(
                            "Trending",
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.height(context, 1)),

                    SizedBox(
                      height:
                          70, // Adjust height based on your container content
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: localStorageService
                            .assetList
                            .length, // Number of items
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Container(
                              decoration: BoxDecoration(
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
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0XFF0f131a),
                              ),
                              width: MediaQuery.of(context).size.width * 0.7,

                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 5,
                                        bottom: 15,
                                      ),
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Color(0xFF202832),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
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
                                                fontWeight: FontWeight.bold,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    localStorageService
                                                .assetList[index]
                                                .coinType ==
                                            "2"
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                localStorageService.allAssetList.indexWhere(
                                                          (v) =>
                                                              v.gasPriceSymbol ==
                                                              localStorageService
                                                                  .assetList[index]
                                                                  .gasPriceSymbol,
                                                        ) ==
                                                        -1
                                                    ? ""
                                                    : localStorageService
                                                          .allAssetList[localStorageService
                                                              .allAssetList
                                                              .indexWhere(
                                                                (v) =>
                                                                    v.gasPriceSymbol ==
                                                                    localStorageService
                                                                        .assetList[index]
                                                                        .gasPriceSymbol,
                                                              )]
                                                          .imageUrl!,
                                                errorBuilder: (_, obj, trc) {
                                                  return AppText(
                                                    localStorageService
                                                        .assetList[index]
                                                        .gasPriceSymbol
                                                        .toString(),
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
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
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppText(
                                              localStorageService
                                                  .assetList[index]
                                                  .coinName!,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surfaceBright,
                                              overflow: TextOverflow
                                                  .ellipsis, // This ensures truncation if needed
                                            ),
                                          ),
                                          SizedBox(width: 10),

                                          // Use Flexible instead of Expanded
                                          // Flexible(
                                          //   child: Container(
                                          //     decoration: BoxDecoration(
                                          //       borderRadius: BorderRadius.circular(
                                          //         10,
                                          //       ),
                                          //       color: Colors.black38,
                                          //     ),
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.only(
                                          //         left: 4.0,
                                          //         right: 4.0,
                                          //       ),
                                          //       child: AppText(
                                          //         localStorageService
                                          //             .assetList[index]
                                          //             .network!,
                                          //         fontSize: 10,
                                          //         overflow: TextOverflow.ellipsis,
                                          //         // Ensure truncation here too
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          result.containsKey(
                                                "${localStorageService.assetList[index].coinSymbol!}USDT",
                                              )
                                              ? Expanded(
                                                  child: AppText(
                                                    "${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                  ),
                                                )
                                              : AppText(
                                                  localStorageService
                                                              .assetList[index]
                                                              .coinType ==
                                                          '2'
                                                      ? "Token"
                                                      : "\$1224.45",
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surfaceBright,
                                                ),
                                          SizedBox(
                                            width: SizeConfig.width(context, 4),
                                          ),
                                          //old code
                                          // result.containsKey(
                                          //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                                          //     )
                                          //     ? Row(
                                          //         children: [
                                          //           AppText(
                                          //             double.parse(
                                          //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                          //                           .toString(),
                                          //                     ) <
                                          //                     0
                                          //                 ? ''
                                          //                 : '+',
                                          //             fontSize: 12,
                                          //             color:
                                          //                 double.parse(
                                          //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                          //                           .toString(),
                                          //                     ) <
                                          //                     0
                                          //                 ? Color(0xFFFD0000)
                                          //                 : Colors.green,
                                          //           ),
                                          //           AppText(
                                          //             '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                          //             fontSize: 13,
                                          //             fontWeight: FontWeight.w400,
                                          //             color:
                                          //                 double.parse(
                                          //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                          //                           .toString(),
                                          //                     ) <
                                          //                     0
                                          //                 ? Color(0xFFFD0000)
                                          //                 : Colors.green,
                                          //           ),
                                          //         ],
                                          //       )
                                          //     : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,

                                  // Ensure the column takes minimum space
                                  children: [
                                    result.containsKey(
                                          "${localStorageService.assetList[index].coinSymbol!}USDT",
                                        )
                                        ? AppText(
                                            "\$${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceBright,
                                          )
                                        : AppText(
                                            localStorageService
                                                        .assetList[index]
                                                        .coinType ==
                                                    '2'
                                                ? "Token"
                                                : "\$1227.87",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceBright,
                                          ),
                                    //old code
                                    // AppText(
                                    //   isTextVisible
                                    //       ? (index <
                                    //                 localStorageService
                                    //                     .assetBalance1
                                    //                     .length
                                    //             ? double.tryParse(
                                    //                             localStorageService
                                    //                                 .assetBalance1[index],
                                    //                           ) !=
                                    //                           null &&
                                    //                       double.tryParse(
                                    //                             localStorageService
                                    //                                 .assetBalance1[index],
                                    //                           )! >
                                    //                           0
                                    //                   ? double.tryParse(
                                    //                           localStorageService
                                    //                               .assetBalance1[index],
                                    //                         )!
                                    //                         .toStringAsFixed(6)
                                    //                         .replaceAll(
                                    //                           RegExp(
                                    //                             r"([.]*0+)(?!.*\d)",
                                    //                           ),
                                    //                           "",
                                    //                         ) // Remove trailing zeros
                                    //                   : "0"
                                    //             : "0")
                                    //       : "****",
                                    //   fontSize: 15,
                                    //   fontWeight: FontWeight.w400,
                                    //   color: Theme.of(
                                    //     context,
                                    //   ).colorScheme.surfaceBright,
                                    // ),
                                    result.containsKey(
                                          "${localStorageService.assetList[index].coinSymbol!}USDT",
                                        )
                                        ? AppText(
                                            '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                double.parse(
                                                      result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                                          .toString(),
                                                    ) <
                                                    0
                                                ? Color(0xFFFD0000)
                                                : Colors.green,
                                          )
                                        : AppText(
                                            "0.54%",
                                            color: Colors.green,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    //old code
                                    // result.containsKey(
                                    //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                                    //     )
                                    //     ? AppText(
                                    //         isTextVisible
                                    //             ? "\$${(num.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()) * num.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index].toString() : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                    //             : '****',
                                    //         fontSize: 12,
                                    //         fontWeight: FontWeight.w400,
                                    //         color: Theme.of(
                                    //           context,
                                    //         ).colorScheme.surfaceBright,
                                    //       )
                                    //     : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: SizeConfig.height(context, 2)),

                    // Row of custom tabs
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                border: _selectedIndex == 0
                                    ? null
                                    : Border.all(color: Color(0XFF444444)),
                              ),
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  "Crypto",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == 0
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _selectedIndex == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                border: _selectedIndex == 1
                                    ? null
                                    : Border.all(color: Color(0XFF444444)),
                              ),
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  "NFTs",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == 1
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.height(context, 1)),

                    // Show content based on selected index
                    Expanded(
                      child: _selectedIndex == 0 ? AssetTab() : NFTsTab(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Map<String, List<String>> result = {};

  Widget AssetTab() {
    return Column(
      children: [
        Flexible(
          child: balanceLoading
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        color: Colors.purpleAccent[100],
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
                          "${value.coinSymbol!}USDT".toLowerCase(),
                        )) {
                          if (result.containsKey("${value.coinSymbol!}USDT")) {
                            result["${value.coinSymbol!}USDT"] = [
                              data['c'],
                              data['P'],
                            ];
                          } else {
                            result.addAll({
                              "${value.coinSymbol!}USDT": [
                                data['c'],
                                data['P'],
                              ],
                            });
                          }
                        }
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      child: ListView.builder(
                        itemCount: localStorageService
                            .assetList
                            .length, // Set the number of items to 5
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              extentRatio: 0.2,
                              children: [
                                index > 0
                                    ? Builder(
                                        builder: (context) {
                                          return InkWell(
                                            onTap: () async {
                                              setState(() {
                                                localStorageService
                                                    .assetBalance1
                                                    .removeAt(index);
                                              });
                                              await localStorageService
                                                  .removeMapValue(
                                                    localStorageService
                                                        .assetList[index],
                                                    context,
                                                  );
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
                                              Slidable.of(context)?.close();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 6.0,
                                              ),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
                                                  color: Colors.red,
                                                ),
                                                width: SizeConfig.width(
                                                  context,
                                                  16,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                      AppText(
                                                        "Delete",
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          if (!await launchUrl(
                                            Uri.parse(
                                              localStorageService
                                                  .assetList[index]
                                                  .explorerURL!,
                                            ),
                                          )) {
                                            throw Exception(
                                              'Could not launch ',
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6.0,
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight: Radius.circular(
                                                  10,
                                                ),
                                              ),
                                              color: Colors.blue,
                                            ),
                                            width: SizeConfig.width(
                                              context,
                                              16,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                4.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.info,
                                                    color: Colors.white,
                                                  ),
                                                  AppText(
                                                    "  Info  ",
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return TransactionAction(
                                          coinData: localStorageService
                                              .assetList[index],
                                          balance:
                                              (index <
                                                  localStorageService
                                                      .assetBalance1
                                                      .length
                                              ? localStorageService
                                                    .assetBalance1[index]
                                              : "0.0"),
                                          userWallet: localStorageService
                                              .activeWalletData!,
                                          usdPrice: double.parse(
                                            result.containsKey(
                                                  "${localStorageService.assetList[index].coinSymbol!}USDT",
                                                )
                                                ? result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0]
                                                      .toString()
                                                : "0",
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                leading: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Color(0xFF202832),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
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
                                                fontWeight: FontWeight.bold,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    localStorageService
                                                .assetList[index]
                                                .coinType ==
                                            "2"
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                localStorageService.allAssetList.indexWhere(
                                                          (v) =>
                                                              v.gasPriceSymbol ==
                                                              localStorageService
                                                                  .assetList[index]
                                                                  .gasPriceSymbol,
                                                        ) ==
                                                        -1
                                                    ? ""
                                                    : localStorageService
                                                          .allAssetList[localStorageService
                                                              .allAssetList
                                                              .indexWhere(
                                                                (v) =>
                                                                    v.gasPriceSymbol ==
                                                                    localStorageService
                                                                        .assetList[index]
                                                                        .gasPriceSymbol,
                                                              )]
                                                          .imageUrl!,
                                                errorBuilder: (_, obj, trc) {
                                                  return AppText(
                                                    localStorageService
                                                        .assetList[index]
                                                        .gasPriceSymbol
                                                        .toString(),
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AppText(
                                          localStorageService
                                              .assetList[index]
                                              .coinName!,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceBright,
                                          overflow: TextOverflow
                                              .ellipsis, // This ensures truncation if needed
                                        ),
                                        SizedBox(width: 10),

                                        // Use Flexible instead of Expanded
                                        // Flexible(
                                        //   child: Container(
                                        //     decoration: BoxDecoration(
                                        //       borderRadius: BorderRadius.circular(
                                        //         10,
                                        //       ),
                                        //       color: Colors.black38,
                                        //     ),
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(
                                        //         left: 4.0,
                                        //         right: 4.0,
                                        //       ),
                                        //       child: AppText(
                                        //         localStorageService
                                        //             .assetList[index]
                                        //             .network!,
                                        //         fontSize: 10,
                                        //         overflow: TextOverflow.ellipsis,
                                        //         // Ensure truncation here too
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        result.containsKey(
                                              "${localStorageService.assetList[index].coinSymbol!}USDT",
                                            )
                                            ? AppText(
                                                "${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)} ${localStorageService.assetList[index].coinSymbol!}",
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white.withOpacity(
                                                  0.6,
                                                ),
                                              )
                                            : AppText(
                                                localStorageService
                                                            .assetList[index]
                                                            .coinType ==
                                                        '2'
                                                    ? "Token"
                                                    : "\$1224.65",
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surfaceBright,
                                              ),
                                        SizedBox(
                                          width: SizeConfig.width(context, 4),
                                        ),
                                        //old code
                                        // result.containsKey(
                                        //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                                        //     )
                                        //     ? Row(
                                        //         children: [
                                        //           AppText(
                                        //             double.parse(
                                        //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                        //                           .toString(),
                                        //                     ) <
                                        //                     0
                                        //                 ? ''
                                        //                 : '+',
                                        //             fontSize: 12,
                                        //             color:
                                        //                 double.parse(
                                        //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                        //                           .toString(),
                                        //                     ) <
                                        //                     0
                                        //                 ? Color(0xFFFD0000)
                                        //                 : Colors.green,
                                        //           ),
                                        //           AppText(
                                        //             '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                        //             fontSize: 13,
                                        //             fontWeight: FontWeight.w400,
                                        //             color:
                                        //                 double.parse(
                                        //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                        //                           .toString(),
                                        //                     ) <
                                        //                     0
                                        //                 ? Color(0xFFFD0000)
                                        //                 : Colors.green,
                                        //           ),
                                        //         ],
                                        //       )
                                        //     : SizedBox(),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  // Ensure the column takes minimum space
                                  children: [
                                    result.containsKey(
                                          "${localStorageService.assetList[index].coinSymbol!}USDT",
                                        )
                                        ? AppText(
                                            "\$${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceBright,
                                          )
                                        : AppText(
                                            localStorageService
                                                        .assetList[index]
                                                        .coinType ==
                                                    '2'
                                                ? "Token"
                                                : "\$1224.65",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surfaceBright,
                                          ),
                                    //old code
                                    // AppText(
                                    //   isTextVisible
                                    //       ? (index <
                                    //                 localStorageService
                                    //                     .assetBalance1
                                    //                     .length
                                    //             ? double.tryParse(
                                    //                             localStorageService
                                    //                                 .assetBalance1[index],
                                    //                           ) !=
                                    //                           null &&
                                    //                       double.tryParse(
                                    //                             localStorageService
                                    //                                 .assetBalance1[index],
                                    //                           )! >
                                    //                           0
                                    //                   ? double.tryParse(
                                    //                           localStorageService
                                    //                               .assetBalance1[index],
                                    //                         )!
                                    //                         .toStringAsFixed(6)
                                    //                         .replaceAll(
                                    //                           RegExp(
                                    //                             r"([.]*0+)(?!.*\d)",
                                    //                           ),
                                    //                           "",
                                    //                         ) // Remove trailing zeros
                                    //                   : "0"
                                    //             : "0")
                                    //       : "****",
                                    //   fontSize: 15,
                                    //   fontWeight: FontWeight.w400,
                                    //   color: Theme.of(
                                    //     context,
                                    //   ).colorScheme.surfaceBright,
                                    // ),
                                    result.containsKey(
                                          "${localStorageService.assetList[index].coinSymbol!}USDT",
                                        )
                                        ? AppText(
                                            '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                double.parse(
                                                      result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                                                          .toString(),
                                                    ) <
                                                    0
                                                ? Color(0xFFFD0000)
                                                : Colors.green,
                                          )
                                        : AppText(
                                            "0.54%",
                                            color: Colors.green,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    //old code
                                    // result.containsKey(
                                    //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                                    //     )
                                    //     ? AppText(
                                    //         isTextVisible
                                    //             ? "\$${(num.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()) * num.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index].toString() : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                    //             : '****',
                                    //         fontSize: 12,
                                    //         fontWeight: FontWeight.w400,
                                    //         color: Theme.of(
                                    //           context,
                                    //         ).colorScheme.surfaceBright,
                                    //       )
                                    //     : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                    // }
                    // return Container();
                  },
                ),
        ),
      ],
    );
  }

  Widget NFTsTab() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Nfts();
            },
          ),
        );
      },

      child: Expanded(child: Nfts()),
    );
  }
}
