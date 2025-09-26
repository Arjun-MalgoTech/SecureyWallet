import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:web3dart/web3dart.dart';

class TransactionService extends ChangeNotifier {
  bool isLoading = false;

  List<Map<String, dynamic>> balanceList = [];

  setLoading(bool loader) {
    isLoading = loader;
    notifyListeners();
  }

  setBalance(List<Map<String, dynamic>> data) {
    balanceList = data;
    notifyListeners();
  }

  getBalance(List<AssetModel> coinData, String privateKey) async {
    setLoading(true);

    try {
      List<Future<Map<String, dynamic>>> futures = [];

      for (var coin in coinData) {
        String rpcUrl = coin.rpcURL!;
        final client = Web3Client(rpcUrl, Client());
        final credentials = EthPrivateKey.fromHex(privateKey);
        final address = credentials.address;

        futures.add(client.getBalance(address).then((balance) {
          var coinBalance =
              (balance.getInWei / BigInt.from(1000000000000000000))
                  .toStringAsFixed(CoinListConfig.cryptoDecimal);
          return {"symbol": coin.coinSymbol, "balance": coinBalance};
        }).catchError((e) {
          return {"symbol": coin.coinSymbol, "balance": '0.0'};
        }));
      }

      List<Map<String, dynamic>> results = await Future.wait(futures);

      setBalance(results);
    } catch (e) {
      print(" Error fetching balance : $e");
      // Handle error
    }

    setLoading(false);
  }

// Function to check if a string is a valid hexadecimal Ethereum address
  bool isValidHexAddress(String address) {
    final regExp = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return regExp.hasMatch(address);
  }
}

// Function to get the number of decimal places for the token
Future<int> getDecimals(Web3Client client, DeployedContract contract) async {
  final decimalsFunction = contract.function('decimals');
  final result = await client
      .call(contract: contract, function: decimalsFunction, params: []);
  return (result[0] as BigInt).toInt();
}
