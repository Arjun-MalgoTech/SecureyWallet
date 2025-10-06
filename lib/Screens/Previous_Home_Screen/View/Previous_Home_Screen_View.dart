import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalance.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Constant_Image.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/App_Drawer/App_Drawer_View.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
import 'package:securywallet/Screens/HomeScreen/Controllers/home_controller.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/ViewModel/Pre_Home_Screen_VM.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_View.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/StaticAssetList.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PreHome extends StatefulWidget {
  PreHome({super.key});

  @override
  State<PreHome> createState() => _PreHomeState();
}

// Optimized and restructured version of _PreHomeState
class _PreHomeState extends State<PreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController<Map<String, dynamic>> streamController =
      StreamController.broadcast();
  late WebSocketChannel channel;
  late PreHomeScreenVm viewModel;

  List<Map<String, String>> assetList = [];
  Map<String, List<String>> result = {};
  List<String> usdtPair = [];

  @override
  void initState() {
    super.initState();
    _initViewModel();
    _fetchInitialPrice();
    _initWebSocket();
  }

  void _initViewModel() {
    viewModel = Provider.of<PreHomeScreenVm>(context, listen: false);
    viewModel.addDataToStorage(mandatoryCoinList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      assetList = viewModel.retrieveDataFromStorage();
      _subscribeToPairs();
    });
  }

  void _fetchInitialPrice() async {
    var nvxTicker = await assetBalance.nvxAPIUSDTPrice("NVXO_USDT");
    if (!streamController.isClosed) {
      streamController.add(nvxTicker);
    }
  }

  void _initWebSocket() {
    channel = IOWebSocketChannel.connect('wss://stream.binance.com:9443/ws');
    channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      if (!streamController.isClosed) {
        streamController.add(data);
      }
    });
  }

  void _subscribeToPairs() {
    usdtPair = assetList
        .map((coin) => "${coin["coinSymbol"]!.toLowerCase()}usdt@ticker")
        .toList();
    channel.sink.add(
      jsonEncode({"method": "SUBSCRIBE", "params": usdtPair, "id": 1}),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = context.watch<PreHomeScreenVm>();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWalletBanner(),
            _buildTrendingTitle(),
            _buildSetupOptions(context),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Text(
                        "Crypto",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: Color(0XFF444444)),
                    ),
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Text(
                        "NFTs",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildTrendingList(),

            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8),
              child: _buildOptionCard(
                context,

                title: "Create New Wallet",

                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SecureBackup()),
                ),
              ),
            ),
            _buildOptionCard1(
              context,

              title: "Access Existing Wallet",

              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConnectExistingWallet()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildWalletBanner() {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30, bottom: 8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset("assets/Images/1.png"),
          ),
          Column(
            children: [
              SizedBox(height: SizeConfig.height(context, 2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "\$567.89",
                    style: TextStyle(
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontSize: 36,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
              AppText(
                "\$11.32 (+1.46%)",
                color: Colors.green,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              SizedBox(height: SizeConfig.height(context, 6)),
              Padding(
                padding: const EdgeInsets.only(left: 26.0, right: 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: // Required for ImageFilter
                          SvgPicture.asset(
                            ConstantImage.arrowup,
                          ),
                        ),
                        SizedBox(height: SizeConfig.height(context, 0.5)),
                        AppText(
                          "Send",
                          fontFamily: 'LexendDeca',
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.surfaceBright,
                          fontSize: 14,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          SvgPicture.asset(ConstantImage.arrowdown),

                          SizedBox(height: SizeConfig.height(context, 0.5)),
                          AppText(
                            "Receive",
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          SvgPicture.asset(ConstantImage.crevon),
                          SizedBox(height: SizeConfig.height(context, 0.5)),
                          AppText(
                            "Fund",
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          SvgPicture.asset(ConstantImage.Dollar),
                          SizedBox(height: SizeConfig.height(context, 0.5)),
                          AppText(
                            "Sell",
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetupOptions(BuildContext context) {
    return SizedBox(
      height: 80, // Adjust height based on your container content
      child: StreamBuilder(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
          _updateResult(data);

          return ListView.builder(
            itemCount: assetList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _buildTokenTile(context, index),
          );
        },
      ),
    );
  }

  // padding: const EdgeInsets.only(
  // left: 64, right: 64, top: 8, bottom: 8),
  //
  // Padding(
  // padding: const EdgeInsets.only(left: 24, right: 24, top: 84),

  Widget _buildOptionCard(
    BuildContext context, {

    required String title,

    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Center(
              child: AppText(
                title,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard1(
    BuildContext context, {

    required String title,

    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
            ),
            child: Center(
              child: AppText(
                title,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, top: 12),
      child: Row(children: [AppText("Trending", color: Colors.white)]),
    );
  }

  Widget _buildTrendingList() {
    return Column(
      children: [
        Image.asset("assets/Images/emptywallet.png", height: 200, width: 300),
        AppText(
          "Your wallet is empty!",
          color: Color(0XFFB4B1B2),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  void _updateResult(Map<String, dynamic> data) {
    String symbol = data['s'].toString().toLowerCase();
    for (var value in assetList) {
      if (symbol.contains(value["coinSymbol"]!.toLowerCase())) {
        result[value["coinSymbol"]!] = [data['c'], data['P']];
      }
    }
  }

  Widget _buildTokenTile(BuildContext context, int index) {
    String coinSymbol = assetList[index]["coinSymbol"]!;
    String coinName = assetList[index]["coinName"]!;
    List<String>? coinData = result[coinSymbol];

    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0XFF34373d)),
          borderRadius: BorderRadius.circular(15),
          color: Color(0XFF0f131a),
        ),
        width: MediaQuery.of(context).size.width * 0.7,
        child: ListTile(
          onTap: () => Utils.snackBar("Please Create or Import an Wallet"),
          leading: _buildTokenAvatar(coinSymbol, assetList[index]["imageUrl"]!),
          title: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  coinSymbol,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.surfaceBright,
                ),
                AppText(
                  coinName,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.surfaceBright,
                ),
              ],
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildTokenTrailing(context, coinSymbol, coinName, coinData),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenAvatar(String symbol, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0, bottom: 15),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFF202832),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            imageUrl,
            errorBuilder: (_, __, ___) => AppText(
              symbol.characters.first,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenTrailing(
    BuildContext context,
    String symbol,
    String name,
    List<String>? data,
  ) {
    if (data == null) {
      return Column(
        children: [
          AppText(
            name,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
          AppText(
            "Crypto",
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
        ],
      );
    }

    double value = double.parse(data[1]);
    Color valueColor = value < 0 ? Color(0xFFFD0000) : Colors.green;
    String prefix = value > 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          double.parse(data[0]).toStringAsFixed(CoinListConfig.usdtDecimal),
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        AppText(
          '$prefix${value.toStringAsFixed(CoinListConfig.usdtDecimal)}%',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: valueColor,
        ),
      ],
    );
  }
}
