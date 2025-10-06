import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_processor.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeEntryView.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';

class ConfirmTransactionPage extends StatefulWidget {
  final AssetModel coinData;
  final String fromAddress;
  final String toAddress;
  final String estimatedGas;
  final String amount;
  final UserWalletDataModel userWallet;

  const ConfirmTransactionPage({
    Key? key,
    required this.toAddress,
    required this.estimatedGas,
    required this.coinData,
    required this.amount,
    required this.fromAddress,
    required this.userWallet,
  }) : super(key: key);

  @override
  State<ConfirmTransactionPage> createState() => _ConfirmTransactionPageState();
}

class _ConfirmTransactionPageState extends State<ConfirmTransactionPage> {
  String? privateKey;
  String networkSymbol = '';
  AsyncSnapshot<List<String>>? snapshotData;

  String maskEthAddress(
    String address, {
    int prefixLength = 10,
    int suffixLength = 10,
    String maskChar = '*',
  }) {
    if (address.length < prefixLength + suffixLength) {
      throw ArgumentError(
        'Address length is shorter than prefixLength + suffixLength',
      );
    }

    String prefix = address.substring(0, prefixLength);
    String suffix = address.substring(address.length - suffixLength);
    String masked = prefix + "..." + suffix;

    return masked;
  }

  Future<void> fetchNetworkSymbol() async {
    String rpcUrl = widget.coinData.rpcURL!;
    final client = Web3Client(rpcUrl, Client());

    try {
      final networkId = await client.getNetworkId();

      switch (networkId) {
        case 1:
          networkSymbol = 'ETH'; // Mainnet Ethereum
          break;
        case 5272:
          networkSymbol = 'DCX'; // Ropsten Testnet
          break;
        case 56:
          networkSymbol = 'BNB'; // Binance Smart Chain Mainnet
          break;
        // Add more cases as needed
        default:
          networkSymbol = 'Unknown';
      }
    } catch (e) {
      // print('Error fetching network ID: $e');
      networkSymbol = 'Unknown';
    } finally {
      client.dispose();
    }

    setState(() {}); // Update the UI with the new symbol
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.coinData.coinType == '2') {
      fetchNetworkSymbol();
    }
    privateKey = widget.userWallet.privateKey;

    print('....${privateKey}');
  }

  String formatBalance(String balance) {
    // Convert the balance string to a Decimal
    Decimal parsedBalance = Decimal.parse(balance);

    // Format the Decimal to a string without losing precision
    String formattedBalance = parsedBalance.toString();
    // print('formattedBalance:::::::::::::::$formattedBalance');
    // Remove unnecessary trailing zeros after the decimal point
    if (formattedBalance.contains('.')) {
      formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
      if (formattedBalance.endsWith('.')) {
        formattedBalance = formattedBalance.substring(
          0,
          formattedBalance.length - 1,
        );
      }
    }

    return formattedBalance;
  }

  bool isLoading = false;

  LocalStorageService localStorageService = LocalStorageService();
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      backgroundColor: Color(0XFF131720),
      appBar: AppBar(
        backgroundColor: Color(0XFF131720),
        centerTitle: true,
        title: AppText(
          "Confirm Send",
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).indicatorColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0XFF191e2a),
                borderRadius: BorderRadius.circular(20),
              ),

              width: SizeConfig.width(context, 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(
                            widget.coinData.imageUrl! ?? "",
                            height: 40,
                            width: 40,
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                "${formatBalance(widget.amount)}",
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              AppText(
                                "${widget.coinData.coinSymbol}",
                                color: Color(0XFF858585),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: SizeConfig.height(context, 2)),
            Container(
              decoration: BoxDecoration(
                color: Color(0XFF191e2a),
                borderRadius: BorderRadius.circular(20),
              ),
              height: SizeConfig.height(context, 20),
              width: SizeConfig.width(context, 100),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          "From",
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceBright.withOpacity(0.5),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                              (widget.userWallet.walletName),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            AppText(
                              maskEthAddress(widget.fromAddress),
                              fontSize: 14,
                              color: Color(0XFF858585),
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          "To",
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceBright.withOpacity(0.5),
                        ),
                        AppText(maskEthAddress(widget.toAddress), fontSize: 14),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          "Network",
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceBright.withOpacity(0.5),
                        ),
                        AppText(widget.coinData.coinName!, fontSize: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: SizeConfig.height(context, 2)),
            widget.coinData.rpcURL == ""
                ? Container(
                    decoration: BoxDecoration(
                      color: Color(0XFF191e2a),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    width: SizeConfig.width(context, 100),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Row(
                              children: [
                                GradientAppText(
                                  text: "Pay this fee with FlexGas",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    "Estimated Fee",
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright
                                        .withOpacity(0.5),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.info_outline, color: Colors.white),
                                ],
                              ),
                              AppText(
                                "${widget.estimatedGas.length > 9 ? widget.estimatedGas.substring(0, 9) : widget.estimatedGas} ${widget.coinData.gasPriceSymbol}",
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Color(0XFF191e2a),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    width: SizeConfig.width(context, 100),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Row(
                              children: [
                                GradientAppText(
                                  text: "Pay this fee with FlexGas",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    "Estimated Fee",
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright
                                        .withOpacity(0.5),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.info_outline, color: Colors.white),
                                ],
                              ),
                              AppText(
                                "${widget.estimatedGas.length > 10 ? widget.estimatedGas.substring(0, widget.estimatedGas.length > 12 ? 12 : widget.estimatedGas.length) : widget.estimatedGas} ${widget.coinData.coinSymbol == 'tBNB'
                                    ? 'tBNB'
                                    : widget.coinData.coinSymbol == 'MATIC'
                                    ? "Polygon"
                                    : widget.coinData.gasPriceSymbol}",
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            Expanded(child: SizedBox()),
            Container(
              decoration: BoxDecoration(
                color: Color(0XFF191e2a),
                borderRadius: BorderRadius.circular(20),
              ),

              width: SizeConfig.width(context, 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText("Total Cost", color: Color(0XFF858585)),
SizedBox(width: 10,),
                      Expanded(
                        child: AppText(
                          "${formatBalance(widget.amount) + widget.estimatedGas}",
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: Platform.isIOS ? 16 : 8),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.purpleAccent[100],
                      ),
                    )
                  : ReuseElevatedButton(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });

                        final prefs = await SharedPreferences.getInstance();
                        final savedPasscode = prefs.getString('passcode');
                        setState(() {
                          isLoading = false;
                        });
                        // Wait for the result from EnterPasscodeScreen
                        final bool isPasscodeConfirmed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasscodeEntryView(
                              savedPasscode: savedPasscode!,
                              click: 'send1',
                              data: localStorageService.activeWalletData!,
                            ),
                          ),
                        );
                        setState(() {
                          isLoading = true;
                        });
                        if (isPasscodeConfirmed) {
                          String fromAddress =
                              'nh8wSaGhwhBhFqMfiKsP2kPDs4jvwufD32';
                          String toAddress =
                              'nh8wSaGhwhBhFqMfiKsP2kPDs4jvwufD32';
                          double amount = 10.0; // Amount in DOGE
                          String privateKey =
                              'd8d92705abebaaba58248a549ed2bd73e22aa393f16e9f3e8ef27c52ce6a2b43';

                          transactionProcessor.processTransaction(
                            context,
                            coinData: widget.coinData,
                            enterAmount: widget.amount,
                            userWallet: widget.userWallet,
                            toAddress: widget.toAddress,
                            privateKeyHex: widget.userWallet.privateKey,
                            contractAddress: widget.coinData.tokenAddress!,
                            rpcUrl: widget.coinData.coinSymbol == 'TRX'
                                ? 'https://api.trongrid.io'
                                : 'https://nile.trongrid.io',
                          );

                          setState(() {
                            isLoading = true;
                          });
                        } else {
                          // Handle incorrect passcode or cancellation
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },

                      /*                    onTap: () async {

                        setState(() {
                          isLoading = true;
                        });
                        final prefs = await SharedPreferences.getInstance();

                        final savedPasscode = prefs.getString('passcode');

                        // Wait for the result from EnterPasscodeScreen
                        final bool isPasscodeConfirmed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnterPasscodeScreen(
                              savedPasscode!,
                              'send1',
                              fetchLocalDataVM.walletDataList[0],
                            ),
                          ),
                        );

                        if (isPasscodeConfirmed) {
                          print("Passcode confirmed, processing transaction...");

                        } else {
                          // Handle incorrect passcode or cancellation
                          setState(() {
                            isLoading = false;
                          });
                        }
                        // coinTransaction.processTransaction(context,
                        //     coinData: widget.coinData,
                        //     enterAmount: widget.amount,
                        //     userWallet: widget.userWallet,
                        //     toAddress: widget.toAddress);
                      },*/
                      height: 45,
                      width: MediaQuery.sizeOf(context).width,
                      text: "Confirm",
                      textcolor: Colors.black,
                      gradientColors: [],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// / ImageConstant.imgSearchGray70002
