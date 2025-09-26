import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalance.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/App_Drawer/App_Drawer_View.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
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
    channel.sink
        .add(jsonEncode({"method": "SUBSCRIBE", "params": usdtPair, "id": 1}));
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
            _buildSetupOptions(context),
            _buildTrendingTitle(),
            _buildTrendingList(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu,
            color: Theme.of(context).colorScheme.surfaceBright),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildWalletBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/Images/wallet.png', height: 200, width: 200),
        Positioned(
            left: 1, bottom: 10, child: _buildFloatingBall1(Colors.blueAccent)),
        Positioned(
            top: 0.1,
            right: 0.1,
            child: _buildFloatingBall2(Colors.greenAccent)),
        Positioned(
            bottom: 5,
            right: 1,
            child: _buildFloatingBall(Colors.lightBlueAccent)),
      ],
    );
  }

  Widget _buildSetupOptions(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GradientAppText(
            text: "Empowering the next wave of\nWeb3 users—join us!",
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        _buildOptionCard(
          context,
          icon: Icons.add,
          title: "Set Up Your Wallet",
          subtitle: "Secret Phrase",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SecureBackup()),
          ),
        ),
        _buildOptionCard(
          context,
          icon: Icons.arrow_downward,
          title: "Access Existing Wallet",
          subtitle: "Recover, Import, or View-Only Access",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConnectExistingWallet()),
          ),
        ),
      ],
    );
  }

  // padding: const EdgeInsets.only(
  // left: 64, right: 64, top: 8, bottom: 8),
  //
  // Padding(
  // padding: const EdgeInsets.only(left: 24, right: 24, top: 84),

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white30.withOpacity(0.2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF3D354C),
                  radius: 20,
                  child: Icon(icon, color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.surfaceBright),
                  AppText(subtitle,
                      fontWeight: FontWeight.w300,
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.surfaceBright),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          AppText("Trending Tokens 🔥", color: Color(0xFF787878)),
        ],
      ),
    );
  }

  Widget _buildTrendingList() {
    return SizedBox(
      height: 450,
      child: StreamBuilder(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
          _updateResult(data);

          return ListView.builder(
            itemCount: assetList.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _buildTokenTile(context, index),
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white30.withOpacity(0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: ListTile(
              onTap: () => Utils.snackBar(
                "Please Create or Import an Wallet",
              ),
              leading:
                  _buildTokenAvatar(coinSymbol, assetList[index]["imageUrl"]!),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(coinSymbol,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.surfaceBright),
                  AppText(coinName,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.surfaceBright),
                ],
              ),
              trailing:
                  _buildTokenTrailing(context, coinSymbol, coinName, coinData),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenAvatar(String symbol, String imageUrl) {
    return CircleAvatar(
      radius: 15,
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
    );
  }

  Widget _buildTokenTrailing(
      BuildContext context, String symbol, String name, List<String>? data) {
    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(name,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.surfaceBright),
          AppText("Crypto",
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.surfaceBright),
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

Widget _buildFloatingBall(Color color) {
  return Container(
    width: 15, // Adjust size
    height: 15,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}

Widget _buildFloatingBall1(Color color) {
  return Container(
    width: 8, // Adjust size
    height: 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}

Widget _buildFloatingBall2(Color color) {
  return Container(
    width: 18, // Adjust size
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}
