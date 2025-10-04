import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalanceFunction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/Hex_Bytes.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/sol_transaction.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Store_Hash.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/QRView/QRView_Android.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Crypto_Transactions/Services/Balance_Formatter.dart';
import 'package:securywallet/Screens/Crypto_Transactions/Services/Crypto_validator.dart';
import 'package:securywallet/Screens/Crypto_Transactions/confirmTransactionPage/View/confirmTransactionPage_View.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:web3dart/web3dart.dart';

class SendCryptoPage extends StatefulWidget {
  final AssetModel assetData;
  final UserWalletDataModel walletData;
  String balance;
  String? ethAddress;

  SendCryptoPage({
    super.key,
    this.ethAddress,
    required this.assetData,
    required this.walletData,
    required this.balance,
  });

  @override
  State<SendCryptoPage> createState() => _SendCryptoPageState();
}

class _SendCryptoPageState extends State<SendCryptoPage> {
  TextEditingController addressCtrl = TextEditingController();
  TextEditingController amountCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? privateKey;

  GetHashStorage getHashStorage = GetHashStorage();

  double? solGas, tronGas, tronEnergy, xrpGas, btcGas;

  Future<String>? gasFeeFunction;

  bool isMaxClicked = false;
  bool isLoading = false;

  late Web3Client client;

  Future<num> fetchBitcoinFee() async {
    String blockCypherApi = widget.assetData.coinSymbol == "BTC"
        ? 'https://api.blockcypher.com/v1/btc/main'
        : 'https://api.blockcypher.com/v1/btc/test3';

    try {
      // Fetch fee rates from the BlockCypher API
      final response = await http.get(Uri.parse(blockCypherApi));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract fee rates in satoshis per kilobyte
        num highFeePerKb = data['high_fee_per_kb'];
        num mediumFeePerKb = data['medium_fee_per_kb'];
        num lowFeePerKb = data['low_fee_per_kb'];

        // Calculate transaction size (in bytes)
        int transactionSize = (2 * 68) + (2 * 31) + 10;

        // Convert fees to satoshis per byte
        double highFeePerByte = highFeePerKb / 1000;
        double mediumFeePerByte = mediumFeePerKb / 1000;
        double lowFeePerByte = lowFeePerKb / 1000;

        // Calculate total fees in BTC
        double highFeeBTC = (highFeePerByte * transactionSize) / 1e8;
        double mediumFeeBTC = (mediumFeePerByte * transactionSize) / 1e8;
        double lowFeeBTC = (lowFeePerByte * transactionSize) / 1e8;

        btcGas = (lowFeePerKb / 1e8).toDouble();

        print("BTC NETWORK FEE::${(lowFeePerKb / 1e8)}");

        return lowFeeBTC;
      } else {
        throw Exception('Failed to fetch fee rates from BlockCypher API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> tronTnxEstimateFee({
    required String fromAddress,
    required String toAddress,
    required int amountInSun, // Amount in sun (1 TRX = 1,000,000 sun)
  }) async {
    final url = 'https://api.trongrid.io/v1/accounts/$fromAddress';

    try {
      // Fetch account details
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('API Response TRON: $data');

        // Check if 'data' and expected keys are present
        if (data.containsKey('data') &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          final accountData =
              data['data'][0]; // Adjust based on the actual response structure

          // Extract bandwidth and energy information
          final bandwidth = accountData['freeNetUsed'] ?? 0;
          final energy = accountData['freeEnergyUsed'] ?? 0;

          // Example costs per unit
          final bandwidthCost = 0.1; // Replace with actual cost
          final energyCost = 0.2; // Replace with actual cost

          // Calculate total fee
          final totalFee = (bandwidth * bandwidthCost) + (energy * energyCost);

          // Convert fee to TRX
          final feeInTrx = totalFee / 1000000; // Convert sun to TRX
          // print('Estimated Fee in TRX: $feeInTrx');

          return feeInTrx;
        } else {
          throw Exception('Invalid response structure or empty data');
        }
      } else {
        throw Exception(
          'Failed to fetch account data, Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to estimate transaction fee');
    }
  }

  Future<double> fetchXrpTnxFee() async {
    final url = 'https://s1.ripple.com:51234';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"method": "server_info"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('API Response XRP: $data');

        if (data.containsKey('result') && data['result'].containsKey('info')) {
          final info = data['result']['info'];

          // Extract the current fee in drops
          final fee = info['validated_ledger']['base_fee_xrp'];

          // Convert fee to XRP
          final feeInXrp =
              fee; // No conversion needed since the API returns the fee in XRP directly
          // print('Estimated Fee in XRP: ${feeInXrp.toStringAsFixed(18)}');

          xrpGas = feeInXrp;

          print("feeInXrp :$feeInXrp");
          return feeInXrp;
        } else {
          throw Exception('Invalid response structure or empty data');
        }
      } else {
        throw Exception(
          'Failed to fetch server info, Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to estimate transaction fee');
    }
  }

  Future<num> fetchTrxBandwidth() async {
    final String url = widget.assetData.gasPriceSymbol == "TRX"
        ? "https://apilist.tronscanapi.com/api/accountv2?address=${widget.assetData.address}"
        : "https://nileapi.tronscan.org/api/accountv2?address=${widget.assetData.address}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final num freeNetRemaining = data['bandwidth']['freeNetRemaining'];
        final num netRemaining = data['bandwidth']['netRemaining'];
        return (freeNetRemaining + netRemaining) / 1000;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<num> fetchTrxEnergy() async {
    final String url = widget.assetData.gasPriceSymbol == "TRX"
        ? "https://apilist.tronscanapi.com/api/accountv2?address=${widget.assetData.address}"
        : "https://nileapi.tronscan.org/api/accountv2?address=${widget.assetData.address}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final num energyRemaining = data['bandwidth']['energyRemaining'];
        return energyRemaining;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("${widget.walletData.walletAddress}");
    if (widget.assetData.coinSymbol!.toUpperCase().contains("BTC")) {
      fetchBitcoinFee();
    }
    if (widget.ethAddress != null && widget.ethAddress!.contains("0x")) {
      Future.delayed(Duration(), () async {
        var bal = await assetBalanceFunction.ethBalance(
          widget.assetData,
          localStorageService.activeWalletData!.privateKey,
        );
        setState(() {
          widget.balance = bal;
        });
      });
    }
    fetchXrpTnxFee();
    privateKey = widget.walletData.privateKey;
    String rpcUrl = widget.assetData.rpcURL!;
    client = Web3Client(rpcUrl, http.Client());
    addressCtrl.text = widget.ethAddress! ?? "";

    if (widget.assetData.coinType == "2") {
      setState(() {
        gasFeeFunction =
            widget.assetData.gasPriceSymbol!.toUpperCase().contains("SOL")
            ? assetBalanceFunction.getSolBalance(
                widget.assetData,
                widget.walletData,
              )
            : widget.assetData.gasPriceSymbol == "TRX"
            ? assetBalanceFunction.getTrxBalance(widget.assetData.address!)
            : widget.assetData.gasPriceSymbol == "tTRX"
            ? assetBalanceFunction.trxTestnetBalance(widget.assetData.address!)
            : assetBalanceFunction.ethBalance(
                widget.assetData,
                widget.walletData.privateKey,
              );
      });
    }
    if (widget.ethAddress == null) {
    } else if (widget.ethAddress != null && widget.ethAddress!.contains(":")) {
      var addres = widget.ethAddress!.split(":").last;
      addres = addres.split("?").first;
      setState(() {
        addressCtrl.text = addres;
        if (widget.ethAddress!.contains("?amount=")) {
          amountCtrl.text = widget.ethAddress!.split("amount=").last;
        }
      });
    } else {
      setState(() {
        addressCtrl.text = widget.ethAddress ?? "";
      });
    }
  }

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
          "Send ${widget.assetData.coinSymbol}",
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).indicatorColor,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                    child: AppText(
                      "Address or Domain name",
                      fontSize: 15,
                      color: Color(0XFF858585),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: TextFormField(
                          controller: addressCtrl,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            print(widget.assetData.toJson());
                            if (v!.isEmpty) {
                              return "Please enter ${widget.assetData.coinSymbol} address";
                            } else if (!isValidCryptoAddress(
                              v,
                              widget.assetData.gasPriceSymbol.toString(),
                            )) {
                              return "Please enter valid ${widget.assetData.coinSymbol} address";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    ClipboardData? data =
                                        await Clipboard.getData(
                                          Clipboard.kTextPlain,
                                        );
                                    if (data != null) {
                                      setState(() {
                                        addressCtrl.text = data.text ?? '';
                                      });
                                    }
                                  },
                                  child: AppText(
                                    "Paste",
                                    fontSize: 14,
                                    fontFamily: 'LexendDeca',
                                    color: const Color(0xFFaf77f8),
                                  ),
                                ),
                                // IconButton(
                                //   icon: Icon(
                                //     Icons.qr_code,
                                //     color: Theme.of(context).indicatorColor,
                                //   ),
                                //   onPressed: () {
                                //     addressCtrl.clear();
                                //     amountCtrl.clear();
                                //     if (widget.assetData.coinType == "1" ||
                                //         (widget.assetData.coinType == "2" &&
                                //             widget.assetData.rpcURL != "")) {
                                //       FocusScope.of(context).unfocus();
                                //       Future.delayed(
                                //         Duration(milliseconds: 500),
                                //         () {
                                //           Navigator.of(context)
                                //               .push(
                                //                 MaterialPageRoute(
                                //                   builder: (builder) =>
                                //                       QRView(back: true),
                                //                 ),
                                //               )
                                //               .then((value) {
                                //                 if (value == null) {
                                //                 } else if (value != null &&
                                //                     value.contains(":")) {
                                //                   var addres = value
                                //                       .split(":")
                                //                       .last;
                                //                   addres = addres
                                //                       .split("?")
                                //                       .first;
                                //                   setState(() {
                                //                     addressCtrl.text = addres;
                                //                     if (value.contains(
                                //                       "?amount=",
                                //                     )) {
                                //                       amountCtrl.text = value
                                //                           .split("amount=")
                                //                           .last;
                                //                     }
                                //                   });
                                //                 } else {
                                //                   setState(() {
                                //                     addressCtrl.text =
                                //                         value ?? "";
                                //                   });
                                //                 }
                                //               });
                                //         },
                                //       );
                                //     } else {
                                //       FocusScope.of(context).unfocus();
                                //       Future.delayed(
                                //         Duration(milliseconds: 500),
                                //         () {
                                //           Navigator.of(context)
                                //               .push(
                                //                 MaterialPageRoute(
                                //                   builder: (builder) =>
                                //                       QRView(back: true),
                                //                 ),
                                //               )
                                //               .then((value) {
                                //                 if (value != null) {
                                //                   if (value
                                //                       is Map<String, String>) {
                                //                     String rawAddress =
                                //                         value['barcode'] ?? '';
                                //
                                //                     String formattedAddress =
                                //                         rawAddress.contains(':')
                                //                         ? rawAddress
                                //                               .split(':')
                                //                               .last
                                //                               .split('amount')
                                //                               .first
                                //                         : rawAddress
                                //                               .split('amount')
                                //                               .first;
                                //                     String amount =
                                //                         rawAddress.contains(
                                //                           'amount=',
                                //                         )
                                //                         ? rawAddress
                                //                               .split('amount=')
                                //                               .last
                                //                         : value['value'] != null
                                //                         ? value['value']!
                                //                         : '';
                                //
                                //                     if (isValidCryptoAddress(
                                //                       formattedAddress,
                                //                       widget
                                //                           .assetData
                                //                           .gasPriceSymbol!,
                                //                     )) {
                                //                       setState(() {
                                //                         addressCtrl.text =
                                //                             formattedAddress;
                                //                         amountCtrl.text =
                                //                             amount;
                                //                       });
                                //                     } else {}
                                //                   } else if (value != null &&
                                //                       value.contains(":")) {
                                //                     var addres = value
                                //                         .split(":")
                                //                         .last;
                                //                     addres = addres
                                //                         .split("?")
                                //                         .first;
                                //                     setState(() {
                                //                       addressCtrl.text = addres;
                                //                       if (value.contains(
                                //                         "?amount=",
                                //                       )) {
                                //                         amountCtrl.text = value
                                //                             .split("amount=")
                                //                             .last;
                                //                       }
                                //                     });
                                //                   } else if (value is String) {
                                //                     String formattedAddress =
                                //                         value.contains(':')
                                //                         ? value
                                //                               .split(':')
                                //                               .last
                                //                               .split('amount')
                                //                               .first
                                //                         : value
                                //                               .split('amount')
                                //                               .first;
                                //                     String amount =
                                //                         value.contains(
                                //                           'amount=',
                                //                         )
                                //                         ? value
                                //                               .split('amount=')
                                //                               .last
                                //                         : '';
                                //
                                //                     if (isValidCryptoAddress(
                                //                       formattedAddress,
                                //                       widget
                                //                           .assetData
                                //                           .gasPriceSymbol!,
                                //                     )) {
                                //                       setState(() {
                                //                         addressCtrl.text =
                                //                             formattedAddress;
                                //                         amountCtrl.text =
                                //                             amount;
                                //                       });
                                //                     } else {}
                                //                   }
                                //                 } else if (value == null) {
                                //                 } else if (value != null &&
                                //                     value.contains(":")) {
                                //                   var addres = value
                                //                       .split(":")
                                //                       .last;
                                //                   addres = addres
                                //                       .split("?")
                                //                       .first;
                                //                   setState(() {
                                //                     addressCtrl.text = addres;
                                //                     if (value.contains(
                                //                       "?amount=",
                                //                     )) {
                                //                       amountCtrl.text = value
                                //                           .split("amount=")
                                //                           .last;
                                //                     }
                                //                   });
                                //                 } else {
                                //                   setState(() {
                                //                     addressCtrl.text =
                                //                         value ?? "";
                                //                   });
                                //                 }
                                //               });
                                //         },
                                //       );
                                //     }
                                //   },
                                // ),
                              ],
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(
                                  0.3,
                                ), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0XFFaf77f8), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Enter Address',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent, // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          addressCtrl.clear();
                          amountCtrl.clear();
                          if (widget.assetData.coinType == "1" ||
                              (widget.assetData.coinType == "2" &&
                                  widget.assetData.rpcURL != "")) {
                            FocusScope.of(context).unfocus();
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (builder) => QRView(back: true),
                                    ),
                                  )
                                  .then((value) {
                                    if (value == null) {
                                    } else if (value != null &&
                                        value.contains(":")) {
                                      var addres = value.split(":").last;
                                      addres = addres.split("?").first;
                                      setState(() {
                                        addressCtrl.text = addres;
                                        if (value.contains("?amount=")) {
                                          amountCtrl.text = value
                                              .split("amount=")
                                              .last;
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        addressCtrl.text = value ?? "";
                                      });
                                    }
                                  });
                            });
                          } else {
                            FocusScope.of(context).unfocus();
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (builder) => QRView(back: true),
                                    ),
                                  )
                                  .then((value) {
                                    if (value != null) {
                                      if (value is Map<String, String>) {
                                        String rawAddress =
                                            value['barcode'] ?? '';

                                        String formattedAddress =
                                            rawAddress.contains(':')
                                            ? rawAddress
                                                  .split(':')
                                                  .last
                                                  .split('amount')
                                                  .first
                                            : rawAddress.split('amount').first;
                                        String amount =
                                            rawAddress.contains('amount=')
                                            ? rawAddress.split('amount=').last
                                            : value['value'] != null
                                            ? value['value']!
                                            : '';

                                        if (isValidCryptoAddress(
                                          formattedAddress,
                                          widget.assetData.gasPriceSymbol!,
                                        )) {
                                          setState(() {
                                            addressCtrl.text = formattedAddress;
                                            amountCtrl.text = amount;
                                          });
                                        } else {}
                                      } else if (value != null &&
                                          value.contains(":")) {
                                        var addres = value.split(":").last;
                                        addres = addres.split("?").first;
                                        setState(() {
                                          addressCtrl.text = addres;
                                          if (value.contains("?amount=")) {
                                            amountCtrl.text = value
                                                .split("amount=")
                                                .last;
                                          }
                                        });
                                      } else if (value is String) {
                                        String formattedAddress =
                                            value.contains(':')
                                            ? value
                                                  .split(':')
                                                  .last
                                                  .split('amount')
                                                  .first
                                            : value.split('amount').first;
                                        String amount =
                                            value.contains('amount=')
                                            ? value.split('amount=').last
                                            : '';

                                        if (isValidCryptoAddress(
                                          formattedAddress,
                                          widget.assetData.gasPriceSymbol!,
                                        )) {
                                          setState(() {
                                            addressCtrl.text = formattedAddress;
                                            amountCtrl.text = amount;
                                          });
                                        } else {}
                                      }
                                    } else if (value == null) {
                                    } else if (value != null &&
                                        value.contains(":")) {
                                      var addres = value.split(":").last;
                                      addres = addres.split("?").first;
                                      setState(() {
                                        addressCtrl.text = addres;
                                        if (value.contains("?amount=")) {
                                          amountCtrl.text = value
                                              .split("amount=")
                                              .last;
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        addressCtrl.text = value ?? "";
                                      });
                                    }
                                  });
                            });
                          }
                        },
                        child: Image.asset(
                          "assets/Images/Arrow left.png",
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.height(context, 2)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                    child: AppText(
                      "Amount",
                      fontSize: 15,
                      color: Color(0XFF858585),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: TextFormField(
                      controller: amountCtrl,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () {
                        if (num.parse(widget.balance) ==
                            num.tryParse(amountCtrl.text)) {
                          isMaxClicked = true;
                        } else {
                          isMaxClicked = false;
                        }
                      },
                      onChanged: (v) {
                        if (num.parse(widget.balance) == num.tryParse(v)) {
                          isMaxClicked = true;
                        } else {
                          isMaxClicked = false;
                        }
                      },
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Please enter amount";
                        } else if (v.contains('.')) {
                          final parts = v.split('.');
                          if (parts.length > 1 &&
                              parts[1].length >
                                  int.parse(
                                    widget.assetData.tokenDecimal == null ||
                                            widget.assetData.tokenDecimal == ""
                                        ? "18"
                                        : widget.assetData.tokenDecimal ?? "18",
                                  )) {
                            return 'Max allowed decimals ${widget.assetData.tokenDecimal ?? "18"}';
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.go,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,}$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              widget.assetData.imageUrl!,
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(width: 5),
                            AppText(
                              "${widget.assetData.coinSymbol}",
                              color: Color(0XFF696969),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  if (widget.assetData.coinType == "1" ||
                                      widget.assetData.coinType == "2") {
                                    double balance = double.parse(
                                      widget.balance,
                                    );

                                    bool isToken =
                                        widget.assetData.coinType == "2";
                                    print("$isToken");
                                    setState(() {
                                      amountCtrl.text = balanceFormat
                                          .formatBalance(widget.balance);
                                      isMaxClicked = true;
                                    });
                                  } else {
                                    bool isBTC =
                                        widget.assetData.coinType == "3";
                                    double balance = double.parse(
                                      balanceFormat.formatBalance(
                                        widget.balance,
                                      ),
                                    );

                                    setState(() {
                                      amountCtrl.text = isBTC
                                          ? balanceFormat.formatBalance(
                                              widget.balance,
                                            )
                                          : '0';
                                      isMaxClicked = true;
                                    });
                                  }
                                } catch (e) {
                                  print("An error occurred: $e");
                                }
                              },
                              child: AppText(
                                "Max",
                                fontSize: 14,
                                fontFamily: 'LexendDeca',
                                color: Color(0xFFB982FF),
                              ),
                            ),
                          ],
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3), // Focus color
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFB982FF), // Focus color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: '${widget.assetData.coinSymbol} Amount',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent, // Focus color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'LexendDeca',
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.surfaceBright,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.height(context, 2)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        AppText(
                          "${balanceFormat.formatBalanceToString(widget.balance)} ${widget.assetData.coinSymbol}",
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0XFFBBBBBB),
                        ),
                      ],
                    ),
                  ),
                  widget.assetData.coinType == "2"
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: FutureBuilder<String>(
                            future: gasFeeFunction!,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(
                                      "Network Balance\n(Gas Deduction)",
                                      fontSize: 14,
                                    ),
                                    AppText(
                                      "${balanceFormat.formatBalanceToString(snapshot.data!)} ${widget.assetData.gasPriceSymbol}",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ],
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        )
                      : SizedBox(),
                  if (widget.assetData.coinSymbol == "XRP" ||
                      widget.assetData.coinSymbol == "tXRP")
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF512e5f).withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.orange[400],
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: AppText(
                                    "The ${widget.assetData.coinSymbol} network requires a one-time fee of 1 ${widget.assetData.coinSymbol} for account activation",
                                    fontSize: 12,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: SizedBox()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                ), // Add some padding for spacing
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.purpleAccent[100])
                    : ReuseElevatedButton(
                        onTap: isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate() &&
                                    addressCtrl.text.isNotEmpty &&
                                    amountCtrl.text.isNotEmpty) {
                                  double enteredAmount = double.parse(
                                    amountCtrl.text,
                                  );
                                  double tokenBalance = double.parse(
                                    widget.balance,
                                  );
                                  if (enteredAmount > tokenBalance) {
                                    Utils.snackBarErrorMessage(
                                      "Insufficient Balance",
                                    );
                                  } else if (enteredAmount <= 0) {
                                    Utils.snackBarErrorMessage(
                                      "Enter Amount Greater Than Zero",
                                    );
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (widget.assetData.rpcURL == "" ||
                                        widget.assetData.coinSymbol ==
                                            "DOG1E" ||
                                        widget.assetData.coinSymbol ==
                                            "tDOG1E") {
                                      if (widget.assetData.gasPriceSymbol!
                                          .contains("TRX")) {
                                        var trx = await fetchTrxBandwidth();
                                        tronGas = trx.toDouble();
                                        if (widget.assetData.coinType == "2") {
                                          var energy = await fetchTrxEnergy();
                                          tronEnergy = energy.toDouble();
                                        }
                                      }

                                      fetchXrpTnxFee();
                                      double amountControl =
                                          double.tryParse(amountCtrl.text) ??
                                          0.0;

                                      double btcGas1 =
                                          double.tryParse(btcGas.toString()) ??
                                          0.0;

                                      double solGas1 =
                                          double.tryParse(solGas.toString()) ??
                                          0.0;

                                      double xrpGas1 =
                                          double.tryParse(1.1.toString()) ??
                                          0.0; // Handle potential null value for `solgas`

                                      double tronGas1 =
                                          double.tryParse(tronGas.toString()) ??
                                          0.0; // Handle potential null value for `solgas`
                                      double trxEnergy =
                                          double.tryParse(
                                            tronEnergy.toString(),
                                          ) ??
                                          0.0;

                                      double btcAmount =
                                          amountControl - btcGas1;
                                      double solAmount =
                                          amountControl - solGas1;
                                      double tronAmount =
                                          widget.assetData.coinType == "3"
                                          ? (tronGas1 < 0.297
                                                ? amountControl - 0.297
                                                : amountControl)
                                          : (tronGas1 < 0.345
                                                ? amountControl - 0.345
                                                : amountControl);
                                      tronAmount =
                                          (widget.assetData.coinType == "3" ||
                                              trxEnergy >= 13540)
                                          ? tronAmount
                                          : tronAmount - 2.85;
                                      double xrpMaxAmount =
                                          amountControl - xrpGas1;
                                      if (widget.assetData.coinSymbol ==
                                              'tXRP' ||
                                          widget.assetData.coinSymbol ==
                                              'XRP') {
                                        if (amountControl + xrpGas1 >=
                                                double.parse(widget.balance) &&
                                            isMaxClicked == false) {
                                          Utils.snackBarErrorMessage(
                                            "Insufficient gas fee",
                                          );
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        }
                                      }

                                      if (widget.assetData.coinSymbol ==
                                              'tBTC' ||
                                          widget.assetData.coinSymbol ==
                                              'BTC') {}

                                      num trxEst =
                                          widget.assetData.coinType == "3"
                                          ? (tronGas1 < 0.297 ? 0.297 : 0.0)
                                          : (tronGas1 < 0.345 ? 0.297 : 0.0);
                                      trxEst =
                                          (widget.assetData.coinType == "3" ||
                                              trxEnergy >= 13540)
                                          ? trxEst
                                          : trxEst + 2.85;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (builder) => ConfirmTransactionPage(
                                            coinData: widget.assetData,
                                            toAddress: addressCtrl.text,
                                            estimatedGas:
                                                widget.assetData.coinSymbol ==
                                                        'tXRP' ||
                                                    widget
                                                            .assetData
                                                            .coinSymbol ==
                                                        'XRP'
                                                ? xrpGas1.toString()
                                                : widget
                                                              .assetData
                                                              .gasPriceSymbol ==
                                                          'tSOL' ||
                                                      widget
                                                              .assetData
                                                              .gasPriceSymbol ==
                                                          'SOL'
                                                ? solGas1.toString()
                                                : widget.assetData.coinSymbol ==
                                                          'tBTC' ||
                                                      widget
                                                              .assetData
                                                              .coinSymbol ==
                                                          'BTC'
                                                ? btcGas1.toString()
                                                : widget
                                                              .assetData
                                                              .gasPriceSymbol ==
                                                          'tTRX' ||
                                                      widget
                                                              .assetData
                                                              .gasPriceSymbol ==
                                                          'TRX'
                                                ? (trxEst.toString())
                                                : '',
                                            amount: isMaxClicked == true
                                                ? widget.assetData.coinSymbol ==
                                                              'tXRP' ||
                                                          widget
                                                                  .assetData
                                                                  .coinSymbol ==
                                                              'XRP'
                                                      ? xrpMaxAmount.toString()
                                                      : widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'tSOL' ||
                                                            widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'SOL'
                                                      ? solAmount.toString()
                                                      : widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'TRX' ||
                                                            widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'tTRX'
                                                      ? tronAmount.toString()
                                                      : widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'tBTC' ||
                                                            widget
                                                                    .assetData
                                                                    .coinSymbol ==
                                                                'BTC'
                                                      ? btcAmount.toString()
                                                      : amountCtrl.text
                                                : amountCtrl.text,
                                            fromAddress:
                                                widget.assetData.address!,
                                            userWallet: widget.walletData,
                                          ),
                                        ),
                                      );

                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String rpcUrl = widget.assetData.rpcURL!;
                                      final client = Web3Client(
                                        rpcUrl,
                                        http.Client(),
                                      );
                                      final credentials = EthPrivateKey.fromHex(
                                        privateKey!,
                                      );
                                      final address = credentials.address;
                                      String amountStr = amountCtrl.text;

                                      BigInt weiAmount = hexBytes.etherToWei(
                                        amountStr,
                                      );
                                      final amount = EtherAmount.inWei(
                                        weiAmount,
                                      );
                                      String myAddress = address.hexEip55;

                                      final chainID = await client.getChainId();

                                      final gas = await client.getGasPrice();

                                      dynamic vetamountcontroller =
                                          amountCtrl.text;
                                      dynamic vetestfee = 0.1;
                                      if (widget.assetData.coinSymbol ==
                                              'tVET' ||
                                          widget.assetData.coinSymbol ==
                                              'VET') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (builder) =>
                                                ConfirmTransactionPage(
                                                  fromAddress:
                                                      widget.assetData.address!,
                                                  toAddress: addressCtrl.text,
                                                  estimatedGas: 0.10.toString(),
                                                  amount: isMaxClicked == true
                                                      ? ((double.tryParse(
                                                                      vetamountcontroller,
                                                                    ) ??
                                                                    0) -
                                                                vetestfee)
                                                            .toStringAsFixed(6)
                                                      : amountCtrl.text,
                                                  coinData: widget.assetData,
                                                  userWallet: widget.walletData,
                                                ),
                                          ),
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      final estGas = await client.estimateGas();

                                      BigInt transactionFeeWei =
                                          estGas * gas.getInWei;

                                      double networkFeeEther =
                                          transactionFeeWei /
                                          BigInt.from(1000000000000000000);

                                      EtherAmount balance = await client
                                          .getBalance(address);

                                      BigInt balanceInWei = balance.getInWei;
                                      double balanceInEther =
                                          balanceInWei.toDouble() / 1e18;
                                      double roundedNetworkFeeEther =
                                          double.parse(
                                            networkFeeEther.toStringAsFixed(15),
                                          );
                                      double roundedBalanceInEther =
                                          double.parse(
                                            balanceInEther.toStringAsFixed(15),
                                          );
                                      print(
                                        'roundedBalanceInEther:::::::::${roundedBalanceInEther.toStringAsFixed(15)}',
                                      );
                                      double amountControl =
                                          double.tryParse(amountCtrl.text) ??
                                          0.0;
                                      double roundedAmountControl =
                                          double.parse(
                                            amountControl.toStringAsFixed(15),
                                          );
                                      print(
                                        'amountControl:::::::::${roundedAmountControl.toStringAsFixed(15)}',
                                      );

                                      double amountAndGas =
                                          roundedAmountControl +
                                          roundedNetworkFeeEther;

                                      final balminuscontrol =
                                          roundedBalanceInEther -
                                          roundedAmountControl;

                                      if (widget.assetData.coinType == '1') {
                                        if (isMaxClicked == true) {
                                          roundedAmountControl =
                                              roundedAmountControl -
                                              roundedNetworkFeeEther;
                                        } else if (roundedBalanceInEther ==
                                            roundedAmountControl) {
                                          roundedAmountControl =
                                              roundedAmountControl -
                                              roundedNetworkFeeEther;
                                        } else if (balminuscontrol >=
                                            roundedNetworkFeeEther) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          roundedAmountControl =
                                              roundedAmountControl;
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Utils.snackBarErrorMessage(
                                            "Insufficient Gas Fee",
                                          );
                                          return;
                                        }
                                      }
                                      double balanceAfterGas =
                                          roundedAmountControl -
                                          roundedNetworkFeeEther;
                                      bool token =
                                          widget.assetData.coinType == "2";

                                      final balanceAsDouble = double.parse(
                                        widget.balance,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });

                                      if (context.mounted) {
                                        if (token) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (builder) =>
                                                  ConfirmTransactionPage(
                                                    fromAddress: myAddress,
                                                    toAddress: addressCtrl.text,
                                                    estimatedGas: balanceFormat
                                                        .formatBalance(
                                                          networkFeeEther
                                                              .toString(),
                                                        ),
                                                    amount: amountCtrl.text,
                                                    coinData: widget.assetData,
                                                    userWallet:
                                                        widget.walletData,
                                                  ),
                                            ),
                                          );
                                        } else if ((roundedAmountControl <=
                                                roundedBalanceInEther) &&
                                            (roundedAmountControl > 0)) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (builder) =>
                                                  ConfirmTransactionPage(
                                                    fromAddress: myAddress,
                                                    toAddress: addressCtrl.text,
                                                    estimatedGas: balanceFormat
                                                        .formatBalance(
                                                          networkFeeEther
                                                              .toString(),
                                                        ),
                                                    amount: token
                                                        ? amountCtrl.text
                                                        : roundedAmountControl
                                                              .toStringAsFixed(
                                                                15,
                                                              ),
                                                    coinData: widget.assetData,
                                                    userWallet:
                                                        widget.walletData,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          print(
                                            "${(roundedAmountControl <= roundedBalanceInEther)}",
                                          );
                                          Utils.snackBarErrorMessage(
                                            "Insufficient Gas Fee",
                                          );
                                        }
                                      }
                                    }
                                  }
                                }
                              },
                        height: 50,
                        width: MediaQuery.sizeOf(context).width,
                        text: "Continue",
                        textcolor: Colors.black,
                        gradientColors: [],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// / ImageConstant.imgSearchGray70002
