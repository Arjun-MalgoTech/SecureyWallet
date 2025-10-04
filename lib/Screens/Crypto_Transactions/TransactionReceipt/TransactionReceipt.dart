import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/Hex_Bytes.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Hash_Model.dart';
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';

class TransactionReceiptPage extends StatefulWidget {
  final TransactionInformation? transactiondata;
  final AssetModel coinData;
  final UserWalletDataModel userWallet;
  final HashModel hashModel;

  const TransactionReceiptPage({
    Key? key,
    this.transactiondata,
    required this.coinData,
    required this.userWallet,
    required this.hashModel,
  }) : super(key: key);

  @override
  State<TransactionReceiptPage> createState() => _TransactionReceiptPageState();
}

class _TransactionReceiptPageState extends State<TransactionReceiptPage> {
  TransactionReceipt? transactionReceipt;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactiondata != null) {
      fetchTransactionReceipt();
    }
  }

  Future<void> fetchTransactionReceipt() async {
    final client = Web3Client(widget.coinData.rpcURL!, Client());
    try {
      final data = await client.getTransactionReceipt(widget.hashModel.hash!);
      setState(() => transactionReceipt = data);
    } catch (_) {}
  }

  Future<void> _handleTap() async {
    if (_isTapped) return;
    setState(() => _isTapped = true);

    try {
      final url = _buildExplorerUrl();
      print("url $url");

      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print(e);
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      _isTapped = false;
    }
  }

  String _buildExplorerUrl() {
    final hash = widget.hashModel.hash;
    final baseUrl = widget.coinData.explorerURL!;
    final symbol = widget.coinData.gasPriceSymbol;
    final rpcUrl = widget.coinData.rpcURL;
    final coinType = widget.coinData.coinType;

    if (symbol == "TRX" || symbol == "tTRX") {
      return "${baseUrl}transaction/$hash";
    } else if (symbol == "tSOL") {
      return "$baseUrl/tx/$hash?cluster=devnet";
    } else if (symbol == "DCX" ||
        (rpcUrl == 'https://mainnetcoin.d-ecosystem.io/' && coinType == '2')) {
      return "$baseUrl/tx/$hash";
    } else if (widget.coinData.coinSymbol == "tXRP" ||
        widget.coinData.coinSymbol == "XRP") {
      print("transsss ${baseUrl}transactions/$hash");
      return "${baseUrl}transactions/$hash";
    } else if (widget.coinData.coinSymbol == "tBTC" ||
        widget.coinData.coinSymbol == "BTC") {
      return "${baseUrl}tx/$hash";
    } else if (widget.coinData.coinSymbol == "tVET" ||
        widget.coinData.coinSymbol == "VET") {
      return "$baseUrl/transactions/$hash#info";
    }
    print("eosssss $baseUrl/tx/$hash");
    return "$baseUrl/tx/$hash";
  }

  String formatBalance(String balance) {
    final parsed = Decimal.parse(balance);
    String formatted = parsed.toString();
    if (formatted.contains('.')) {
      formatted = formatted
          .replaceAll(RegExp(r'0*\$'), '')
          .replaceAll(RegExp(r'\.\$'), '');
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hash = widget.hashModel;
    final coin = widget.coinData;
    final formattedAmount = formatBalance(hash.amount ?? '0');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText("${widget.coinData.coinSymbol} Sent"),
        centerTitle: true,
        leading: BackButton(color: theme.indicatorColor),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: theme.indicatorColor),
            onPressed: () async {
              await Share.share(_buildExplorerUrl());
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(child: Image.asset("assets/Images/send.png")),

          Center(
            child: AppText(
              "-$formattedAmount ${coin.coinSymbol}",
              fontSize: 20,
              color: theme.colorScheme.surfaceBright,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            children: [
              _buildInfoRow(
                "Date",
                CommonCalculationFunctions.formatDateTimeGMTIndia(
                  DateTime.fromMillisecondsSinceEpoch(hash.time!).toString(),
                ),
              ),
              _buildInfoRow(
                "Status",
                widget.transactiondata == null
                    ? "Completed"
                    : widget.transactiondata!.blockNumber.isPending
                    ? "Pending"
                    : "Completed",
                color: widget.transactiondata == null
                    ? theme.colorScheme.surfaceBright
                    : widget.transactiondata!.blockNumber.isPending
                    ? Colors.orangeAccent
                    : Colors.green,
              ),
              _buildInfoRow(
                "Recipient",
                CommonCalculationFunctions.maskWalletAddress(
                  hash.toAddress.toString(),
                ),
              ),
            ],
          ),
          if (widget.transactiondata != null)
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  "Network fee",
                  transactionReceipt == null
                      ? ""
                      : "${hexBytes.etherWeiToValue(transactionReceipt!.gasUsed! * widget.transactiondata!.gasPrice.getInWei).toStringAsFixed(8)} ${coin.coinSymbol == 'tBNB' ? 'tBNB' : coin.gasPriceSymbol}",
                ),
                _buildInfoRow("Confirmation", "-"),
                _buildInfoRow("Nonce", "${widget.transactiondata!.nonce}"),
              ],
            ),
          GestureDetector(
            onTap: _handleTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: AppText(
                  "View on block explorer",
                  color: theme.colorScheme.surfaceBright,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0XFF131720),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? color}) {
    final isStatusRow = title == "Status";
    final isNetworkFee = title == "Network fee";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isNetworkFee
              ? Row(
                  children: [
                    AppText(title, color: Theme.of(context).indicatorColor),
                    SizedBox(width: 5),
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                  ],
                )
              : AppText(title, color: Theme.of(context).indicatorColor),

          // ✅ For Status row — use colored container
          isStatusRow
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: value == "Completed"
                        ? Color(0XFF003309)
                        : Color(0XFF331e00),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: AppText(
                    value,
                    color: value == "Completed"
                        ? Color(0XFF8cffb0)
                        : Color(0XFFffca7f),
                    fontWeight: FontWeight.w500,
                  ),
                )
              : AppText(
                  value,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Theme.of(context).colorScheme.surfaceBright,
                ),
        ],
      ),
    );
  }
}
