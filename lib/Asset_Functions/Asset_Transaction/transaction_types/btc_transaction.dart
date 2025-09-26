import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
import 'package:http/http.dart';
import 'package:json_bigint/json_bigint.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:securywallet/Api_Service/ApiUrl_Service.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/btc_generator.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';

import 'Hex_Bytes.dart';

class BtcTransaction {
  sendTestnet(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    String apiUrl = apiUrlService.btcTestnetApiUrl;

    double value = double.parse(enterAmount);

    BigInt satoshiAmount = BigInt.from((value * 100000000).toInt());
    Map<String, Object> requestBody = {
      "inputs": [
        {
          "addresses": [btcTestnet(userWallet.mnemonic)]
        }
      ],
      "outputs": [
        {
          "addresses": [toAddress],
          "value": satoshiAmount
        }
      ],
      "confirmations": 7,
      "preference": "low",
    };
    final encSettings = EncoderSettings(
      indent: "  ",
      singleLineLimit: 30,
      afterKeyIndent: " ",
    );
    String requestBodyJson = encodeJson(requestBody, settings: encSettings);

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    try {
      final response = await post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBodyJson,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var newtx = jsonDecode(response.body);
        newtx.addAll({"pubkeys": []});
        newtx.addAll({"signatures": []});
        List tosign = newtx["tosign"];

        String seedPhrase = userWallet.mnemonic.trim();
        var seed = bip39.mnemonicToSeed(seedPhrase);
        final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
        var privateKey = wallet.derivePath("m/84'/1'/0'/0/0").toWIF();
        final keyPair = btc.ECPair.fromWIF(privateKey);

        for (var sign in tosign) {
          newtx["pubkeys"].add(hexBytes.bytesToHex(keyPair.publicKey));
          print(newtx["pubkeys"]);
          var s = keyPair.sign(hexBytes.hexToBytes(sign));
          var fsig = hexBytes.bytesToHex(btc.encodeSignature(s, 1));

          newtx["signatures"].add(fsig);
          print(newtx["signatures"]);
        }

        if (context.mounted) {
          btcTestnetSendAmount(
              newtx, context, coinData, userWallet, toAddress, enterAmount);
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // print('Error sending transaction: $error');
    }
  }

  btcTestnetSendAmount(
      var data,
      BuildContext context,
      AssetModel coinData,
      UserWalletDataModel userWallet,
      String toAddress,
      String enterAmount) async {
    Map<String, dynamic> body = data;
    try {
      String jsonBody = encodeJson(body);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      final response = await post(
        Uri.parse(apiUrlService.btcTestnetSendApiUrl),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        // print('wefvev');
        print(responseData);
        if (context.mounted) {
          await StoreHashDetails().hashDetails(
              hash: responseData["tx"]["hash"].toString(),
              fromAddress: coinData.address!,
              coinData: coinData,
              toAddress: toAddress,
              amount: enterAmount);
          if (context.mounted) {
            Utils.snackBar("Transaction is proceed");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => AppBottomNav()),
                (route) => false);
          }
        }
      } else {
        throw Exception('Failed to make POST request: ${response.body}');
      }
    } catch (error) {
      print('Error making POST request: $error');
      rethrow;
    }
  }

  sendMainnet(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    String apiUrl = apiUrlService.btcMainnetApiUrl;

    double value = double.parse(enterAmount);

    BigInt satoshiAmount = BigInt.from((value * 100000000).toInt());
    Map<String, Object> requestBody = {
      "inputs": [
        {
          "addresses": [btcMainnet(userWallet.mnemonic)]
        }
      ],
      "outputs": [
        {
          "addresses": [toAddress],
          "value": satoshiAmount
        }
      ],
      "confirmations": 2,
      "preference": "low",
    };
    final encSettings = EncoderSettings(
      indent: "  ",
      singleLineLimit: 30,
      afterKeyIndent: " ",
    );
    // Convert request body to JSON
    String requestBodyJson = encodeJson(requestBody, settings: encSettings);

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    try {
      final response = await post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBodyJson,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var newtx = jsonDecode(response.body);
        newtx.addAll({"pubkeys": []});
        newtx.addAll({"signatures": []});
        List tosign = newtx["tosign"];

        String seedPhrase = userWallet.mnemonic.trim();
        var seed = bip39.mnemonicToSeed(seedPhrase);
        final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
        var privateKey = wallet.derivePath("m/84'/0'/0'/0/0").toWIF();
        final keyPair = btc.ECPair.fromWIF(privateKey);

        for (var sign in tosign) {
          newtx["pubkeys"].add(hexBytes.bytesToHex(keyPair.publicKey));
          var s = keyPair.sign(hexBytes.hexToBytes(sign));
          var fsig = hexBytes.bytesToHex(btc.encodeSignature(s, 1));

          newtx["signatures"].add(fsig);
        }

        if (context.mounted) {
          btcMainnetSendAmount(
              newtx, context, coinData, userWallet, toAddress, enterAmount);
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error sending transaction: $error');
    }
  }

  btcMainnetSendAmount(
      var data,
      BuildContext context,
      AssetModel coinData,
      UserWalletDataModel userWallet,
      String toAddress,
      String enterAmount) async {
    Map<String, dynamic> body = data;
    try {
      String jsonBody = encodeJson(body);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      final response = await post(
        Uri.parse(apiUrlService.btcMainnetSendApiUrl),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        // print(responseData);
        if (context.mounted) {
          await StoreHashDetails().hashDetails(
              hash: responseData["tx"]["hash"].toString(),
              fromAddress: coinData.address!,
              coinData: coinData,
              toAddress: toAddress,
              amount: enterAmount);
          if (context.mounted) {
            Utils.snackBar("Transaction is proceed");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => AppBottomNav()),
                (route) => false);
          }
        }
      } else {
        throw Exception('Failed to make POST request: ${response.body}');
      }
    } catch (error) {
      // print('Error making POST request: $error');
      rethrow;
    }
  }
}
