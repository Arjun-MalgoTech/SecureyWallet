import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:securywallet/Api_Service/ApiUrl_Service.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalanceFunction.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:web3dart/web3dart.dart';

class AssetBalanceModel {
  final AssetModel coin;
  final String balance;

  AssetBalanceModel({required this.coin, required this.balance});
}

class AssetBalance {
  Future<List<String>> fetchBalances(
      List<AssetModel> coins, UserWalletDataModel activeWalletData) async {
    List<Future<String>> futures = [];
    for (var coin in coins) {
      if (coin.coinType == "2") {
        if (coin.rpcURL != "") {
          futures.add(assetBalanceFunction.evmTokenBalance(
              coin, activeWalletData.privateKey));
        } else if (coin.coinType == "2" &&
            (coin.gasPriceSymbol == "SOL" || coin.gasPriceSymbol == "tSOL")) {
          futures.add(assetBalanceFunction.solanaTokenBalance(
              coin.address!, coin.tokenAddress!, coin.network!));
        } else if (coin.coinType == '2' &&
            (coin.gasPriceSymbol == "TRX" || coin.gasPriceSymbol == "tTRX")) {
          final String rpcUrl = coin.gasPriceSymbol == 'TRX'
              ? apiUrlService.TronMainnetRpc
              : apiUrlService.TronTestnetRpc;
          futures.add(assetBalanceFunction.tronTokenBalance(
              rpcUrl: rpcUrl,
              contractAddress: coin.tokenAddress!,
              ownerAddress: coin.address!));
        }
      } else {
        switch (coin.coinSymbol) {
          case "BTC":
            futures.add(assetBalanceFunction.getBtcBalance(coin.address!));
            break;
          case "LTC":
            futures.add(
                assetBalanceFunction.getLitecoinMainnetBalance(coin.address!));
            break;
          case "tLTC":
            futures.add(
                assetBalanceFunction.getLitecoinTestnetBalance(coin.address!));
            break;
          case "tTON":
            futures.add(assetBalanceFunction.getTonBalance(coin.address!));
            break;
          case "TRX":
            futures.add(assetBalanceFunction.getTrxBalance(coin.address!));
            break;
          case "tBTC":
            futures.add(assetBalanceFunction.getTestbtcBalance(coin.address!));
            break;
          case "SOL" || "tSOL":
            futures.add(
                assetBalanceFunction.getSolBalance(coin, activeWalletData));
            break;
          case "XRP":
            futures.add(assetBalanceFunction.xrpBalance(coin.address!));
            break;
          case "tXRP":
            futures.add(assetBalanceFunction.txrpBalance(coin.address!));
            break;
          case "tTRX":
            futures.add(assetBalanceFunction.trxTestnetBalance(coin.address!));
            break;
          case "tDOGE":
            futures.add(
                assetBalanceFunction.getDogecoinTestnetBalance(coin.address!));
            break;
          case "DOGE":
            futures.add(
                assetBalanceFunction.getDogecoinMainnetBalance(coin.address!));
            break;
          case 'tVET':
            futures.add(assetBalanceFunction.tVetBalance(coin.address!));
            break;
          case 'VET':
            futures.add(assetBalanceFunction.VetBalance(coin.address!));
            break;
          default:
            futures.add(assetBalanceFunction.ethBalance(
                coin, activeWalletData.privateKey));
            break;
        }
      }
    }
    return Future.wait(futures);
  }

  Future<Map<String, dynamic>> nvxAPIUSDTPrice(String pair) async {
    Map<String, dynamic> convertedResponse;

    try {
      final response = await http.post(
        Uri.parse("https://api.bitnevex.com/webapi/v1/trade/checkPair"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"pair": pair}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final message = data['Message'];

          convertedResponse = {
            "e": "24hrTicker", // Static field
            "E": DateTime.now()
                .millisecondsSinceEpoch, // Event time (current timestamp)
            "s": pair.replaceAll("_", ""), // Trading pair
            "p": message["changeValue"].toString(), // Price change
            "P": message["changePer"].toString(), // Price change percentage
            "w": message["usdPrice"]
                .toString(), // Weighted average price (mapped to USD price)
            "x": message["lastPrice"]
                .toString(), // Previous close price (mapped to last price)
            "c": message["price"].toString(), // Current close price
            "Q": message["lastVolume"].toString(), // Last quantity
            "b": message["low"]
                .toString(), // Best bid price (mapped to low price)
            "B": message["volume"]
                .toString(), // Best bid quantity (mapped to volume)
            "a": message["high"]
                .toString(), // Best ask price (mapped to high price)
            "A": message["volume_fromCur"]
                .toString(), // Best ask quantity (mapped to volume from currency)
            "o": message["lastPrice"]
                .toString(), // Open price (mapped to last price)
            "h": message["high"].toString(), // High price
            "l": message["low"].toString(), // Low price
            "v": message["volume"]
                .toString(), // Total traded base asset volume (volume)
            "q": (message["volume"] * message["usdPrice"])
                .toString(), // Total traded quote asset volume (calculated)
            "O": DateTime.parse(message["created"])
                .millisecondsSinceEpoch, // Open time (mapped to created timestamp)
            "C": DateTime.now()
                .millisecondsSinceEpoch, // Close time (current timestamp)
            "F": 0, // First trade ID (not available in the response)
            "L": 0, // Last trade ID (not available in the response)
            "n": 0 // Trade count (not available in the response)
          };
        } else {
          // If status is false, set default values
          convertedResponse = getDefaultValues(pair);
        }
      } else {
        // If the response status is not 200, set default values
        convertedResponse = getDefaultValues(pair);
      }
    } catch (e) {
      // In case of an error or exception, return default values
      // print("Error: $e");
      convertedResponse = getDefaultValues(pair);
    }

    print("convertedResponse:::$convertedResponse");
    return convertedResponse;
  }

  Future<Map<String, dynamic>> fetchUSDTPriceData(
      String price, priceChange) async {
    const String url =
        "https://api.coingecko.com/api/v3/simple/price?ids=tether&vs_currencies=usd&include_24hr_change=true";

    try {
      // Make the GET request to the CoinGecko API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response if the request was successful
        final Map<String, dynamic> data = jsonDecode(response.body);
        double price = data['tether']['usd'];
        double priceChange = data['tether']['usd_24h_change'];
        return {
          'price': price,
          'priceChange': priceChange,
        };
      } else {
        throw Exception("Failed to load price data");
      }
    } catch (e) {
      // Handle any errors during the API call
      print("Error fetching USDT Data $e");
      return {
        'price': 0.0,
        'priceChange': 0.0,
      };
    }
  }

  Future<Map<String, dynamic>> getTetherPriceAPI(String pair) async {
    Map<String, dynamic> convertedResponse;

    try {
      final response = await http.get(
        Uri.parse(
            "https://ticker-api.cointelegraph.com/rates/details/tether?fiatSymbol=USD"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        convertedResponse = {
          "e": "24hrTicker", // Static field
          "E": DateTime.now().millisecondsSinceEpoch, // Event time
          "s": pair.replaceAll("_", ""), // Trading pair
          "p": data["change24h"].toString(), // Price change (24h)
          "P": data["change24h"].toString(), // Price change percentage
          "w": data["price"]
              .toString(), // Weighted average price (mapped to current price)
          "x": data["open24h"].toString(), // Previous close price (open 24h)
          "c": data["price"].toString(), // Current close price
          "Q": data["volume24h"]
              .toString(), // Last quantity (mapped to volume 24h)
          "b": data["low24h"].toString(), // Best bid price (low 24h)
          "B": data["volume24h"].toString(), // Best bid quantity (volume 24h)
          "a": data["high24h"].toString(), // Best ask price (high 24h)
          "A": data["volume24h"].toString(), // Best ask quantity (volume 24h)
          "o": data["open24h"].toString(), // Open price (open 24h)
          "h": data["high24h"].toString(), // High price
          "l": data["low24h"].toString(), // Low price
          "v": data["volume24h"]
              .toString(), // Total traded base asset volume (volume 24h)
          "q": (double.parse(data["volume24h"]) * double.parse(data["price"]))
              .toString(), // Total traded quote asset volume
          "O": DateTime.now()
              .subtract(Duration(hours: 24))
              .millisecondsSinceEpoch, // Open time (24 hours ago)
          "C": DateTime.now()
              .millisecondsSinceEpoch, // Close time (current timestamp)
          "F": 0, // First trade ID (not available in response)
          "L": 0, // Last trade ID (not available in response)
          "n": 0 // Trade count (not available in response)
        };
      } else {
        // If response status is not 200, set default values
        convertedResponse = getDefaultValues(pair);
      }
    } catch (e) {
      // In case of an error or exception, return default values
      // print("Error: $e");
      convertedResponse = getDefaultValues(pair);
    }

    print("convertedResponse:::$convertedResponse");
    return convertedResponse;
  }

// Function to return default values with zeros
  Map<String, dynamic> getDefaultValues(String pair) {
    return {
      "e": "24hrTicker",
      "E": DateTime.now().millisecondsSinceEpoch, // Current timestamp
      "s": pair.replaceAll("_", ""), // Trading pair
      "p": "0", // Price change
      "P": "0", // Price change percentage
      "w": "0", // Weighted average price
      "x": "0", // Previous close price
      "c": "0", // Current close price
      "Q": "0", // Last quantity
      "b": "0", // Best bid price
      "B": "0", // Best bid quantity
      "a": "0", // Best ask price
      "A": "0", // Best ask quantity
      "o": "0", // Open price
      "h": "0", // High price
      "l": "0", // Low price
      "v": "0", // Total traded base asset volume
      "q": "0", // Total traded quote asset volume
      "O": 0, // Open time
      "C": 0, // Close time
      "F": 0, // First trade ID
      "L": 0, // Last trade ID
      "n": 0 // Trade count
    };
  }
}

AssetBalance assetBalance = AssetBalance();

Future<int> getDecimals(Web3Client client, DeployedContract contract) async {
  final decimalsFunction = contract.function('decimals');
  final result = await client
      .call(contract: contract, function: decimalsFunction, params: []);
  return (result[0] as BigInt).toInt();
}

bool isValidHexAddress(String address) {
  final regExp = RegExp(r'^0x[0-9a-fA-F]{40}$');
  return regExp.hasMatch(address);
}
