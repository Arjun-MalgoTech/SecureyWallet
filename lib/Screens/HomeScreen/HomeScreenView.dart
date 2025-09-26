import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:securywallet/Screens/HomeScreen/AllAssetAddress_View/AllAssetAddressView.dart';
import 'package:securywallet/Screens/HomeScreen/Controllers/home_controller.dart';
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

  const HomeView({
    super.key,
    required this.dollar,
    required this.privateKey,
  });

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
  WebSocketChannel channel =
      IOWebSocketChannel.connect('wss://stream.binance.com:9443/ws');

  bool isPasscodeSet = false;

  void _checkPasscodeSet() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');
    if (savedPasscode == null) {
      // Passcode is set
      setState(() {
        isPasscodeSet = true;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasscodeScreen(
          name: "",
          data: localStorageService.activeWalletData!,
        );
      }));
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
            walletData: localStorageService.activeWalletData);
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
    usdTotal.value =
        multiplyCalculation(result, localStorageService.assetBalance1)
            .toStringAsFixed(CoinListConfig.usdtDecimal);
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
    channel.sink
        .add(jsonEncode({"method": "SUBSCRIBE", "params": usdtPair, "id": 1}));
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
      sum += double.parse(listValues[i]) *
          double.parse(i >= localStorageService.assetList.length
              ? "0"
              : mapValues.containsKey(
                      "${localStorageService.assetList[i].coinSymbol}USDT")
                  ? "${mapValues["${localStorageService.assetList[i].coinSymbol}USDT"][0]}"
                  : "0");
    }
    return sum;
  }

  bool isTextVisible = true;

  List<AssetBalanceModel> overallBalances = [];

  Future<void> fetchOverallBalances(List<String>? data) async {
    var balances = data;

    overallBalances =
        List.generate(localStorageService.assetList.length, (index) {
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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          centerTitle: true,
          title: Text(
            'NVXO WALLET',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Theme.of(context).colorScheme.surfaceBright,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRView()),
                      );
                    });
                    FocusScope.of(context)
                        .unfocus(); // Unfocus to dismiss the keyboard
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        ConstantImage.imgPrinter,
                        width: 20,
                        height: 20,
                        semanticsLabel: 'Acme Logo',
                        color: Color(0XFFB982FF),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AssetManager()))
                          .then((v) {});
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
            SizedBox(
              width: SizeConfig.width(context, 5),
            ),
          ],
        ),
        key: _scaffoldKey,
        drawer: AppDrawer(walletConnectionRequest: walletSessionRequest),
        body: RefreshIndicator(
          onRefresh: _refresh, // Trigger the refresh action
          child: localStorageService.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.purpleAccent[100],
                ))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const UserWalletPage();
                          }));
                          FocusScope.of(context).unfocus();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Color(0XFF71E863),
                                // Background color
                                shape: BoxShape.circle, // Makes it circular
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            AppText(
                              localStorageService.activeWalletData!.walletName
                                          .toString()
                                          .length >
                                      16
                                  ? '${localStorageService.activeWalletData!.walletName.toString().substring(0, 16)}...'
                                  : localStorageService
                                      .activeWalletData!.walletName
                                      .toString(),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 1),
                      ),
                      boyImage(),
                      SizedBox(
                        height: SizeConfig.height(context, 1),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            CircularProgressIndicator(
                              color: Colors.purpleAccent[100],
                            );
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return AllAssetAddress(
                                userData: localStorageService.activeWalletData!,
                                address: localStorageService
                                    .activeWalletData!.walletAddress,
                              );
                            }),
                          );

                          FocusScope.of(context).unfocus();
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFF262737)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6.0, right: 6.0),
                                  child: AppText(
                                    '${localStorageService.activeWalletData!.walletAddress.substring(0, 6)}...${localStorageService.activeWalletData!.walletAddress.substring(localStorageService.activeWalletData!.walletAddress.length - 4)}',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    ConstantImage.imgContentCopy,
                                    width: 18,
                                    height: 18,
                                    semanticsLabel: 'Acme Logo',
                                    color: Color(0XFFB982FF),
                                  ),
                                ),
                              )
                            ]),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              ValueListenableBuilder(
                                  valueListenable: usdTotal,
                                  builder: (context, value, child) {
                                    return Text(
                                      isTextVisible ? "\$ ${value}" : "****",
                                      style: TextStyle(
                                        fontFamily: 'LexendDeca',
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                        fontSize: 30,
                                      ),
                                    );
                                  }),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isTextVisible = !isTextVisible;
                                  });
                                },
                                child: isTextVisible
                                    ? Icon(
                                        Icons.visibility,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                        size: 22,
                                      )
                                    : Icon(
                                        Icons.visibility_off,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                        size: 22,
                                      ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _controller.value *
                                            2 *
                                            3.1416, // Full rotation
                                        child: Icon(
                                          Icons.refresh,
                                          color: Color(0XFFB982FF),
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                onPressed: _isRefreshing ? null : _refresh,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 1),
                      ),
                      iconRow(context),
                      SizedBox(
                        height: SizeConfig.height(context, 2),
                      ),
                      bannerImage(context),
                      SizedBox(
                        height: SizeConfig.height(context, 1),
                      ),
                      TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        labelPadding: EdgeInsets.zero,
                        indicatorColor:
                            Colors.transparent, // Set indicator color to 30DCF9
                        tabs: [
                          tabs("Crypto", 0),
                          tabs(" NFTs ", 1),
                        ],
                      ),
                      Container(
                        height: SizeConfig.height(
                            context, localStorageService.assetList.length * 9),
                        color: Colors.transparent,
                        child: TabBarView(
                            controller: _tabController,
                            children: [AssetTab(), NFTsTab()]),
                      ),
                    ],
                  ),
                ),
        ));
  }

  Map<String, List<String>> result = {};

  Widget tabs(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? Color(0xFFB982FF)
            : Colors.white30, // Change color when selected
      ),
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Tab(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? Colors.black : Colors.white, // Change text color
          ),
        ),
      ),
    );
  }

  Widget AssetTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          ///single 50 -  so count value

          Expanded(
            child: balanceLoading
                ? Center(
                    child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      CircularProgressIndicator(
                        color: Colors.purpleAccent[100],
                      ),
                    ],
                  ))
                : StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data =
                            snapshot.data as Map<String, dynamic>;
                        String symbol = data['s'] ?? "";
                        for (var value in localStorageService.assetList) {
                          if (symbol.toLowerCase().contains(
                              "${value.coinSymbol!}USDT".toLowerCase())) {
                            if (result
                                .containsKey("${value.coinSymbol!}USDT")) {
                              result["${value.coinSymbol!}USDT"] = [
                                data['c'],
                                data['P']
                              ];
                            } else {
                              result.addAll({
                                "${value.coinSymbol!}USDT": [
                                  data['c'],
                                  data['P']
                                ]
                              });
                            }
                          }
                        }
                      }

                      return searchController.text.isNotEmpty
                          ? filteredCoins.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 64.0),
                                  child: GradientAppText(
                                      text: "No data found", fontSize: 16),
                                )
                              : ListView.builder(
                                  itemCount: filteredCoins
                                      .length, // Set the number of items to 5
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0,
                                                left: 16,
                                                right: 16),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white30.withOpacity(
                                                      0.1), // Make it slightly transparent
                                                ),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Ensure blur stays within bounds
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 20,
                                                          sigmaY: 20),
                                                      child: ListTile(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            int originalIndex =
                                                                localStorageService
                                                                    .assetList
                                                                    .indexOf(
                                                                        filteredCoins[
                                                                            index]);
                                                            return TransactionAction(
                                                              coinData:
                                                                  filteredCoins[
                                                                      index],
                                                              balance: (originalIndex <
                                                                      localStorageService
                                                                          .assetBalance1
                                                                          .length
                                                                  ? localStorageService
                                                                          .assetBalance1[
                                                                      originalIndex]
                                                                  : "0.0"),
                                                              userWallet:
                                                                  localStorageService
                                                                      .activeWalletData!,
                                                              usdPrice: double.parse(result
                                                                      .containsKey(
                                                                          "${filteredCoins[index].coinSymbol!}USDT")
                                                                  ? result["${filteredCoins[index].coinSymbol!}USDT"]![
                                                                          0]
                                                                      .toString()
                                                                  : "0"),
                                                            );
                                                          }));
                                                        },
                                                        leading: Stack(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 15,
                                                                  backgroundColor:
                                                                      Color(
                                                                          0xFF202832),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                    child: Image
                                                                        .network(
                                                                      filteredCoins[
                                                                              index]
                                                                          .imageUrl!,
                                                                      errorBuilder: (_,
                                                                          obj,
                                                                          trc) {
                                                                        return AppText(
                                                                          filteredCoins[index]
                                                                              .coinSymbol
                                                                              .toString()
                                                                              .characters
                                                                              .first,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              filteredCoins[index]
                                                                          .coinType ==
                                                                      "2"
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30),
                                                                        child: Image
                                                                            .network(
                                                                          localStorageService.allAssetList.indexWhere((v) => v.gasPriceSymbol == filteredCoins[index].gasPriceSymbol) == -1
                                                                              ? ""
                                                                              : localStorageService.allAssetList[localStorageService.allAssetList.indexWhere((v) => v.gasPriceSymbol == filteredCoins[index].gasPriceSymbol)].imageUrl!,
                                                                          errorBuilder: (_,
                                                                              obj,
                                                                              trc) {
                                                                            return AppText(
                                                                              filteredCoins[index].gasPriceSymbol.toString(),
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 7,
                                                                            );
                                                                          },
                                                                          height:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                            ]),
                                                        title: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                AppText(
                                                                  filteredCoins[
                                                                          index]
                                                                      .coinSymbol!,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .surfaceBright,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // This ensures truncation if needed
                                                                ),
                                                                SizedBox(
                                                                    width: 10),

                                                                // Use Flexible instead of Expanded
                                                                Flexible(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Color(
                                                                          0xFF262737),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              4.0,
                                                                          right:
                                                                              4.0),
                                                                      child:
                                                                      AppText(
                                                                        filteredCoins[index]
                                                                            .network!,
                                                                        fontSize:
                                                                            10,
                                                                        overflow:
                                                                            TextOverflow.ellipsis, // Ensure truncation here too
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                result.containsKey(
                                                                        "${filteredCoins[index].coinSymbol!}USDT")
                                                                    ? AppText(
                                                                        "\$${double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![0].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}",
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .surfaceBright,
                                                                      )
                                                                    : AppText(
                                                                        localStorageService.assetList[index].coinType ==
                                                                                '2'
                                                                            ? "Token"
                                                                            : "Crypto",
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .surfaceBright,
                                                                      ),
                                                                SizedBox(
                                                                  width: SizeConfig
                                                                      .width(
                                                                          context,
                                                                          4),
                                                                ),
                                                                result.containsKey(
                                                                        "${filteredCoins[index].coinSymbol!}USDT")
                                                                    ? Row(
                                                                        children: [
                                                                          AppText(
                                                                            double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![1].toString()) < 0
                                                                                ? ''
                                                                                : '+',
                                                                            fontSize:
                                                                                12,
                                                                            color: double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![1].toString()) < 0
                                                                                ? Color(0xFFFD0000)
                                                                                : Colors.green,
                                                                          ),
                                                                          AppText(
                                                                            '${double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![1].toString()).toStringAsFixed(CoinListConfig.usdtDecimal)}% ',
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![1].toString()) < 0
                                                                                ? Color(0xFFFD0000)
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
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          // Ensure the column takes minimum space
                                                          children: [
                                                            AppText(
                                                              isTextVisible
                                                                  ? (double.tryParse(overAllBalance[index]) !=
                                                                              null &&
                                                                          double.tryParse(overAllBalance[index])! >
                                                                              0
                                                                      ? double.tryParse(overAllBalance[
                                                                              index])!
                                                                          .toStringAsFixed(
                                                                              6)
                                                                          .replaceAll(
                                                                              RegExp(r"([.]*0+)(?!.*\d)"),
                                                                              "") // Remove trailing zeros
                                                                      : "0")
                                                                  : "****",
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surfaceBright,
                                                            ),
                                                            result.containsKey(
                                                                    "${filteredCoins[index].coinSymbol!}USDT")
                                                                ? AppText(
                                                                    isTextVisible
                                                                        ? "\$${(double.parse(result["${filteredCoins[index].coinSymbol!}USDT"]![0].toString()) * double.parse(index < localStorageService.assetBalance1.length ? localStorageService.assetBalance1[index] : "0.0")).toStringAsFixed(CoinListConfig.usdtDecimal)}"
                                                                        : '****',
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .surfaceBright,
                                                                  )
                                                                : SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ))))
                                      ],
                                    );
                                  },
                                )
                          : ListView.builder(
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
                                          index > 0
                                              ? Builder(builder: (context) {
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
                                              : InkWell(
                                                  onTap: () async {
                                                    if (!await launchUrl(Uri
                                                        .parse(localStorageService
                                                            .assetList[index]
                                                            .explorerURL!))) {
                                                      throw Exception(
                                                          'Could not launch ');
                                                    }
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
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: Colors.blue,
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
                                                              Icons.info,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            AppText(
                                                              "  Info  ",
                                                              color:
                                                                  Colors.white,
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
                                                )
                                        ]),
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5.0, left: 16, right: 16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white30.withOpacity(
                                                0.1), // Make it slightly transparent
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10), // Ensure blur stays within bounds
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 20, sigmaY: 20),
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
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors
                                                                  .black38,
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
                                                                        .ellipsis,
                                                                // Ensure truncation here too
                                                              ),
                                                            ),
                                                          ),
                                                        ),
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
                                            ),
                                          ),
                                        )));
                              },
                            );
                      // }
                      // return Container();
                    }),
          )
        ],
      ),
    );
  }

  Widget NFTsTab() {
    return const Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          children: [
            ComingSoon(),
          ],
        ));
  }
}
