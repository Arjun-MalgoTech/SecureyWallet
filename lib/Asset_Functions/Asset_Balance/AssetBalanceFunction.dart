import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:securywallet/Api_Service/ApiUrl_Service.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Asset_Functions/XrpHttpClient.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:http/http.dart' as http;
import 'package:thor_request_dart/connect.dart';
import 'package:web3dart/web3dart.dart';
import 'package:solana_web3/solana_web3.dart' as sol;
// import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:solana/src/solana_client.dart';
import 'package:solana/dto.dart';


class AssetBalanceFunction {
  Future<String> VetBalance(String address) async {
    var connector = Connect("https://mainnet.veblocks.net");
    BigInt VETBalance = await connector
        .getVetBalance(address); // Assuming it returns Future<BigInt>
    print("VETBalance $VETBalance");
    // Assuming the balance needs to be divided by 10^18 to get the actual value in human-readable format
    BigInt base =
        BigInt.from(pow(10, 18)); // For 18 decimal places (adjust if needed)
    double balanceInVet = VETBalance.toDouble() / base.toDouble();

    // Format the balance to 6 decimal places
    String formattedBalance = balanceInVet.toString();

    print("Formatted VETBalance: $formattedBalance");

    // Return the formatted balance as a string
    return formattedBalance;
  }

  Future<String> tVetBalance(String address) async {
    var connector = Connect("https://testnet.veblocks.net");
    BigInt tVETBalance = await connector
        .getVetBalance(address); // Assuming it returns Future<BigInt>
    print("tVETBalance $tVETBalance");
    // Assuming the balance needs to be divided by 10^18 to get the actual value in human-readable format
    BigInt base =
        BigInt.from(pow(10, 18)); // For 18 decimal places (adjust if needed)
    double balanceInVet = tVETBalance.toDouble() / base.toDouble();

    // Format the balance to 6 decimal places
    String formattedBalance = balanceInVet.toString();

    print("Formatted tVETBalance: $formattedBalance");

    // Return the formatted balance as a string
    return formattedBalance;
  }

  Future<String> ethBalance(AssetModel coinData, String privateKey) async {
    String coinBalance = "0.0";
    String rpcUrl = coinData.rpcURL!;
    print("$rpcUrl");
    final client = Web3Client(rpcUrl, http.Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;

    try {
      // Get the balance in Wei
      final balanceInWei = await client.getBalance(address);

      // Convert Wei to Ether
      BigInt balanceInEtherWei = balanceInWei.getInWei;
      BigInt conversionFactor = BigInt.from(1000000000000000000);
      BigInt etherInWei = balanceInEtherWei;

      // Perform the division to get the Ether value
      // Here, you want to keep track of precision by performing arithmetic in BigInt
      BigInt integerPart = etherInWei ~/ conversionFactor;
      BigInt fractionalPart = etherInWei % conversionFactor;

      // Convert fractional part to a fixed number of decimal places
      String fractionalPartString = fractionalPart.toString().padLeft(18, '0');
      String fractionalPartFormatted =
          fractionalPartString.substring(0, CoinListConfig.cryptoDecimal);

      // Format result
      coinBalance = '$integerPart.$fractionalPartFormatted';
      print('${coinData.coinSymbol}coinBalance:::::::$coinBalance');
    } catch (e) {
      coinBalance = "0.0";
    } finally {
      client.dispose();
    }

    return coinBalance;
  }

  Future<String> getSolBalance(
      AssetModel coinData, UserWalletDataModel activeWalletData) async {
    final cluster = coinData.network == "Testnet"
        ? sol.Cluster.devnet
        : sol.Cluster.mainnet;
    final connection = sol.Connection(cluster);
    final balance =
        await connection.getBalance(sol.Pubkey.fromString(coinData.address!));
    var coinBalance = sol.lamportsToSol(BigInt.from(balance));
    return coinBalance.toString();
  }

  String base58ToHex(String base58Address) {
    const String base58Alphabet =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

    BigInt decoded = BigInt.zero;

    for (int i = 0; i < base58Address.length; i++) {
      final int index = base58Alphabet.indexOf(base58Address[i]);
      if (index == -1) {
        throw FormatException("Invalid Base58 character: ${base58Address[i]}");
      }
      decoded = decoded * BigInt.from(58) + BigInt.from(index);
    }

    final result = <int>[];
    while (decoded > BigInt.zero) {
      result.insert(0, (decoded % BigInt.from(256)).toInt());
      decoded = decoded ~/ BigInt.from(256);
    }

    final int leadingZeros =
        base58Address.split('').takeWhile((char) => char == '1').length;

    final data = Uint8List.fromList(List.filled(leadingZeros, 0) + result);

    // Validate checksum
    final checksum = data.sublist(data.length - 4);
    final payload = data.sublist(0, data.length - 4);
    final hash = sha256.convert(sha256.convert(payload).bytes).bytes;
    for (int i = 0; i < 4; i++) {
      if (checksum[i] != hash[i]) {
        throw FormatException("Invalid Base58 address checksum");
      }
    }

    // Convert to hex and return
    return hex.encode(data.sublist(0, data.length - 4)).toLowerCase();
  }

  Future<String> getDogecoinTestnetBalance(String address) async {
    final url =
        Uri.parse('https://api.tatum.io/v3/dogecoin/address/balance/$address');
    final headers = {
      'x-api-key': 't-679cc3141db825b185ad236b-80b6380f557f4fcd9268c908'
    }; // Use your API key here

    final response = await http.get(url, headers: headers);

    final result = json.decode(response.body);
    print('Balance: ${result['incoming']} DOGE');
    return result['incoming'];
  }

  Future<String> getDogecoinMainnetBalance(String address) async {
    final url =
        Uri.parse('https://api.tatum.io/v3/dogecoin/address/balance/$address');
    final headers = {
      'x-api-key': 't-679cc3141db825b185ad236b-3ba2dc8e1de949ff8fa52fc0'
    }; // Use your API key here

    final response = await http.get(url, headers: headers);

    final result = json.decode(response.body);
    print('Balance11: ${result['incoming']} DOGE');
    return result['incoming'];
  }

  Future<String> tronTokenBalance({
    required String rpcUrl,
    required String contractAddress, // Token contract address in Base58
    required String ownerAddress, // Wallet address in Base58
  }) async {
    print('dssss');
    try {
      // Convert addresses from Base58 to Hex
      final String hexContractAddress = base58ToHex(contractAddress);
      final String hexOwnerAddress = base58ToHex(ownerAddress);

      // TRON API endpoint for constant contract methods
      print("fffff");
      final String url = "$rpcUrl/wallet/triggerconstantcontract";
      print('nn$url');
      // Helper function to call a contract function

      // Fetch token decimals
      final String? rawDecimals = await callContractFunction(
          'decimals()', hexOwnerAddress, hexContractAddress, url);
      print('rawDecimals : $rawDecimals');
      if (rawDecimals == null)
        throw Exception('Failed to fetch token decimals');
      final int decimals = int.parse(rawDecimals, radix: 16);

      // Fetch token balance
      final String? rawBalance = await callContractFunction(
        'balanceOf(address)',
        hexOwnerAddress,
        hexContractAddress,
        url,
        hexOwnerAddress.padLeft(64, '0'),
      );
      print('rawBalance : $rawBalance');
      if (rawBalance == null) throw Exception('Failed to fetch token balance');
      final BigInt balance = BigInt.parse(rawBalance, radix: 16);

      // Adjust the balance by decimals
      final double adjustedBalance = balance / BigInt.from(10).pow(decimals);
      print(
          'adjustedBalanceadjustedBalance${adjustedBalance.toStringAsFixed(CoinListConfig.cryptoDecimal)}');
      return adjustedBalance.toString();
    } catch (e) {
      throw Exception('Error fetching TRON token balance: $e');
    }
  }

  Future<String?> callContractFunction(String functionSelector,
      String hexOwnerAddress, String hexContractAddress, String url,
      [String? parameter]) async {
    final Map<String, dynamic> requestData = {
      'owner_address': hexOwnerAddress, // Wallet address in Hex
      'contract_address': hexContractAddress, // Token contract address in Hex
      'function_selector': functionSelector, // Solidity method
      'parameter': parameter ?? '', // Optional parameter
      'call_value': 0, // Set to 0 for constant methods
    };
    print("requestData::::$requestData");
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("responseData::::$responseData");
      if (responseData['constant_result'] != null &&
          responseData['constant_result'].isNotEmpty) {
        return responseData['constant_result'][0];
      } else {
        throw Exception('Failed to fetch data: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch data: ${response.body}');
    }
  }

  Future<String> evmTokenBalance(AssetModel coinData, String privateKey) async {
    String coinBalance = "0.0";

    if (!isValidHexAddress(coinData.tokenAddress!)) {
      // print('Invalid Ethereum address format: ${coinData.tokenAddress}');
      return coinBalance;
    }

    String rpcURL = coinData.rpcURL!;
    final client = Web3Client(rpcURL, http.Client());
    final tokenAddress = EthereumAddress.fromHex(coinData.tokenAddress!);
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;

    const tokenAbi = '''
    [
      {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},
      {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}
    ]
  ''';

    final contract = DeployedContract(
      ContractAbi.fromJson(tokenAbi, 'Token'), // 'Token' is a placeholder name
      tokenAddress,
    );

    final balanceFunction = contract.function('balanceOf');
    final decimalsFunction = contract.function('decimals');

    try {
      final balanceResult = await client.call(
        contract: contract,
        function: balanceFunction,
        params: [address],
      );
      final decimalsResult = await client.call(
        contract: contract,
        function: decimalsFunction,
        params: [],
      );

      BigInt tokenBalanceWei = balanceResult[0] as BigInt;
      int decimals = (decimalsResult[0] as BigInt).toInt();

      // Calculate the balance in a precise way
      BigInt divisor = BigInt.from(10).pow(decimals);
      BigInt tokenBalance = tokenBalanceWei ~/ divisor; // Whole part
      BigInt remainder = tokenBalanceWei % divisor; // Remainder

      String tokenBalanceFormatted =
          '$tokenBalance.${remainder.toString().padLeft(decimals, '0')}';

      coinBalance = tokenBalanceFormatted;
      print('tokenBalance:::::: $coinBalance');
    } catch (e) {
      // print('Error fetching token balance: $e');
      coinBalance = "0.0";
    }

    return coinBalance;
  }

  bool loadingSol = false;

  Future<String> solanaTokenBalance(
      String Address, String tokenAddress, String networkType) async {
    Solana solana = Solana();
    // print("IIIIII");
    String coinBalance = "0.0";
    await Future.delayed(Duration(seconds: 1), () async {
      SolanaClient client = SolanaClient(
        rpcUrl: Uri.parse(networkType == "Testnet"
            ? apiUrlService.solanaDevnetURL
            : apiUrlService.solanaMainnetURL),
        websocketUrl: Uri.parse(networkType == "Testnet"
            ? apiUrlService.solanaDevnetWS
            : apiUrlService.solanaMainnetWS),
      );
      if (true) {
        try {
          loadingSol = true;
          var tokenInfo = await solana.getTokenInfo(
              address: tokenAddress,
              networktype: networkType == "Testnet"
                  ? NetworkType.Devnet
                  : NetworkType.Mainnet);

          var tr = await client.rpcClient.getTokenAccountsByOwner(
              Address,
              encoding: Encoding.jsonParsed,
              TokenAccountsFilter.byProgramId(
                  '${tokenInfo['value']['owner']}'));

          var transactionJson = tr.toJson();

          List overallTokenBalances = transactionJson['value'];

          int i = overallTokenBalances.indexWhere((v) =>
              v['account']['data']['parsed']['info']["mint"] == tokenAddress);

          final data = tr.toJson()['value'][i]['account']['data']['parsed']
              ['info']['tokenAmount']['uiAmountString'];
          // print('data::::::::::$data');
          coinBalance = data.toString();
        } catch (e) {
          // print("SOLLLLLLL::e$e");
          coinBalance = "0.0";
        }
      }
    });

    return coinBalance;
  }

  Future<String> getTestbtcBalance(String address) async {
    final response = await http.get(
      Uri.parse(
          'https://api.blockcypher.com/v1/btc/test3/addrs/$address/balance?token=${apiKeyService.blockCypherKEY}'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return (data["final_balance"] / 100000000)
          .toStringAsFixed(CoinListConfig.cryptoDecimal);
    } else {
      return "0.0";
    }
  }

  Future<String> getBtcBalance(String address) async {
    final response = await http.get(
      Uri.parse(
          'https://api.blockcypher.com/v1/btc/main/addrs/$address/balance?token=${apiKeyService.blockCypherKEY}'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return (data["final_balance"] / 100000000)
          .toStringAsFixed(CoinListConfig.cryptoDecimal);
    } else {
      return "0.0";
    }
  }

  Future<String> getLitecoinMainnetBalance(String address) async {
    final url =
        Uri.parse('https://api.tatum.io/v3/litecoin/address/balance/$address');
    final headers = {
      'x-api-key':
          't-679cc3141db825b185ad236b-3ba2dc8e1de949ff8fa52fc0' // Use your Tatum API key here
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('Balance: ${result['incoming']} LTC');
      return result['incoming'].toString(); // Return the balance as a string
    } else {
      print('Error fetching balance: ${response.statusCode}');
      return 'Error';
    }
  }

  Future<String> getLitecoinTestnetBalance(String address) async {
    final url =
        Uri.parse('https://api.tatum.io/v3/litecoin/address/balance/$address');
    final headers = {
      'x-api-key':
          't-679cc3141db825b185ad236b-80b6380f557f4fcd9268c908' // Use your Tatum API key here
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('Balance: ${result['incoming']} LTC');
      return result['incoming'].toString(); // Return the balance as a string
    } else {
      print('Error fetching balance: ${response.statusCode}');
      return 'Error';
    }
  }

  Future<String> getTonBalance(String address) async {
    final url = Uri.parse('https://testnet.toncenter.com/api/v2/jsonRPC');

    // Make sure the address is not null or empty
    if (address.isEmpty) {
      return 'Invalid address';
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getAddressBalance",
        "params": {"address": address}, // Address should be in a list
      }),
    );

    // Check if the response status code is 200
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print("data :: $data");
        if (data['ok']) {
          // Ensure the result is in the correct format (it's returned as a String)
          dynamic nanoTonBalance = data['result'];

          // Convert nanoTON to TON
          double tonBalance = double.tryParse(nanoTonBalance.toString()) ?? 0.0;
          tonBalance /= 1000000000.0;

          return tonBalance.toString(); // Return the balance as a string
        } else {
          return 'Error: ${data['error']}';
        }
      } catch (e) {
        // If there is an issue with parsing the response
        print('Error parsing response: $e');
        return 'Error: Unable to parse response';
      }
    } else {
      // If the status code is not 200
      print("Error: ${response.body}");
      return 'Error: ${response.body}';
    }
  }

  Future<String> getTrxBalance(String address) async {
    final response = await http.get(
      Uri.parse(
          'https://apilist.tronscan.org/api/account?address=$address&includeToken=false'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return (data["balance"] / 1000000).toString();
    } else {
      return "0.0";
    }
  }

  Future<String> xrpBalance(String address) async {
    final response = await http.get(
        Uri.parse(
            'https://bithomp.com/api/v2/address/$address?ledgerInfo=true'),
        headers: {"x-bithomp-token": apiKeyService.bithompKEY});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return (double.parse(data["ledgerInfo"]["activated"]
                  ? data["ledgerInfo"]["balance"]
                  : "0") /
              1000000)
          .toString();
    } else {
      return "0.0";
    }
  }

  // Future<String> txrpBalance(String address) async {
  //   XRPHTTPClient? service;
  //   final rpc = await XRPProvider.testNet((httpUri, websocketUri) async {
  //     service = XRPHTTPClient(httpUri, http.Client());
  //     return service!;
  //   });
  //
  //   /// sync
  //   try {
  //     var inf = await rpc.request(XRPRequestAccountInfo(account: address));
  //
  //     // return inf.accountData.balance;
  //     return (double.parse(inf.accountData.balance) / 1000000).toString();
  //
  //     /// catch rpc errors
  //   } on RPCError catch (e) {
  //     // print(e.toString());
  //     return "0.0";
  //   }
  // }

  Future<String> trxTestnetBalance(String address) async {
    final body = jsonEncode({"address": address, "visible": true});
    final response = await http.post(
        Uri.parse('https://nile.trongrid.io/wallet/getaccount'),
        headers: {
          "Content-Type": "application/json",
          "TRON-PRO-API-KEY": apiKeyService.tronproKEY
        },
        body: body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return ((data["balance"] ?? 0) / 1000000).toString();
    } else {
      return "0.0";
    }
  }
}

AssetBalanceFunction assetBalanceFunction = AssetBalanceFunction();

bool isValidHexAddress(String address) {
  final regExp = RegExp(r'^0x[0-9a-fA-F]{40}$');
  return regExp.hasMatch(address);
}
