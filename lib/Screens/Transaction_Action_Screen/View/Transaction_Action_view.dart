import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
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
import 'package:securywallet/Screens/HomeScreen/Controllers/home_controller.dart';
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

  const TransactionAction({
    super.key,
    required this.coinData,
    required this.balance,
    required this.userWallet,
    required this.usdPrice,
  });

  @override
  State<TransactionAction> createState() => _TransactionActionState();
}

class _TransactionActionState extends State<TransactionAction> {
  GetHashStorage getHashStorage = GetHashStorage();

  List<HashModel> hashList = [];
  int _selectedIndex = 0;

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
      final TransactionInformation? transaction = await client
          .getTransactionByHash(hash);
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
      formattedBalance = formattedBalance.substring(
        0,
        formattedBalance.length - 1,
      );
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
            child: Icon(
              Icons.arrow_back,
              color:Colors.white,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            children: [
              AppText(
                widget.coinData.coinSymbol!,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    widget.coinData.coinType == '2' ? 'TOKEN' : 'COIN',
                    color: Theme.of(context).indicatorColor,
                    fontSize: 12,
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    color: Theme.of(context).indicatorColor.withOpacity(0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                  ),

                  AppText(
                    widget.coinData.network!,
                    color: Theme.of(context).indicatorColor,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0XFF131720),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Watch',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          )
        ],
      ),
      body:
      Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // Gradient only visible in the top-left area
                            gradient: const LinearGradient(
                              colors: [Color(0xFF08204E), Color(0xFF0D0D0D)],
                              begin: Alignment.topLeft,
                              end: Alignment(0.5, 0.5), // Limits gradient spread (only covers top-left)
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset("assets/Images/key.png"),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      ' ${widget.coinData.coinSymbol!} fees may increase during network\ncongestion. '
                                          'Secury Wallet gains no\nbenefit. Tap the gas icon below to view\nestimated costs.',

                                      color: Colors.white54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,


                                    ),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Color(0XFF3d3c40))),
                                      child: const Icon(Icons.close, color: Colors.white60, size: 18)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {},
                                  child:  AppText(
                                    'Learn more',
                                    color: Color(0xFFAF77F8),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,

                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        AppText(
                          "\$${(widget.usdPrice * double.parse(widget.balance)).toStringAsFixed(3)}",
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),

                        AppText(
                          "\$2.09 (2.5%)",
                          color: Color(0XFF8CFFB0),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,

                        ),
                        Image.asset("assets/Images/chart1.png"),
                        SizedBox(height: 20,),

                        Row(
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
                                  child: AppText(
                                    "Holdings",

                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedIndex == 0
                                          ? Colors.black
                                          : Colors.white.withOpacity(0.7),

                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
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
                                  child: AppText(
                                    "History",

                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedIndex == 1
                                          ? Colors.black
                                          : Colors.white.withOpacity(0.7),

                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 2;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: _selectedIndex == 2
                                      ? Colors.white
                                      : Colors.transparent,
                                  border: _selectedIndex == 2
                                      ? null
                                      : Border.all(color: Color(0XFF444444)),
                                ),
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: AppText(
                                    "About",

                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedIndex == 2
                                          ? Colors.black
                                          : Colors.white.withOpacity(0.7),

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: SizeConfig.height(context, 50),
                          child: _selectedIndex == 0 ? Holdings() : _selectedIndex == 1?History(): About(),
                        ),



                        // Padding(
                        //   padding: const EdgeInsets.only(top: 16.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       AppText("${widget.coinData.coinSymbol!} Balance : "),
                        //       AppText(
                        //         "${formatBalance(widget.balance)} ",
                        //         color: Theme.of(context).colorScheme.surfaceBright,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 20,
                        //       ),
                        //       AppText(
                        //         "(\$${(widget.usdPrice * double.parse(widget.balance)).toStringAsFixed(3)})",
                        //         color: Theme.of(context).indicatorColor,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 20),

                      ],
                    ),
                  ),


                  SizedBox(height: SizeConfig.height(context, 10)),

                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0XFF151A23), // translucent glass tint
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2), width: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, -2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: transactionActionRow(context),
                ),
              ),
            )

          ),

        ],
      )


    );

  }

  Widget Holdings(){
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0,bottom: 8),
              child: AppText("My Balance",color: Color(0XFf858585),fontSize: 15,fontWeight: FontWeight.w500,),
            ),
          ],
        ),

        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),color: Color(0XFF191E2A)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                      ),
                    ),
                    SizedBox(width: 6,),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("${widget.coinData.coinName!}"),
                        AppText(
                          "${formatBalance(widget.balance)}${widget.coinData.coinSymbol} ",
                          color: Color(0XFF858585),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ],
                    )
                  ],
                ),Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(  "\$${(widget.usdPrice * double.parse(widget.balance)).toStringAsFixed(2)}",),
                    AppText("-",color: Color(0XFF858585),)
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );

  }

  Widget History(){
    return  Column(
 
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              "Recent Transactions",
              color: Theme.of(context).indicatorColor,
            ),
          ),
        ),
        hashList.isEmpty
            ? Column(
              children: [
                Image.asset("assets/Images/recent.png"),
                AppText("No recent transactions",fontSize: 24,color: Colors.white,fontWeight: FontWeight.w600,),
                AppText("Transactions will appear here",color: Color(0XFFB4B1B2),fontSize: 13,fontWeight: FontWeight.w400,)
              ],
            )
            : SizedBox(
          height: SizeConfig.height(
            context,
            hashList.length * 8,
          ),
          // width: AppSize.width(context, 90),
          child: ListView.builder(
            itemCount: hashList.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              String hash = hashList[index].hash!;
              String? amount = hashList[index]
                  .amount; // amount is of type String?
              String formattedAmount = formatBalance(
                amount ?? '0.0',
              );
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
                      Tuple2<
                          TransactionInformation?,
                          TransactionReceipt?
                      >?
                      data =
                      await getTokenTransactionList(
                        hash,
                        widget.coinData.rpcURL!,
                      );
                      transaction = data.item1!;
                    }
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TransactionReceiptPage(
                              transactiondata:
                              transaction,
                              coinData: widget.coinData,
                              userWallet:
                              widget.userWallet,
                              hashModel: hashList[index],
                            );
                          },
                        ),
                      ).then((v) {
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceBright,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceBright,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: SizeConfig.height(context, 5)),
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
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Transaction not found? ',
                        style: TextStyle(color: Colors.white70),
                        children: const <TextSpan>[
                          TextSpan(
                            text: 'Check the explorer.',
                            style: TextStyle(
                              color: Color(
                                0xFFB982FF,
                              ), // You can change the color as needed
                              // Add any other styles you want for this part of the text
                            ),
                            // Add any other properties you want for this part of the text
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

  }

  Widget About(){
    return Column(
      children: [
       Padding(
         padding: const EdgeInsets.only(top: 16.0,bottom: 8),
         child: Row(
           children: [
             AppText("Overview",color: Color(0XFFB4B1B2),fontSize: 16,fontWeight: FontWeight.w700,)
           ],
         ),
       ),
        AppText("Bitcoin is a decentralized digital currency that allows\npeer-to-peer transactions on a borderless network.\nLaunched as the world's first cryptocurrency, it\nsparked the blockchain revolution and is often\ncalled \"digital gold\" for its fixed supply and\ndecentralized nature.",
        fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0XFF858585),
        )
      ],
    );

  }


  Widget transactionActionRow(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => SendCryptoPage(
                      assetData: widget.coinData,
                      walletData: widget.userWallet,
                      balance: widget.balance,
                      ethAddress: "",
                    ),
                  ),
                );
              },
              child: // Required for ImageFilter
              Image.asset(
                "assets/Images/sendicon.png",
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
          onTap: () {
            // FocusScope.of(context).unfocus();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (builder) =>
                    ReceiveCrypto(coinData: widget.coinData),
              ),
            );
          },
          child: Column(
            children: [
              Image.asset(
                "assets/Images/receiveicon.png",
              ),

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
              Image.asset(
                "assets/Images/dollaricon.png",
              ),


              SizedBox(height: SizeConfig.height(context, 0.5)),
              AppText(
                "Swap",
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
              Image.asset(
                "assets/Images/fundicon.png",
              ),

              SizedBox(height: SizeConfig.height(context, 0.5)),
              AppText(
                "Buy",
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.surfaceBright,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProcessingDialogBottom extends StatelessWidget {
  const ProcessingDialogBottom({super.key});

  @override
  Widget build(BuildContext context) {
    List<HashModel> hashList = [];
    List<AssetModel> coinData = [];
    List<UserWalletDataModel> userWallet = [];
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.03),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  // Hourglass Image
                  Image.asset(
                    'assets/Images/procress.png',
                    height: 280,

                    // 👈 replace with your neon hourglass image
                  ),

                  const SizedBox(height: 20),

                  // Title
                  AppText(
                    "Processing",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Transaction in progress! Blockchain validation is underway. "
                    "This may take a few minutes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
 Widget _tabButton(String text, bool active) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
decoration: BoxDecoration(
color: active ? Colors.white : const Color(0xFF131720),
borderRadius: BorderRadius.circular(20),
),
child: Text(
text,
style: TextStyle(
color: active ? Colors.black : Colors.white, fontSize: 13),
),
);
}