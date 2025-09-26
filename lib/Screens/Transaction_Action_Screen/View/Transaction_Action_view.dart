import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Hash_Model.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Store_Hash.dart';
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Constant_Image.dart';
import 'package:securywallet/Crypto_Utils/Launch_Explorer_Url/LaunchExplorerUrl.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Crypto_Transactions/ReceiveCryptoPage.dart';
import 'package:securywallet/Screens/Crypto_Transactions/SendCryptoPage.dart';
import 'package:securywallet/Screens/Crypto_Transactions/TransactionReceipt/TransactionReceipt.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:tuple/tuple.dart';
import 'package:web3dart/web3dart.dart';

class TransactionAction extends StatefulWidget {
  final AssetModel coinData;
  final String balance;
  final UserWalletDataModel userWallet;
  final double usdPrice;
  const TransactionAction(
      {super.key,
      required this.coinData,
      required this.balance,
      required this.userWallet,
      required this.usdPrice});

  @override
  State<TransactionAction> createState() => _TransactionActionState();
}

class _TransactionActionState extends State<TransactionAction> {
  GetHashStorage getHashStorage = GetHashStorage();

  List<HashModel> hashList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _initializeHashList();
    });
  }

  void _initializeHashList() {
    final isCoinType3 = widget.coinData.coinType == "3";
    final isCoinType2WithNoRpc =
        widget.coinData.coinType == "2" && widget.coinData.rpcURL == "";

    final String key = isCoinType3 || isCoinType2WithNoRpc
        ? "${widget.coinData.address}${widget.coinData.coinType}${widget.coinData.coinType == "2" ? widget.coinData.tokenAddress : ""}${widget.coinData.coinSymbol}${widget.coinData.coinName}"
        : "${widget.userWallet.walletAddress}${widget.coinData.coinType}${widget.coinData.coinType == "2" ? widget.coinData.tokenAddress : ""}${widget.coinData.coinSymbol}${widget.coinData.coinName}";

    hashList = getHashStorage.getHashList(key);
    hashList.sort((a, b) => b.time!.compareTo(a.time!));
  }
  bool isLoading = true;


  Future<Tuple2<TransactionInformation?, TransactionReceipt?>>
      getTokenTransactionList(String hash, String rpcUrl) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      final TransactionInformation? transaction =
          await client.getTransactionByHash(hash);
      if (transaction == null) {
        return Tuple2(null, null);
      }

      final receipt = await client.getTransactionReceipt(hash);
      if (receipt == null || receipt.logs.isEmpty) {
        return Tuple2(transaction, null);
      }

      // Return both the transaction and its receipt
      return Tuple2(transaction, receipt);
    } on FormatException catch (e) {
      print("Format exception occurred: $e");
      print("Failed to parse BigInt from hexadecimal string: ${e.source}");
      return Tuple2(null, null);
    } on Exception catch (e) {
      print("Exception occurred: $e");
      return Tuple2(null, null);
    }
  }

  String formatBalance(String balance) {
    double parsedBalance = double.tryParse(balance) ?? 0.0;

    String formattedBalance = parsedBalance.toStringAsFixed(8);

    formattedBalance = formattedBalance.replaceAll(RegExp(r'0+$'), '');

    if (formattedBalance.endsWith('.')) {
      formattedBalance =
          formattedBalance.substring(0, formattedBalance.length - 1);
    }

    return formattedBalance;
  }

  bool tapped = false;

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).indicatorColor),
            )),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    widget.coinData.coinSymbol!,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).primaryColorLight),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: AppText(
                          widget.coinData.coinType == '2' ? 'Token' : 'Coin',
                          color: Theme.of(context).colorScheme.surfaceBright,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              AppText(
                widget.coinData.network!,
                color: Theme.of(context).indicatorColor,
                fontSize: 12,
              )
            ],
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF202832),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            widget.coinData.imageUrl!,
                            errorBuilder: (_, obj, trc) {
                              return AppText(
                                widget.coinData.coinSymbol
                                    .toString()
                                    .characters
                                    .first,
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              );
                            },
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                              "${widget.coinData.coinSymbol!} Balance : "),
                          AppText(
                            "${formatBalance(widget.balance)} ",
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          AppText(
                            "(\$${(widget.usdPrice * double.parse(widget.balance)).toStringAsFixed(3)})",
                            color: Theme.of(context).indicatorColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8, top: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => SendCryptoPage(
                                        assetData: widget.coinData,
                                        walletData: widget.userWallet,
                                        balance: widget.balance,
                                        ethAddress: "",
                                      )));
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 18.0,
                                        right: 18.0,
                                        top: 10,
                                        bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AppText(
                                          "Send",
                                          fontFamily: 'LexendDeca',
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                          fontSize: 14,
                                        ),
                                        Transform.rotate(
                                          angle: 45 *
                                              (3.141592653589793 /
                                                  180), // Convert degrees to radians
                                          child: SvgPicture.asset(
                                            ConstantImage
                                                .imgArrowRightLightBlueA200,
                                            color: Color(0xFFB982FF),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => ReceiveCrypto(
                                        coinData: widget.coinData,
                                      )));
                            },
                            child: Container(
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white24,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 18.0,
                                    right: 18.0,
                                    top: 10,
                                    bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AppText(
                                      "Receive",
                                      fontFamily: 'LexendDeca',
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright,
                                      fontSize: 14,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    SvgPicture.asset(
                                      ConstantImage.imgPrinter,
                                      semanticsLabel: 'Acme Logo',
                                      color: Color(0XFFB982FF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.5,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        "Recent Transactions",
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                  ),
                  hashList.isEmpty
                      ? SizedBox()
                      : SizedBox(
                          height:
                              SizeConfig.height(context, hashList.length * 8),
                          // width: AppSize.width(context, 90),
                          child: ListView.builder(
                            itemCount: hashList.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              String hash = hashList[index].hash!;
                              String? amount = hashList[index]
                                  .amount; // amount is of type String?
                              String formattedAmount =
                                  formatBalance(amount ?? '0.0');
                              return Opacity(
                                opacity: tapped ? 0.4 : 1,
                                child: ListTile(
                                  onTap: tapped
                                      ? null
                                      : () async {
                                          setState(() {
                                            tapped = true;
                                          });
                                          TransactionInformation? transaction;
                                          if (widget.coinData.coinType != "3" &&
                                              widget.coinData.rpcURL != "") {
                                            Tuple2<TransactionInformation?,
                                                    TransactionReceipt?>? data =
                                                await getTokenTransactionList(
                                                    hash,
                                                    widget.coinData.rpcURL!);
                                            transaction = data.item1!;
                                          }
                                          if (mounted) {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return TransactionReceiptPage(
                                                transactiondata: transaction,
                                                coinData: widget.coinData,
                                                userWallet: widget.userWallet,
                                                hashModel: hashList[index],
                                              );
                                            })).then((v) {
                                              setState(() {
                                                tapped = false;
                                              });
                                            });
                                          }
                                        },
                                  leading: CircleAvatar(
                                    child: Icon(
                                      Icons.arrow_forward_sharp,
                                      color: Color(0xFFB982FF),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).primaryColorLight ??
                                            Color(0xFFD4D4D4),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        "Transfer",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                      ),
                                      AppText(
                                        "To: ${CommonCalculationFunctions.maskWalletAddress(hashList[index].toAddress.toString())}",
                                        color: Theme.of(context).indicatorColor,
                                        fontSize: 13,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "-$formattedAmount ${widget.coinData.coinSymbol}",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
                  SizedBox(
                    height: SizeConfig.height(context, 5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, right: 26),
                    child: GestureDetector(
                      onTap: () async {
                        await launchExplorer.launchExplorerAddressURL(
                          coin: widget.coinData,
                          walletAddress: widget.userWallet.walletAddress,
                        );
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white30,
                          ),
                          child: Center(
                              child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Transaction not found? ',
                                  style: TextStyle(color: Colors.white70),
                                  children: const <TextSpan>[
                                    TextSpan(
                                      text: 'Check the explorer.',
                                      style: TextStyle(
                                        color: Color(
                                            0xFFB982FF), // You can change the color as needed
                                        // Add any other styles you want for this part of the text
                                      ),
                                      // Add any other properties you want for this part of the text
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.height(context, 10),
              ),
              Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Colors.white30,
                    ),
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
