import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';

import 'package:web3dart/web3dart.dart';

class AssetTransactionAPI extends ChangeNotifier {
  bool isLoading = false;

  List<Map<String, dynamic>> assetBalanceList = [];

  setLoading(bool loader) {
    isLoading = loader;
    notifyListeners();
  }

  setBalance(List<Map<String, dynamic>> data) {
    assetBalanceList = data;
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
      notifyListeners();
    } catch (e) {
      // Handle error
    }

    setLoading(false);
  }
}
