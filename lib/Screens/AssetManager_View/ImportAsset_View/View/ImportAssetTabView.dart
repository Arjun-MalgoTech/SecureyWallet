import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/TronUtils.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/QRView/QRView_Android.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class ImportAssetTab extends StatefulWidget {
  @override
  _ImportAssetTabState createState() => _ImportAssetTabState();
}

class _ImportAssetTabState extends State<ImportAssetTab>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  late Web3Client client;
  String? tokenName;
  String? tokenSymbol;
  int? decimals;
  TextEditingController _rpcUrlController = TextEditingController();
  TextEditingController _contractAddressController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _symbolController = TextEditingController();
  TextEditingController _decimalController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController nodeController = TextEditingController();
  TextEditingController explorerController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  TextEditingController _selectedCoinController = TextEditingController();

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LocalStorageService localStorageService = LocalStorageService();
  Map<String, String>? selectedCoin;
  List<AssetModel> manageCoinList = [];
  List<dynamic> bsctokens = [];

  @override
  void initState() {
    super.initState();

    tabviewController = TabController(length: 2, vsync: this);
    manageCoinList.addAll(CoinListConfig.coinModelList);
    // loadBsctokens();
  }

  // Future<void> loadBsctokens() async {
  //   final String response =
  //       await rootBundle.loadString('assets/Json/bnbtokens');
  //   final data = await json.decode(response.toString());
  //   setState(() {
  //     bsctokens = data;
  //   });
  // }

  bool isValidCryptoAddress(
    String address,
  ) {
    // Ethereum address regex
    RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return ethereumAddressRegex
        .hasMatch(address); // Invalid or unsupported coin symbol
  }

  String? _rpcUrlError;
  Future<String?> validateRpcUrl(String rpcUrl) async {
    if (rpcUrl.isEmpty) {
      return "Please enter a valid URL";
    } else if (!Uri.parse(rpcUrl).isAbsolute) {
      return 'Please enter a valid URL';
    }

    try {
      // Initialize the Web3Client with the provided RPC URL
      final web3Client = Web3Client(rpcUrl, Client());

      // Attempt to get the latest block number
      await web3Client.getBlockNumber();
      print('${web3Client.getBlockNumber()}');

      // If no exception is thrown, the URL is valid
      return null;
    } catch (e) {
      return 'Node Connection Error';
    }
  }

  String? _nodeUrlError;
  Future<String?> validateNodeUrl(String rpcUrl) async {
    if (rpcUrl.isEmpty) {
      return "Please enter a valid URL";
    } else if (!Uri.parse(rpcUrl).isAbsolute) {
      return 'Please enter a valid URL';
    }

    try {
      final response = await http.get(Uri.parse(rpcUrl));
      if (response.statusCode != 200) {
        // print('DGGJHBUOYGHERG');
        return 'Node Connection Error';
      }
    } catch (e) {
      return 'Node Connection Error';
    }
    // print('sdjbiuhbhbhhjbjhbjhbjhb');
    return null; // No validation error
  }

  Future<void> getTokenInfo(String rpcUrl, String contractAddress) async {
    if (isValidEthereumAddress(contractAddress)) {
      EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

      // Load contract ABI from a JSON file or define it here
      String abiCode =
          '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"}]';
      DeployedContract contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'Token'),
        contractAddr,
      );

      try {
        // Create a new client with the provided RPC URL
        client = Web3Client(rpcUrl, Client());

        // Call name, symbol, and decimals functions of the token contract
        final nameFunction = contract.function('name');
        final symbolFunction = contract.function('symbol');
        final decimalsFunction = contract.function('decimals');

        final List<dynamic> nameResult = await client.call(
          contract: contract,
          function: nameFunction,
          params: [],
        );
        final List<dynamic> symbolResult = await client.call(
          contract: contract,
          function: symbolFunction,
          params: [],
        );
        final List<dynamic> decimalsResult = await client.call(
          contract: contract,
          function: decimalsFunction,
          params: [],
        );
        setState(() {
          tokenName = nameResult[0].toString();
          tokenSymbol = symbolResult[0].toString();
          decimals = int.parse(decimalsResult[0].toString());

          // print('Token Info Successfully');

          // Set the text of the controllers
          _nameController.text = tokenName ?? '';
          _symbolController.text = tokenSymbol ?? '';
          _decimalController.text = decimals?.toString() ?? '';
        });
      } catch (e) {
        // Show error message using SnackBar
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).bottomAppBarTheme.color ??
                  Color(0xFFD4D4D4),
              title: AppText(
                'Error fetching token info',
                color: Theme.of(context).colorScheme.surfaceBright,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // _selectedCoinController.clear();
                    // _contractAddressController.clear();
                    // _imageController.clear();
                  },
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFFB982FF),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 4, bottom: 4),
                          child: AppText(
                            "OK",
                            color: Colors.black,
                          ),
                        )),
                  ),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Clear token information if the address is invalid
      setState(() {
        tokenName = null;
        tokenSymbol = null;
        decimals = null;

        // Clear the text of the controllers
        _nameController.clear();
        _symbolController.clear();
        _decimalController.clear();
      });
    }
  }

  Future<void> getSolanaTokenInfo(String contractAddress) async {
    Solana solana = Solana();
    try {
      var data = await solana.getTokenInfo(
          address: contractAddress,
          networktype: coinData!.network == "Testnet"
              ? NetworkType.Devnet
              : NetworkType.Mainnet);

      print("SOLANAAAAAAA::$data");

      setState(() {
        // tokenName = data;
        // tokenSymbol = symbolResult[0].toString();
        decimals = int.parse(
            data["value"]["data"]["parsed"]["info"]["decimals"].toString());

        // print('Token Info Successfully');

        // Set the text of the controllers
        // _nameController.text = tokenName ?? '';
        // _symbolController.text = tokenSymbol ?? '';
        _decimalController.text = decimals?.toString() ?? '';
      });
    } catch (e) {
      // Show error message using SnackBar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                Theme.of(context).bottomAppBarTheme.color ?? Color(0xFFD4D4D4),
            title: AppText(
              'Error fetching token info',
              color: Theme.of(context).colorScheme.surfaceBright,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _nameController.clear();
                  symbolController.clear();
                  _decimalController.clear();
                },
                child: Center(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xFFB982FF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18.0, right: 18.0, top: 4, bottom: 4),
                        child: AppText(
                          "OK",
                          color: Colors.black,
                        ),
                      )),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  bool isValidEthereumAddress(String address) {
    // Regular expression to match Ethereum addresses
    RegExp regex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return regex.hasMatch(address);
  }

  Future<bool> isValidEthereumAddressOnBlockchain(
      rpcurl, String address) async {
    final String rpcUrl = rpcurl;

    // Make sure address is valid with regex first
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(address)) {
      return false; // Invalid format, return false immediately
    }

    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "jsonrpc": "2.0",
          "method": "eth_getCode",
          "params": [address, "latest"],
          "id": 1,
        }),
      );

      final responseBody = json.decode(response.body);

      // Check if response has code for the address
      if (responseBody["result"] == "0x") {
        return false; // No code at this address, probably not a contract
      } else {
        return true; // Valid address with code (likely a smart contract)
      }
    } catch (e) {
      print("Error checking address: $e");
      return false;
    }
  }

  Future<dynamic> tronContractInfo(String contractAddress) async {
    final String rpcUrl = coinData!.gasPriceSymbol == 'TRX'
        ? "https://api.trongrid.io/wallet/getcontractinfo"
        : "https://nile.trongrid.io/wallet/getcontractinfo";

    // Make sure address is valid with regex first

    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"value": contractAddress, "visible": true}),
      );

      final responseBody = json.decode(response.body);

      if (responseBody != null &&
          responseBody["smart_contract"]["name"] != null) {
        print('vvvvvvvvvvv${responseBody["smart_contract"]["name"]}');
        setState(() {
          _nameController.text = responseBody["smart_contract"]["name"];
          _symbolController.text = responseBody["smart_contract"]["name"];
        });
        return responseBody["smart_contract"]["name"];
      } else {
        return "Name not found in contract info";
      }
      // Check if response has code for the address
    } catch (e) {
      print("Error checking address: $e");
      return false;
    }
  }

  void _updateImageController(String coinSymbol) {
    setState(() {
      final coinImage =
          "https://assets.coincap.io/assets/icons/$coinSymbol@2x.png";
      _imageController.text = coinImage;
      print('_imageController::::${_imageController.text}');
    });
  }

  void _updateCoinImageController(String coinSymbol) {
    setState(() {
      final coinImage =
          "https://assets.coincap.io/assets/icons/$coinSymbol@2x.png";
      imageController.text = coinImage;
      print('imageController::::${imageController.text}');
    });
  }

  AssetModel? coinData;
  String? gasSymbol;
  void _onItemSelected(AssetModel selectedCoin) {
    setState(() {
      gasSymbol = selectedCoin.coinSymbol!;
      _rpcUrlController.text = selectedCoin.rpcURL!;

      _selectedCoinController.text = selectedCoin.coinName ?? "Select Coin";
      coinData = selectedCoin;
    });
    // print(
    //     '_contractAddressController::::::::${_contractAddressController.text}');
  }

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Container(
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
        ),
        title: AppText(
          'Import crypto',
          fontSize: 18,
          color: Theme.of(context).colorScheme.surfaceBright,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Your text form fields go here
            // I'm omitting them for brevity
            TabBar(
                dividerColor: Colors.transparent,
                controller: tabviewController,
                labelPadding: EdgeInsets.zero,
                indicatorColor:
                    Color(0xFFB982FF), // Set indicator color to 30DCF9
                tabs: [
                  Tab(
                      child: AppText(
                    "Network",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  )),
                  Tab(
                      child: AppText(
                    "Token",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  )),
                ]),
            Container(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                  controller: tabviewController,
                  children: [NetworkTabs(), TokenTab()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget NetworkTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).bottomAppBarTheme.color ??
                          Color(0xFFD4D4D4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info,
                            color: Color(0xFFFCB500),
                            size: 20,
                          ),
                          SizedBox(
                            width: SizeConfig.width(context, 3),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                "Only use custom networks you trust to protect your",
                                fontFamily: 'LexendDeca',
                                color: Color(0xFFFCB500),
                                fontSize: 11,
                              ),
                              AppText(
                                "data and prevent manipulation of blockchain info.",
                                fontFamily: 'LexendDeca',
                                color: Color(0xFFFCB500),
                                fontSize: 11,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText(
                            "Name",
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      TextFormField(
                        style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                            decorationThickness: 0.0),
                        controller: nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {
                          if (v!.isEmpty) {
                            return "Please enter the coin name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText(
                            "Symbol",
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      TextFormField(
                        style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                            decorationThickness: 0.0),
                        controller: symbolController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {
                          if (v!.isEmpty) {
                            return "Please enter the coin symbol";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText(
                            "Node URL",
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                            decorationThickness: 0.0),
                        controller: nodeController,
                        validator: (value) => _rpcUrlError,
                        onChanged: (value) async {
                          // Avoid redundant validation calls
                          if (value.isEmpty) {
                            setState(() {
                              _rpcUrlError = 'Please enter the node URL';
                            });
                            return;
                          }
                          // Async validate URL
                          String? validationError = await validateRpcUrl(value);
                          if (validationError != _rpcUrlError) {
                            setState(() {
                              _rpcUrlError = validationError;
                            });
                          }

                          // Trigger form-wide validation
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText(
                            "Explorer URL",
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      TextFormField(
                        style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                            decorationThickness: 0.0),
                        controller: explorerController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => _nodeUrlError,
                        onChanged: (value) async {
                          // Avoid redundant validation calls
                          if (value.isEmpty) {
                            setState(() {
                              _nodeUrlError = 'Please enter the node URL';
                            });
                            return;
                          }
                          // Async validate URL
                          String? validationError =
                              await validateNodeUrl(value);
                          if (validationError != _nodeUrlError) {
                            setState(() {
                              _nodeUrlError = validationError;
                            });
                          }

                          // Trigger form-wide validation
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText(
                            "Image URL (Optional)",
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                            decorationThickness: 0.0),
                        controller: imageController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor ??
                                  Color(0xFFD4D4D4), // Focus color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ReuseElevatedButton(
                    onTap: () async {
                      _updateCoinImageController(
                          symbolController.text.toLowerCase());
                      String? validationError =
                          await validateRpcUrl(nodeController.text);
                      setState(() {
                        _rpcUrlError = validationError;
                      });

                      String? explorerError =
                          await validateNodeUrl(explorerController.text);

                      setState(() {
                        _nodeUrlError = explorerError;
                      });

                      if (_formKey.currentState!.validate()) {
                        bool success = await localStorageService.addAssetData({
                          "rpcURL": nodeController.text,
                          "explorerURL": explorerController.text,
                          "coinSymbol": symbolController.text,
                          "coinName": nameController.text,
                          'imageUrl': imageController.text,
                          "balanceFetchAPI": "",
                          "sendAmountAPI": "",
                          "address": "",
                          "coinType": "1",
                          "tokenAddress": "",
                          "tokenDecimal": "",
                          "network": nameController.text,
                          "gasPriceSymbol": symbolController.text,
                        }, context);
                        if (success) {
                          showCustomDialog1(context,
                              "Now you can send, receive\ncoins, add tokens, browse\nand many more.");
                        }
                      }
                    },
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    text: 'Import',
                    textcolor: Colors.black,
                    gradientColors: [Color(0XFF42E695), Color(0XFF3BB2BB)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool loading = false;

  Widget TokenTab() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey1,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText(
                              "Select Coin",
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            var appCoins = manageCoinList
                                .where((element) =>
                                    element.coinType == "1" ||
                                    (element.coinSymbol!
                                        .toUpperCase()
                                        .contains("SOL")) ||
                                    (element.coinSymbol!
                                        .toUpperCase()
                                        .contains("TRX")) ||
                                    (element.coinSymbol!
                                        .toUpperCase()
                                        .contains("XRP")))
                                .toList();
                            var userCoins = localStorageService.assetList
                                .where((element) => element.coinType == "1")
                                .toList();

                            var combinedList = [...appCoins, ...userCoins];

                            var uniqueList =
                                combinedList.fold<List<AssetModel>>(
                              [],
                              (unique, element) {
                                if (!unique.any((e) =>
                                    (e.coinType == "1" &&
                                        e.rpcURL == element.rpcURL) ||
                                    (e.coinType == "3" &&
                                        e.coinSymbol == element.coinSymbol))) {
                                  unique.add(element);
                                }
                                return unique;
                              },
                            );
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CoinListWidget(manageCoinList: uniqueList);
                            })).then((value) {
                              if (value != null) {
                                _onItemSelected(value);
                              }
                            });
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Please select the coin";
                            }
                            return null;
                          },
                          controller: _selectedCoinController,
                          style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.surfaceBright,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText(
                              "Token Address",
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        TextFormField(
                          validator: (v) {
                            if (v != null) {
                              // print('Pasted address: $pastedAddress');
                              if (coinData?.coinType == '1') {
                                setState(() {
                                  // _symbolController.text = v;
                                });
                                print('ccc${_symbolController.text}');
                                getTokenInfo(_rpcUrlController.text, v);

                                // _updateImageController(v.toLowerCase());
                                return null;

                                return "Please enter valid token address";
                              }
                              return null;
                            }
                            return "Please enter valid token address";
                          },
                          style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              fontSize: 18,
                              decorationThickness: 0.0),
                          controller: _contractAddressController,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).hintColor ??
                                      Color(0xFFD4D4D4), // Focus color
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).hintColor ??
                                      Color(0xFFD4D4D4), // Focus color
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                          .bottomAppBarTheme
                                          .color ??
                                      Color(0xFFD4D4D4), // Focus color
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      ClipboardData? data =
                                          await Clipboard.getData(
                                              Clipboard.kTextPlain);
                                      print('Clipboard data: ${data?.text}');
                                      if (data != null) {
                                        String pastedAddress = data.text ?? '';
                                        // print('Pasted address: $pastedAddress');
                                        if (coinData?.coinType == '1') {
                                          setState(() {
                                            _contractAddressController.text =
                                                pastedAddress;
                                          });

                                          getTokenInfo(_rpcUrlController.text,
                                              pastedAddress);
                                        } else {
                                          _contractAddressController.text =
                                              pastedAddress;
                                          if (coinData!.coinSymbol!
                                              .toUpperCase()
                                              .contains("SOL")) {
                                            getSolanaTokenInfo(
                                                _contractAddressController
                                                    .text);
                                          } else if (coinData!.coinSymbol!
                                              .toUpperCase()
                                              .contains("TRX")) {
                                            String ownerAddress = coinData!
                                                .address!; // Your Base58 TRON wallet address
                                            final String contractAddress =
                                                _contractAddressController.text;
                                            if (coinData?.gasPriceSymbol ==
                                                    'TRX' ||
                                                coinData?.gasPriceSymbol ==
                                                    'tTRX') {
                                              await tronContractInfo(
                                                  contractAddress);
                                            }

                                            // TRC-20 contract in Hex
                                            final String rpcURL = coinData
                                                        ?.gasPriceSymbol ==
                                                    'TRX'
                                                ? 'https://api.trongrid.io'
                                                : 'https://nile.trongrid.io';
                                            final tokenInfo =
                                                await TronUtils.getTokenInfo(
                                              rpcurl: rpcURL,
                                              contractAddress: contractAddress,
                                              coinData: coinData!,
                                              selectedWalletData:
                                                  localStorageService
                                                      .activeWalletData!,
                                            );
                                            setState(() {
                                              _decimalController.text =
                                                  tokenInfo['decimals'];
                                              _formKey1.currentState
                                                  ?.validate();
                                            });
                                          }
                                          // Show a message if the address is invalid
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   SnackBar(
                                          //       content: Text(
                                          //           'Invalid address format')),
                                          // );
                                        }
                                      }
                                    },
                                    child: AppText(
                                      "Paste",
                                      fontSize: 14,
                                      fontFamily: 'LexendDeca',
                                      color: const Color(0xFFB982FF),
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.qr_code,
                                        color: Theme.of(context).indicatorColor,
                                      ),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (builder) => QRView(
                                                        back: true,
                                                      )))
                                              .then((value) {
                                            setState(() async {
                                              if (value != null) {
                                                if (value
                                                    is Map<String, String>) {
                                                  String rawAddress =
                                                      value['barcode'] ?? '';
                                                  print(
                                                      '.........1111111$rawAddress');

                                                  String formattedAddress =
                                                      rawAddress.contains(':')
                                                          ? rawAddress
                                                              .split(':')
                                                              .last
                                                          : rawAddress;
                                                  print(
                                                      '::::::::::::$formattedAddress');
                                                  if (coinData?.coinType ==
                                                      '1') {
                                                    if (isValidCryptoAddress(
                                                        formattedAddress)) {
                                                      setState(() {
                                                        _contractAddressController
                                                                .text =
                                                            formattedAddress;
                                                      });

                                                      getTokenInfo(
                                                          _rpcUrlController
                                                              .text,
                                                          formattedAddress);

                                                      // _updateImageController(
                                                      //     formattedAddress);
                                                    }
                                                  } else {
                                                    _contractAddressController
                                                            .text =
                                                        formattedAddress;
                                                    if (coinData!.coinSymbol!
                                                        .toUpperCase()
                                                        .contains("SOL")) {
                                                      getSolanaTokenInfo(
                                                          _contractAddressController
                                                              .text);
                                                    } else if (coinData!
                                                        .coinSymbol!
                                                        .toUpperCase()
                                                        .contains("TRX")) {
                                                      String ownerAddress =
                                                          coinData!
                                                              .address!; // Your Base58 TRON wallet address
                                                      final String
                                                          contractAddress =
                                                          _contractAddressController
                                                              .text;
                                                      if (coinData?.gasPriceSymbol ==
                                                              'TRX' ||
                                                          coinData?.gasPriceSymbol ==
                                                              'tTRX') {
                                                        await tronContractInfo(
                                                            contractAddress);
                                                      }
// TRC-20 contract in Hex
                                                      final String rpcURL = coinData
                                                                  ?.gasPriceSymbol ==
                                                              'TRX'
                                                          ? 'https://api.trongrid.io'
                                                          : 'https://nile.trongrid.io';
                                                      final tokenInfo =
                                                          await TronUtils
                                                              .getTokenInfo(
                                                        rpcurl: rpcURL,
                                                        contractAddress:
                                                            contractAddress,
                                                        coinData: coinData!,
                                                        selectedWalletData:
                                                            localStorageService
                                                                .activeWalletData!,
                                                      );
                                                      setState(() {
                                                        _decimalController
                                                                .text =
                                                            tokenInfo[
                                                                'decimals'];
                                                        _formKey1.currentState
                                                            ?.validate();
                                                      });
                                                    }
                                                  }
                                                } else if (value is String) {
                                                  String formattedAddress =
                                                      value.contains(':')
                                                          ? value
                                                              .split(':')
                                                              .last
                                                          : value;
                                                  if (coinData?.coinType ==
                                                      '1') {
                                                    if (isValidCryptoAddress(
                                                        formattedAddress)) {
                                                      setState(() {
                                                        _contractAddressController
                                                                .text =
                                                            formattedAddress;
                                                      });

                                                      getTokenInfo(
                                                          _rpcUrlController
                                                              .text,
                                                          formattedAddress);

                                                      // _updateImageController(
                                                      //     formattedAddress);
                                                    }
                                                  } else {
                                                    _contractAddressController
                                                            .text =
                                                        formattedAddress;
                                                    if (coinData!.coinSymbol!
                                                        .toUpperCase()
                                                        .contains("SOL")) {
                                                      getSolanaTokenInfo(
                                                          _contractAddressController
                                                              .text);
                                                    } else if (coinData!
                                                        .coinSymbol!
                                                        .toUpperCase()
                                                        .contains("TRX")) {
                                                      String ownerAddress =
                                                          coinData!
                                                              .address!; // Your Base58 TRON wallet address
                                                      final String
                                                          contractAddress =
                                                          _contractAddressController
                                                              .text;
                                                      if (coinData?.gasPriceSymbol ==
                                                              'TRX' ||
                                                          coinData?.gasPriceSymbol ==
                                                              'tTRX') {
                                                        await tronContractInfo(
                                                            contractAddress);
                                                      }
// TRC-20 contract in Hex
                                                      final String rpcURL = coinData
                                                                  ?.gasPriceSymbol ==
                                                              'TRX'
                                                          ? 'https://api.trongrid.io'
                                                          : 'https://nile.trongrid.io';
                                                      final tokenInfo =
                                                          await TronUtils
                                                              .getTokenInfo(
                                                        rpcurl: rpcURL,
                                                        contractAddress:
                                                            contractAddress,
                                                        coinData: coinData!,
                                                        selectedWalletData:
                                                            localStorageService
                                                                .activeWalletData!,
                                                      );
                                                      setState(() {
                                                        _decimalController
                                                                .text =
                                                            tokenInfo[
                                                                'decimals'];
                                                        _formKey1.currentState
                                                            ?.validate();
                                                      });
                                                    }
                                                  }
                                                }
                                              }
                                            });
                                          });
                                        });
                                      }),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText(
                              "Name",
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              fontSize: 18,
                              decorationThickness: 0.0),
                          controller: _nameController,
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Please enter the coin name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.only(left: 8, right: 8),
                          ),
                        ),
                      ],
                    ),
                  ), //name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText(
                              "Symbol",
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        TextFormField(
                          style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              fontSize: 18,
                              decorationThickness: 0.0),
                          controller: _symbolController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Please enter the symbol name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.only(left: 8, right: 8),
                          ),
                        ),
                      ],
                    ),
                  ), //symbol
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText(
                              "Decimal",
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Please enter the decimal";
                            }
                            return null;
                          },
                          style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              fontSize: 18,
                              decorationThickness: 0.0),
                          keyboardType: TextInputType.number,
                          controller: _decimalController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor ??
                                    Color(0xFFD4D4D4), // Focus color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.only(left: 8, right: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Color(0xFF30DCF9),
                        ))
                      : Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ReuseElevatedButton(
                            onTap: () async {
                              _updateImageController(
                                  _symbolController.text.toLowerCase());
                              if (_formKey1.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                String contractAddress =
                                    _contractAddressController.text;
                                bool isValid =
                                    await isValidEthereumAddressOnBlockchain(
                                        _rpcUrlController.text,
                                        contractAddress);
                                print(
                                    "Validating Ethereum address: $contractAddress");
                                // if (!isValid) {
                                //   // If the address is invalid, show an error message
                                //   customSnackBar.showSnakbar(context,
                                //       "Invalid Address!", SnackbarType.negative);
                                //   return; // Don't proceed with adding the token
                                // }
                                await Future.delayed(Duration(seconds: 1),
                                    () async {
                                  String coinAddress = "";
                                  if (coinData!.coinType == "3") {
                                    coinAddress = coinData!.address == ""
                                        ? await assetAddressGenerate
                                            .generateAddress(
                                                coinData!.coinSymbol!,
                                                localStorageService
                                                    .activeWalletData!.mnemonic)
                                        : coinData!.address!;
                                  }
                                  print('//${_rpcUrlController.text}  //');
                                  bool success =
                                      await localStorageService.addTokenData({
                                    "rpcURL": _rpcUrlController.text,
                                    "explorerURL": coinData!.explorerURL!,
                                    "coinSymbol": coinData!.network == "Testnet"
                                        ? ("t${_symbolController.text}")
                                        : _symbolController.text,
                                    "coinName": _nameController.text,
                                    "imageUrl": _imageController.text,
                                    "balanceFetchAPI": "",
                                    "sendAmountAPI": "",
                                    "address": coinAddress,
                                    "coinType": "2",
                                    "tokenAddress":
                                        _contractAddressController.text,
                                    "tokenDecimal": _decimalController.text,
                                    "network": coinData!.network!,
                                    "gasPriceSymbol": gasSymbol!,
                                  }, context);
                                  if (success) {
                                    // print('jgjhggggggggggggggggggggggggggggggggg');
                                    showCustomDialog(
                                        context, "Token Added Successfully!");
                                  }
                                });
                              }
                            },
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            text: 'Import',
                            textcolor: Colors.black,
                            gradientColors: [
                              Color(0XFF42E695),
                              Color(0XFF3BB2BB)
                            ],
                          ),
                        ),
                ],
              ),
              // Other Container widgets go here
              // I'm omitting them for brevity
            )));
  }
}

class CoinListWidget extends StatefulWidget {
  final List<AssetModel> manageCoinList;

  CoinListWidget({required this.manageCoinList});

  @override
  _CoinListWidgetState createState() => _CoinListWidgetState();
}

class _CoinListWidgetState extends State<CoinListWidget> {
  late List<AssetModel> filteredCoinList;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the filtered list with the original list
    filteredCoinList = widget.manageCoinList;
    // Listen to changes in the text field
    searchController.addListener(onSearchTextChanged);
  }

  void onSearchTextChanged() {
    String query = searchController.text.trim();
    filterCoins(query); // Call the filterCoins method with the current query
  }

  void filterCoins(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, show the original list
        filteredCoinList = widget.manageCoinList;
      } else {
        // Filter the list based on the query
        filteredCoinList = widget.manageCoinList.where((coin) {
          return coin.coinName!.toLowerCase().contains(query.toLowerCase()) ||
              coin.coinSymbol!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void clearSearch() {
    // Clear the text field and reset the filtered list to show all items
    searchController.clear();
    setState(() {
      filteredCoinList = widget.manageCoinList;
    });
  }

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
        title: AppText(
          'Select Network',
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: Center(
                child: TextField(
                  controller: searchController,
                  onChanged: (query) => onSearchTextChanged(),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).hintColor ?? Color(0xFFD4D4D4),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      size: 16,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: clearSearch,
                            icon: Icon(Icons.close),
                          )
                        : SizedBox(),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Theme.of(context).bottomAppBarTheme.color ??
                        Color(0xFFD4D4D4),
                    filled: true,
                  ),
                  style: TextStyle(
                    decorationThickness: 0.0,
                    fontFamily: 'LexendDeca',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredCoinList.isEmpty
                ? Center(
                    child: GradientAppText(text: "No data found", fontSize: 16))
                : ListView.builder(
                    itemCount: filteredCoinList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor: const Color(0xFF202832),
                            radius: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                  filteredCoinList[index].imageUrl!,
                                  errorBuilder: (_, obj, trc) {
                                return AppText(
                                  filteredCoinList[index]
                                      .coinSymbol
                                      .toString()
                                      .characters
                                      .first,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                );
                              }),
                            )),
                        title: AppText(
                          "${filteredCoinList[index].coinSymbol}",
                          color: Theme.of(context).colorScheme.surfaceBright,
                          fontSize: 15,
                        ),
                        subtitle: AppText(
                          '${filteredCoinList[index].coinName}',
                          color: Theme.of(context).colorScheme.surfaceBright,
                          fontSize: 13,
                        ),
                        onTap: () {
                          Navigator.pop(context, filteredCoinList[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void showCustomDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor:
            Theme.of(context).bottomAppBarTheme.color ?? Color(0xFFD4D4D4),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.8, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppText(
                    message,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (builder) => AppBottomNav(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFFB982FF),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 4, bottom: 4),
                          child: AppText(
                            "OK",
                            color: Colors.black,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showCustomDialog1(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor:
            Theme.of(context).bottomAppBarTheme.color ?? Color(0xFFD4D4D4),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.8, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText(
                      "Chain Added Successfully!",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppText(
                    message,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (builder) => AppBottomNav(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFFB982FF),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 4, bottom: 4),
                          child: AppText(
                            "OK",
                            color: Colors.black,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
