import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/WalletConnectFunctions/pages/connect_page.dart';
import 'package:securywallet/WalletConnectFunctions/pages/pairings_page.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class WalletConnectPage extends StatefulWidget {
  final UserWalletDataModel selectedWalletData;
  final String? wcURL;

  const WalletConnectPage({
    super.key,
    required this.selectedWalletData,
    this.wcURL,
  });

  @override
  State<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends State<WalletConnectPage>
    with TickerProviderStateMixin {
  late bool _initializing;
  late bool _enableScanView;
  TabController? _tabController;
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  void initState() {
    _initializing = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _initializing = false;
      });
    });
    _enableScanView = false;
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest.initializeContext(context);
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
        title: Column(
          children: [
            AppText('Wallet Connect'),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Theme.of(context).colorScheme.surfaceBright,
          tabs: const [
            Tab(text: 'Connect'),
            Tab(text: 'Pairings'),
          ],
        ),
      ),
      // extendBodyBehindAppBar: true,
      body: _initializing
          ? Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.purpleAccent[100],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                ConnectPage(
                  signClient: walletConnectionRequest.signClient!,
                  selectedWalletData: widget.selectedWalletData,
                  enableScanView: _enableScanView,
                  wcURL: (widget.wcURL ?? "").contains("2/wc")
                      ? null
                      : widget.wcURL,
                ),
                PairingsPage(signClient: walletConnectionRequest.signClient!),
              ],
            ),
    );
  }
}
