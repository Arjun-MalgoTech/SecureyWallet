import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
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
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  ValueNotifier<String> usdTotal = ValueNotifier<String>('0.00');

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
///////Trending Token Flow///////////////
  late Future<List<Map<String, dynamic>>> trendingTokens;
  final String apiKey = '9b4cc00e-85f2-412f-8669-5b6b4ef12f0e';




  // Convert trending token Map to AssetModel
  AssetModel trendingToAssetModel(Map<String, dynamic> token) {
    final rpcURLs = {
      "Ethereum": "https://mainnet.infura.io/v3/${apiKeyService.infuraKey}",
      "BNB Smart Chain": "https://bsc-dataseed.binance.org",
      "Polygon": "https://polygon-rpc.com",
      "Avalanche": "https://api.avax.network/ext/bc/C/rpc",
      "Tron": "https://api.trongrid.io",
      "Solana": "https://api.mainnet-beta.solana.com",
      "Terra Classic": "https://terra-classic-lcd.publicnode.com",
    };

    return AssetModel(
      coinName: token['name'] ?? '',
      coinSymbol: token['symbol'] ?? '',
      imageUrl: token['logo'] ?? '',
      tokenAddress: token['tokenAddress'] ?? '',
      network: token['network'] ?? 'Binance',
      coinType: "2",
      gasPriceSymbol : "BNB",
      address: "",
      tokenDecimal: "18",
      // default balance
      rpcURL: rpcURLs[token['network']] ?? 'https://bsc-dataseed.binance.org',
    );
  }

  Future<List<Map<String, dynamic>>> fetchTrendingTokens() async {
    // 1️⃣ Fetch listings
    final listingsUrl =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=50';
    final listingsResp = await http.get(
      Uri.parse(listingsUrl),
      headers: {'X-CMC_PRO_API_KEY': apiKey},
    );

    if (listingsResp.statusCode != 200) {
      throw Exception('Failed to fetch trending tokens');
    }

    final listingsData = jsonDecode(listingsResp.body)['data'] as List;

    // Filter out SOL, TRX, LTC
    final filteredData = listingsData.where((token) {
      final symbol = token['symbol'] ?? '';
      return symbol != 'SOL' && symbol != 'TRX' && symbol != 'LTC';
    }).toList();

    // Sort by 24h % change
    filteredData.sort((a, b) {
      final changeA = a['quote']['USD']['percent_change_24h'] ?? 0.0;
      final changeB = b['quote']['USD']['percent_change_24h'] ?? 0.0;
      return changeB.compareTo(changeA);
    });

    final topTokens = filteredData.take(10).toList();

    // 2️⃣ Fetch token info (to get platform/contract address)
    final ids = topTokens.map((e) => e['id']).join(',');
    final infoUrl =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?id=$ids';
    final infoResp = await http.get(
      Uri.parse(infoUrl),
      headers: {'X-CMC_PRO_API_KEY': apiKey},
    );

    if (infoResp.statusCode != 200) {
      throw Exception('Failed to fetch token info');
    }

    final infoData = jsonDecode(infoResp.body)['data'] as Map<String, dynamic>;

    // Merge listings + info
    List<Map<String, dynamic>> tokens = [];
    for (var token in topTokens) {
      final info = infoData[token['id'].toString()];
      final platform = info['platform'];

      tokens.add({
        "id": token['id'],
        "name": token['name'],
        "symbol": token['symbol'],
        "price": token['quote']['USD']['price'],
        "volume_24h": token['quote']['USD']['volume_24h'],
        "percent_change_24h": token['quote']['USD']['percent_change_24h'],
        "network": platform?['name'] ?? "Native",
        "tokenAddress": platform?['token_address'] ?? "",
        "logo":
        "https://s2.coinmarketcap.com/static/img/coins/64x64/${token['id']}.png",
      });
    }

    return tokens;
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(2);
  }

  ///////Trending Token Flow///////////////

  @override
  void initState() {
    super.initState();
    trendingTokens = fetchTrendingTokens();
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


    //************** Nfts flow *********************//

    web3client = Web3Client(rpcUrl, Client());
    //************** Nfts flow *********************//

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
  String? ownerAddress;
 // wallet
  final String alchemyApiKey =
      'gSBUx520RvEVfp8EK9XqfP2mvdlqYRaz'; // Alchemy API
  final String rpcUrl =
      'https://mainnet.infura.io/v3/${apiKeyService
      .infuraKey}'; // for sending tx
  List<NFT> nfts = [];
  bool loading1 = true;

  late Web3Client web3client;


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
    ownerAddress = localStorageService.activeWalletData?.walletAddress;


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
              : SingleChildScrollView(
                  child: Column(
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
                                  localStorageService
                                              .activeWalletData!
                                              .walletName
                                              .toString()
                                              .length >
                                          16
                                      ? '${localStorageService.activeWalletData!.walletName.toString().substring(0, 16)}...'
                                      : localStorageService
                                            .activeWalletData!
                                            .walletName
                                            .toString(),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceBright,
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
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final screenHeight = MediaQuery.of(
                              context,
                            ).size.height;


                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background Image Centered
                                Align(
                                  alignment: Alignment.center,
                                  child: FractionallySizedBox(
                                    widthFactor: screenWidth > 600 ? 0.9 : 1, // ✅ 50% on tablet, full on phone
                                    child: Image.asset(
                                      "assets/Images/1.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),


                                // Foreground Content
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: screenHeight * 0.02),

                                    // Balance Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ValueListenableBuilder(
                                          valueListenable: usdTotal,
                                          builder: (context, value, child) {
                                            return FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: AppText(
                                                "\$${value}",
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surfaceBright,
                                                  fontSize:
                                                      screenWidth *
                                                      0.09, // responsive font

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
                            SizeConfig.height(context, 7), // Adjust height based on your container content
                        child:    FutureBuilder<List<Map<String, dynamic>>>(
                          future: trendingTokens,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return  Center(child: CircularProgressIndicator(
                                color: Colors.purpleAccent[100],
                              ));
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No trending tokens found.'));
                            }

                            final tokens = snapshot.data!;

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: tokens.length,
                              itemBuilder: (context, index) {
                                final token = tokens[index];




                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0,),
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

                                  child:ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    minVerticalPadding: 0,
                                    leading:
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(token['logo']),
                                          child: AppText(
                                            token['symbol'][0],
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        Image.asset("assets/Images/bnb.png")
                                      ],
                                    ),

                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AppText('${token['name']} ',
                                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                                        AppText(
                                          '\$${_formatVolume(token['volume_24h'])}',
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),

                                    trailing: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          AppText(
                                            '\$${token['price'].toStringAsFixed(2)}',
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          AppText(
                                            '${token['percent_change_24h'].toStringAsFixed(2)}%',
                                            color: token['percent_change_24h'] > 0 ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ],
                                      ),
                                    ),

                                    onTap: () async {
                                      // Convert Map -> AssetModel
                                      final asset = trendingToAssetModel(token);

                                      // Navigate to TransactionAction with AssetModel
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransactionAction(
                                            coinData: asset,
                                            balance: "0.0",
                                            userWallet: localStorageService.activeWalletData!,
                                            usdPrice: 0.0,
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                                );
                              },
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
                                fetchNFTs();
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
                      SizedBox(
                        height: SizeConfig.height(
                          context,
                          localStorageService.assetList.length * 9,
                        ),
                        child: _selectedIndex == 0 ? AssetTab() : NFTsTab(),
                      ),
                    ],
                  ),
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
                      child:

                      ListView.builder(
                        itemCount: localStorageService.assetList
                            .length, // Set the number of items to 5
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                              key: ValueKey(index),
                              endActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  extentRatio: 0.2,
                                  children: [
                                    Builder(builder: (context) {
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
                                                  .assetList[
                                              index],
                                              context);
                                          WidgetsBinding.instance
                                              .addPostFrameCallback(
                                                  (_) {
                                                Provider.of<LocalStorageService>(
                                                    context,
                                                    listen: false)
                                                    .getData();
                                              });
                                          Slidable.of(context)
                                              ?.close();
                                        },
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 6.0),
                                          child: Container(
                                            decoration:
                                            const BoxDecoration(
                                              borderRadius:
                                              BorderRadius.only(
                                                  topRight: Radius
                                                      .circular(
                                                      10),
                                                  bottomRight:
                                                  Radius.circular(
                                                      10)),
                                              color: Colors.red,
                                            ),
                                            width: SizeConfig.width(
                                                context, 16),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(4.0),
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
                                                    color: Colors
                                                        .white,
                                                  ),
                                                  AppText(
                                                    "Delete",
                                                    color: Colors
                                                        .white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                    //     : InkWell(
                                    //   onTap: () async {
                                    //     if (!await launchUrl(Uri
                                    //         .parse(localStorageService
                                    //         .assetList[index]
                                    //         .explorerURL!))) {
                                    //       throw Exception(
                                    //           'Could not launch ');
                                    //     }
                                    //   },
                                    //   child: Padding(
                                    //     padding:
                                    //     const EdgeInsets.only(
                                    //         bottom: 6.0),
                                    //     child: Container(
                                    //       decoration:
                                    //       const BoxDecoration(
                                    //         borderRadius:
                                    //         BorderRadius.only(
                                    //             topRight: Radius
                                    //                 .circular(
                                    //                 10),
                                    //             bottomRight: Radius
                                    //                 .circular(
                                    //                 10)),
                                    //         color: Colors.blue,
                                    //       ),
                                    //       width: SizeConfig.width(
                                    //           context, 16),
                                    //       child: Padding(
                                    //         padding:
                                    //         const EdgeInsets
                                    //             .all(4.0),
                                    //         child: Column(
                                    //           crossAxisAlignment:
                                    //           CrossAxisAlignment
                                    //               .center,
                                    //           mainAxisAlignment:
                                    //           MainAxisAlignment
                                    //               .center,
                                    //           children: [
                                    //             Icon(
                                    //               Icons.info,
                                    //               color:
                                    //               Colors.white,
                                    //             ),
                                    //             AppText(
                                    //               "  Info  ",
                                    //               color:
                                    //               Colors.white,
                                    //               fontSize: 12,
                                    //               fontWeight:
                                    //               FontWeight
                                    //                   .bold,
                                    //             )
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // )
                                  ]),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10),
                               // Make it slightly transparent
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) {
                                              return TransactionAction(
                                                  coinData:
                                                  localStorageService
                                                      .assetList[
                                                  index],
                                                  balance: (index <
                                                      localStorageService
                                                          .assetBalance1
                                                          .length
                                                      ? localStorageService
                                                      .assetBalance1[
                                                  index]
                                                      : "0.0"),
                                                  userWallet:
                                                  localStorageService
                                                      .activeWalletData!,
                                                  usdPrice: double.parse(
                                                      result.containsKey(
                                                          "${localStorageService.assetList[index].coinSymbol!}USDT")
                                                          ? result["${localStorageService.assetList[index].coinSymbol!}USDT"]![
                                                      0]
                                                          .toString()
                                                          : "0"));
                                            }));
                                  },
                                  leading: Stack(
                                    alignment:
                                    Alignment.bottomRight,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            right: 5),
                                        child: CircleAvatar(
                                          radius: 18,
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
                                          child:
                                          Image.network(
                                            localStorageService.allAssetList.indexWhere((v) =>
                                            v.gasPriceSymbol ==
                                                localStorageService
                                                    .assetList[
                                                index]
                                                    .gasPriceSymbol) ==
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
                                          Expanded(
                                            child: AppText(
                                              localStorageService
                                                  .assetList[index]
                                                  .coinName!,
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w400,
                                              color: Theme.of(
                                                  context)
                                                  .colorScheme
                                                  .surfaceBright,
                                              overflow: TextOverflow
                                                  .ellipsis, // This ensures truncation if needed
                                            ),
                                          ),
                                          SizedBox(width: 10),

                                          // Use Flexible instead of Expanded
                                          // Flexible(
                                          //   child: Container(
                                          //     decoration:
                                          //     BoxDecoration(
                                          //       borderRadius:
                                          //       BorderRadius
                                          //           .circular(
                                          //           10),
                                          //       color: Colors
                                          //           .black38,
                                          //     ),
                                          //     child: Padding(
                                          //       padding:
                                          //       const EdgeInsets
                                          //           .only(
                                          //           left: 4.0,
                                          //           right:
                                          //           4.0),
                                          //       child: AppText(
                                          //         localStorageService
                                          //             .assetList[
                                          //         index]
                                          //             .network!,
                                          //         fontSize: 10,
                                          //         overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
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
                                              "${localStorageService.assetList[index].coinSymbol!}USDT")
                                              ? AppText(
                                            "\$${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight
                                                .w400,
                                            color: Theme.of(
                                                context)
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
                                            FontWeight
                                                .w400,
                                            color: Theme.of(
                                                context)
                                                .colorScheme
                                                .surfaceBright,
                                          ),
                                          SizedBox(
                                            width:
                                            SizeConfig.width(
                                                context, 4),
                                          ),
                                          result.containsKey(
                                              "${localStorageService.assetList[index].coinSymbol!}USDT")
                                              ? Row(
                                            children: [
                                              AppText(
                                                double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()) <
                                                    0
                                                    ? ''
                                                    : '+',
                                                fontSize:
                                                12,
                                                color: double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()) <
                                                    0
                                                    ? Color(
                                                    0xFFFD0000)
                                                    : Colors
                                                    .green,
                                              ),
                                              AppText(
                                                '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                                fontSize:
                                                13,
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                                color: double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()) <
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
                                  trailing: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    // Ensure the column takes minimum space
                                    children: [
                                      AppText(
                                        isTextVisible
                                            ? (index <
                                            localStorageService
                                                .assetBalance1
                                                .length
                                            ? double.tryParse(localStorageService.assetBalance1[
                                        index]) !=
                                            null &&
                                            double.tryParse(localStorageService.assetBalance1[
                                            index])! >
                                                0
                                            ? double.tryParse(
                                            localStorageService.assetBalance1[
                                            index])!
                                            .toStringAsFixed(
                                            6)
                                            .replaceAll(
                                            RegExp(
                                                r"([.]*0+)(?!.*\d)"),
                                            "") // Remove trailing zeros
                                            : "0"
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
                                          "${localStorageService.assetList[index].coinSymbol!}USDT")
                                          ? AppText(
                                        isTextVisible
                                            ? "\$${(num.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()) * num.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index].toString() : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                            : '****',
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: Theme.of(
                                            context)
                                            .colorScheme
                                            .surfaceBright,
                                      )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),

                      // ListView.builder(
                      //   itemCount: localStorageService
                      //       .assetList
                      //       .length, // Set the number of items to 5
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return Slidable(
                      //       key: ValueKey(index),
                      //       endActionPane: ActionPane(
                      //         motion: ScrollMotion(),
                      //         extentRatio: 0.2,
                      //         children: [
                      //           index > 0
                      //               ? Builder(
                      //                   builder: (context) {
                      //                     return InkWell(
                      //                       onTap: () async {
                      //                         setState(() {
                      //                           localStorageService
                      //                               .assetBalance1
                      //                               .removeAt(index);
                      //                         });
                      //                         await localStorageService
                      //                             .removeMapValue(
                      //                               localStorageService
                      //                                   .assetList[index],
                      //                               context,
                      //                             );
                      //                         WidgetsBinding.instance
                      //                             .addPostFrameCallback((_) {
                      //                               Provider.of<
                      //                                     LocalStorageService
                      //                                   >(
                      //                                     context,
                      //                                     listen: false,
                      //                                   )
                      //                                   .getData();
                      //                             });
                      //                         Slidable.of(context)?.close();
                      //                       },
                      //                       child: Padding(
                      //                         padding: const EdgeInsets.only(
                      //                           bottom: 6.0,
                      //                         ),
                      //                         child: Container(
                      //                           decoration: const BoxDecoration(
                      //                             borderRadius:
                      //                                 BorderRadius.only(
                      //                                   topRight:
                      //                                       Radius.circular(10),
                      //                                   bottomRight:
                      //                                       Radius.circular(10),
                      //                                 ),
                      //                             color: Colors.red,
                      //                           ),
                      //                           width: SizeConfig.width(
                      //                             context,
                      //                             16,
                      //                           ),
                      //                           child: Padding(
                      //                             padding: const EdgeInsets.all(
                      //                               4.0,
                      //                             ),
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .center,
                      //                               mainAxisAlignment:
                      //                                   MainAxisAlignment
                      //                                       .center,
                      //                               children: [
                      //                                 Icon(
                      //                                   Icons.delete,
                      //                                   color: Colors.white,
                      //                                 ),
                      //                                 AppText(
                      //                                   "Delete",
                      //                                   color: Colors.white,
                      //                                   fontSize: 12,
                      //                                   fontWeight:
                      //                                       FontWeight.bold,
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     );
                      //                   },
                      //                 )
                      //               : InkWell(
                      //                   onTap: () async {
                      //                     if (!await launchUrl(
                      //                       Uri.parse(
                      //                         localStorageService
                      //                             .assetList[index]
                      //                             .explorerURL!,
                      //                       ),
                      //                     )) {
                      //                       throw Exception(
                      //                         'Could not launch ',
                      //                       );
                      //                     }
                      //                   },
                      //                   child: Padding(
                      //                     padding: const EdgeInsets.only(
                      //                       bottom: 6.0,
                      //                     ),
                      //                     child: Container(
                      //                       decoration: const BoxDecoration(
                      //                         borderRadius: BorderRadius.only(
                      //                           topRight: Radius.circular(10),
                      //                           bottomRight: Radius.circular(
                      //                             10,
                      //                           ),
                      //                         ),
                      //                         color: Colors.blue,
                      //                       ),
                      //                       width: SizeConfig.width(
                      //                         context,
                      //                         16,
                      //                       ),
                      //                       child: Padding(
                      //                         padding: const EdgeInsets.all(
                      //                           4.0,
                      //                         ),
                      //                         child: Column(
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment.center,
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.center,
                      //                           children: [
                      //                             Icon(
                      //                               Icons.info,
                      //                               color: Colors.white,
                      //                             ),
                      //                             AppText(
                      //                               "  Info  ",
                      //                               color: Colors.white,
                      //                               fontSize: 12,
                      //                               fontWeight: FontWeight.bold,
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //         ],
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.only(bottom: 5.0),
                      //         child: ListTile(
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) {
                      //                   return TransactionAction(
                      //                     coinData: localStorageService
                      //                         .assetList[index],
                      //                     balance:
                      //                         (index <
                      //                             localStorageService
                      //                                 .assetBalance1
                      //                                 .length
                      //                         ? localStorageService
                      //                               .assetBalance1[index]
                      //                         : "0.0"),
                      //                     userWallet: localStorageService
                      //                         .activeWalletData!,
                      //                     usdPrice: double.parse(
                      //                       result.containsKey(
                      //                             "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //                           )
                      //                           ? result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0]
                      //                                 .toString()
                      //                           : "0",
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //           },
                      //           leading: Stack(
                      //             alignment: Alignment.bottomRight,
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.only(right: 5),
                      //                 child: CircleAvatar(
                      //                   radius: 20,
                      //                   backgroundColor: Color(0xFF202832),
                      //                   child: ClipRRect(
                      //                     borderRadius: BorderRadius.circular(
                      //                       30,
                      //                     ),
                      //                     child: Image.network(
                      //                       localStorageService
                      //                           .assetList[index]
                      //                           .imageUrl!,
                      //                       errorBuilder: (_, obj, trc) {
                      //                         return AppText(
                      //                           localStorageService
                      //                               .assetList[index]
                      //                               .coinSymbol
                      //                               .toString()
                      //                               .characters
                      //                               .first,
                      //                           color: Colors.white,
                      //                           fontWeight: FontWeight.bold,
                      //                         );
                      //                       },
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //               localStorageService
                      //                           .assetList[index]
                      //                           .coinType ==
                      //                       "2"
                      //                   ? Padding(
                      //                       padding: const EdgeInsets.only(
                      //                         left: 5,
                      //                       ),
                      //                       child: ClipRRect(
                      //                         borderRadius:
                      //                             BorderRadius.circular(30),
                      //                         child: Image.network(
                      //                           localStorageService.allAssetList.indexWhere(
                      //                                     (v) =>
                      //                                         v.gasPriceSymbol ==
                      //                                         localStorageService
                      //                                             .assetList[index]
                      //                                             .gasPriceSymbol,
                      //                                   ) ==
                      //                                   -1
                      //                               ? ""
                      //                               : localStorageService
                      //                                     .allAssetList[localStorageService
                      //                                         .allAssetList
                      //                                         .indexWhere(
                      //                                           (v) =>
                      //                                               v.gasPriceSymbol ==
                      //                                               localStorageService
                      //                                                   .assetList[index]
                      //                                                   .gasPriceSymbol,
                      //                                         )]
                      //                                     .imageUrl!,
                      //                           errorBuilder: (_, obj, trc) {
                      //                             return AppText(
                      //                               localStorageService
                      //                                   .assetList[index]
                      //                                   .gasPriceSymbol
                      //                                   .toString(),
                      //                               color: Colors.white,
                      //                               fontWeight: FontWeight.bold,
                      //                               fontSize: 7,
                      //                             );
                      //                           },
                      //                           height: 15,
                      //                         ),
                      //                       ),
                      //                     )
                      //                   : SizedBox(),
                      //             ],
                      //           ),
                      //           title: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Row(
                      //                 children: [
                      //                   AppText(
                      //                     localStorageService
                      //                         .assetList[index]
                      //                         .coinName!,
                      //                     fontSize: 15,
                      //                     fontWeight: FontWeight.w400,
                      //                     color: Theme.of(
                      //                       context,
                      //                     ).colorScheme.surfaceBright,
                      //                     overflow: TextOverflow
                      //                         .ellipsis, // This ensures truncation if needed
                      //                   ),
                      //                   SizedBox(width: 10),
                      //
                      //                   // Use Flexible instead of Expanded
                      //                   // Flexible(
                      //                   //   child: Container(
                      //                   //     decoration: BoxDecoration(
                      //                   //       borderRadius: BorderRadius.circular(
                      //                   //         10,
                      //                   //       ),
                      //                   //       color: Colors.black38,
                      //                   //     ),
                      //                   //     child: Padding(
                      //                   //       padding: const EdgeInsets.only(
                      //                   //         left: 4.0,
                      //                   //         right: 4.0,
                      //                   //       ),
                      //                   //       child: AppText(
                      //                   //         localStorageService
                      //                   //             .assetList[index]
                      //                   //             .network!,
                      //                   //         fontSize: 10,
                      //                   //         overflow: TextOverflow.ellipsis,
                      //                   //         // Ensure truncation here too
                      //                   //       ),
                      //                   //     ),
                      //                   //   ),
                      //                   // ),
                      //                 ],
                      //               ),
                      //               Row(
                      //                 children: [
                      //                   result.containsKey(
                      //                         "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //                       )
                      //                       ? AppText(
                      //                           "${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)} ${localStorageService.assetList[index].coinSymbol!}",
                      //                           fontSize: 13,
                      //                           fontWeight: FontWeight.w400,
                      //                           color: Colors.white.withOpacity(
                      //                             0.6,
                      //                           ),
                      //                         )
                      //                       : AppText(
                      //                           localStorageService
                      //                                       .assetList[index]
                      //                                       .coinType ==
                      //                                   '2'
                      //                               ? "Token"
                      //                               : "\$1224.65",
                      //                           fontSize: 13,
                      //                           fontWeight: FontWeight.w400,
                      //                           color: Theme.of(
                      //                             context,
                      //                           ).colorScheme.surfaceBright,
                      //                         ),
                      //                   SizedBox(
                      //                     width: SizeConfig.width(context, 4),
                      //                   ),
                      //                   //old code
                      //                   // result.containsKey(
                      //                   //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //                   //     )
                      //                   //     ? Row(
                      //                   //         children: [
                      //                   //           AppText(
                      //                   //             double.parse(
                      //                   //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                      //                   //                           .toString(),
                      //                   //                     ) <
                      //                   //                     0
                      //                   //                 ? ''
                      //                   //                 : '+',
                      //                   //             fontSize: 12,
                      //                   //             color:
                      //                   //                 double.parse(
                      //                   //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                      //                   //                           .toString(),
                      //                   //                     ) <
                      //                   //                     0
                      //                   //                 ? Color(0xFFFD0000)
                      //                   //                 : Colors.green,
                      //                   //           ),
                      //                   //           AppText(
                      //                   //             '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                      //                   //             fontSize: 13,
                      //                   //             fontWeight: FontWeight.w400,
                      //                   //             color:
                      //                   //                 double.parse(
                      //                   //                       result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                      //                   //                           .toString(),
                      //                   //                     ) <
                      //                   //                     0
                      //                   //                 ? Color(0xFFFD0000)
                      //                   //                 : Colors.green,
                      //                   //           ),
                      //                   //         ],
                      //                   //       )
                      //                   //     : SizedBox(),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //           trailing: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.end,
                      //             mainAxisSize: MainAxisSize.min,
                      //             // Ensure the column takes minimum space
                      //             children: [
                      //               result.containsKey(
                      //                     "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //                   )
                      //                   ? AppText(
                      //                       "\$${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                      //                       fontSize: 13,
                      //                       fontWeight: FontWeight.w400,
                      //                       color: Theme.of(
                      //                         context,
                      //                       ).colorScheme.surfaceBright,
                      //                     )
                      //                   : AppText(
                      //                       localStorageService
                      //                                   .assetList[index]
                      //                                   .coinType ==
                      //                               '2'
                      //                           ? "Token"
                      //                           : "\$1224.65",
                      //                       fontSize: 13,
                      //                       fontWeight: FontWeight.w400,
                      //                       color: Theme.of(
                      //                         context,
                      //                       ).colorScheme.surfaceBright,
                      //                     ),
                      //               //old code
                      //               // AppText(
                      //               //   isTextVisible
                      //               //       ? (index <
                      //               //                 localStorageService
                      //               //                     .assetBalance1
                      //               //                     .length
                      //               //             ? double.tryParse(
                      //               //                             localStorageService
                      //               //                                 .assetBalance1[index],
                      //               //                           ) !=
                      //               //                           null &&
                      //               //                       double.tryParse(
                      //               //                             localStorageService
                      //               //                                 .assetBalance1[index],
                      //               //                           )! >
                      //               //                           0
                      //               //                   ? double.tryParse(
                      //               //                           localStorageService
                      //               //                               .assetBalance1[index],
                      //               //                         )!
                      //               //                         .toStringAsFixed(6)
                      //               //                         .replaceAll(
                      //               //                           RegExp(
                      //               //                             r"([.]*0+)(?!.*\d)",
                      //               //                           ),
                      //               //                           "",
                      //               //                         ) // Remove trailing zeros
                      //               //                   : "0"
                      //               //             : "0")
                      //               //       : "****",
                      //               //   fontSize: 15,
                      //               //   fontWeight: FontWeight.w400,
                      //               //   color: Theme.of(
                      //               //     context,
                      //               //   ).colorScheme.surfaceBright,
                      //               // ),
                      //               result.containsKey(
                      //                     "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //                   )
                      //                   ? AppText(
                      //                       '${double.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                      //                       fontSize: 13,
                      //                       fontWeight: FontWeight.w400,
                      //                       color:
                      //                           double.parse(
                      //                                 result["${localStorageService.assetList[index].coinSymbol!}USDT"]![1]
                      //                                     .toString(),
                      //                               ) <
                      //                               0
                      //                           ? Color(0xFFFD0000)
                      //                           : Colors.green,
                      //                     )
                      //                   : AppText(
                      //                       "0.54%",
                      //                       color: Colors.green,
                      //                       fontSize: 13,
                      //                       fontWeight: FontWeight.w400,
                      //                     ),
                      //               //old code
                      //               // result.containsKey(
                      //               //       "${localStorageService.assetList[index].coinSymbol!}USDT",
                      //               //     )
                      //               //     ? AppText(
                      //               //         isTextVisible
                      //               //             ? "\$${(num.parse(result["${localStorageService.assetList[index].coinSymbol!}USDT"]![0].toString()) * num.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index].toString() : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                      //               //             : '****',
                      //               //         fontSize: 12,
                      //               //         fontWeight: FontWeight.w400,
                      //               //         color: Theme.of(
                      //               //           context,
                      //               //         ).colorScheme.surfaceBright,
                      //               //       )
                      //               //     : SizedBox(),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                    );
                    // }
                    // return Container();
                  },
                ),
        ),
      ],
    );
  }


  //*************Ntf flow *****************************//





  Future<void> fetchNFTs() async {


    setState(() => loading1 = true);
    try {
      final url =
          'https://eth-mainnet.alchemyapi.io/v2/$alchemyApiKey/getNFTs?owner=$ownerAddress';
      print("??????????????????????${url}");
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) throw Exception('Failed to fetch NFTs');

      final data = json.decode(resp.body);
      final List<NFT> fetchedNFTs = [];

      for (var item in data['ownedNfts']) {
        final metadata = item['metadata'] ?? {};
        final image = metadata['image'] ?? '';
        final tokenId = item['id']['tokenId'] ?? '';
        fetchedNFTs.add(
          NFT(
            contract: item['contract']['address'] ?? '',
            tokenId: tokenId,
            name: metadata['name'] ?? 'Token #$tokenId',
            description: metadata['description'] ?? '',
            image: image.startsWith('ipfs://')
                ? 'https://ipfs.io/ipfs/${image.substring(7)}'
                : image,
            rawTokenURI: item['tokenUri']?['gateway'] ?? '',
          ),
        );
      }

      setState(() => nfts = fetchedNFTs);
    } catch (e) {
      print('Error fetching NFTs: $e');
    } finally {
      setState(() => loading1 = false);
    }
  }

  Widget _buildDataImage(String dataUri) {
    if (dataUri.contains('image/svg+xml')) {
      final start = dataUri.indexOf('base64,');
      if (start != -1) {
        final b64 = dataUri.substring(start + 'base64,'.length);
        final svgStr = utf8.decode(base64.decode(b64));
        return SvgPicture.string(svgStr, fit: BoxFit.contain);
      }
    }
    if (dataUri.contains('image/png') ||
        dataUri.contains('image/jpeg') ||
        dataUri.contains('image/jpg')) {
      final start = dataUri.indexOf('base64,');
      if (start != -1) {
        final b64 = dataUri.substring(start + 'base64,'.length);
        final bytes = base64.decode(b64);
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    }
    return const Center(child: Icon(Icons.broken_image));
  }

  Future<String> sendNFT({
    required String privateKey,
    required String contractAddress,
    required String toAddress,
    required BigInt tokenId,
  }) async
  {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final contract = DeployedContract(
      ContractAbi.fromJson('''
        [
          {"constant": false, "inputs": [{"name": "from", "type": "address"}, {"name": "to", "type": "address"}, {"name": "tokenId", "type": "uint256"}], "name": "safeTransferFrom", "outputs": [], "type": "function"}
        ]
        ''', 'ERC721'),
      EthereumAddress.fromHex(contractAddress),
    );
    final function = contract.function('safeTransferFrom');

    final tx = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        EthereumAddress.fromHex(ownerAddress!),
        EthereumAddress.fromHex(toAddress),
        tokenId,
      ],
    );

    final hash = await web3client.sendTransaction(
      credentials,
      tx,
      chainId: 1,
      fetchChainIdFromNetworkId: false,
    );
    return hash;
  }

  void _showSendDialog(NFT nft) {
    final toController = TextEditingController();
    final pkController = TextEditingController();
    bool sending = false;
    String? txHash;

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text('Send ${nft.name}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: toController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient address',
                      ),
                    ),
                    TextField(
                      controller: pkController,
                      decoration: const InputDecoration(
                        labelText: 'Your private key',
                      ),
                    ),
                    if (sending)  CircularProgressIndicator(
                 color: Colors.purpleAccent[100],
                    ),
                    if (txHash != null)
                      SelectableText(
                        'Tx hash: $txHash',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: sending ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                      final to = toController.text.trim();
                      final pk = pkController.text.trim();
                      if (to.isEmpty || pk.isEmpty) return;

                      setStateDialog(() {
                        sending = true;
                        txHash = null;
                      });

                      try {
                        final hash = await sendNFT(
                          privateKey: pk.startsWith('0x') ? pk : '0x$pk',
                          contractAddress: nft.contract,
                          toAddress: to,
                          tokenId: BigInt.parse(nft.tokenId),
                        );
                        setStateDialog(() {
                          txHash = hash;
                        });
                      } catch (e) {
                        setStateDialog(() {
                          txHash = 'Error: $e';
                        });
                      } finally {
                        setStateDialog(() => sending = false);
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          ),
    );
  }

  //*************Ntf flow *****************************//

  Widget NFTsTab() {
    return loading1
        ? Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: AppText('Loading...'),
      ),
    )
        : nfts.isEmpty
        ? Padding(
      padding: const EdgeInsets.all(80.0),
      child: AppText('No NFTs found for this wallet.'),
    )
        : GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        final nft = nfts[index];

        return GestureDetector(
          onTap: () => _showSendDialog(nft),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              // stronger blur
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: nft.image.startsWith('data:')
                          ? _buildDataImage(nft.image)
                          : CachedNetworkImage(
                        imageUrl: nft.image.isNotEmpty
                            ? nft.image
                            : 'https://via.placeholder.com/300',
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                         Center(
                          child: CircularProgressIndicator(
                            color: Colors.purpleAccent[100],
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                        const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nft.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${BigInt.parse(nft.tokenId).toString()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
