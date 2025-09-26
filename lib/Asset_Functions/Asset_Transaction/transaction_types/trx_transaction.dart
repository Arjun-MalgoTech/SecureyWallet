// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:json_bigint/json_bigint.dart';
// import 'package:on_chain/tron/src/keys/private_key.dart';
// import 'package:blockchain_utils/blockchain_utils.dart';
// import 'package:http/http.dart' as http;
// import 'package:securywallet/Api_Service/Apikey_Service.dart';
// import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
// import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
// import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
// import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
// import 'package:securywallet/UserWalletData/UserWalletData.dart';
//
// import 'Hex_Bytes.dart';
//
// class TrxTransaction {
//   Future<void> sendTestnet(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     final tronDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.tron).deriveDefaultPath;
//     final tronPrivateKey =
//         TronPrivateKey.fromBytes(tronDefaultPath.privateKey.raw);
//     const String apiUrl = "https://nile.trongrid.io/wallet/createtransaction";
//
//     // Parse the amount as a double and multiply by 1,000,000
//     double amount = double.parse(enterAmount);
//     int value = (amount * 1000000).toInt();
//
//     var requestBody = jsonEncode({
//       "owner_address": tronPrivateKey.publicKey().toAddress().toAddress(),
//       "to_address": toAddress,
//       "amount": value,
//       "visible": true
//     });
//
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "TRON-PRO-API-KEY": apiKeyService.tronproKEY
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: requestBody,
//       );
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var decodeTxn = jsonDecode(response.body);
//
//         // Check for null or missing 'raw_data_hex'
//         String? rawDataHex = decodeTxn["raw_data_hex"];
//         if (rawDataHex == null) {
//           throw Exception("Missing 'raw_data_hex' in response");
//         }
//
//         var sign = tronPrivateKey.sign(hexBytes.hexToBytes(rawDataHex));
//         var signature = [hexBytes.bytesToHex(Uint8List.fromList(sign))];
//         decodeTxn["signature"] = signature;
//
//         if (context.mounted) {
//           print(jsonEncode(decodeTxn));
//           trxTestnetSendAmount(
//               decodeTxn, context, coinData, userWallet, toAddress, enterAmount);
//         }
//       } else {
//         throw Exception(
//             "Failed to create transaction. Status code: ${response.statusCode}");
//       }
//     } catch (error) {
//       // print('Error sending transaction: $error');
//     }
//   }
//
//   trxTestnetSendAmount(
//       var data,
//       BuildContext context,
//       AssetModel coinData,
//       UserWalletDataModel userWallet,
//       String toAddress,
//       String enterAmount) async {
//     Map<String, dynamic> body = data;
//     // print(
//     //     'edrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
//     try {
//       String jsonBody = encodeJson(body);
//       Map<String, String> headers = {
//         "Content-Type": "application/json",
//         "TRON-PRO-API-KEY": apiKeyService.tronproKEY
//       };
//       final response = await post(
//         Uri.parse("https://nile.trongrid.io/wallet/broadcasttransaction"),
//         headers: headers,
//         body: jsonBody,
//       );
//       print('rrrrrr$response');
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = jsonDecode(response.body);
//         print('rrrrrr$responseData');
//         if (responseData["result"] && context.mounted) {
//           await StoreHashDetails().hashDetails(
//               hash: responseData["txid"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => AppBottomNav()),
//                 (route) => false);
//           }
//         }
//       } else {
//         throw Exception('Failed to make POST request: ${response.body}');
//       }
//     } catch (error) {
//       // print('Error making POST request: $error');
//       rethrow;
//     }
//   }
//
//   sendMainnet(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     // print(
//     //     'edrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
//     final tronDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.tron).deriveDefaultPath;
//     final tronPrivateKey =
//         TronPrivateKey.fromBytes(tronDefaultPath.privateKey.raw);
//     const String apiUrl = "https://api.trongrid.io/wallet/createtransaction";
//
//     int value = int.parse(enterAmount);
//
//     var requestBody = jsonEncode({
//       "owner_address": tronPrivateKey.publicKey().toAddress().toAddress(),
//       "to_address": toAddress,
//       "amount": value * 1000000,
//       "visible": true
//     });
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "TRON-PRO-API-KEY": apiKeyService.tronproKEY
//     };
//     try {
//       final response = await post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: requestBody,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var decodeTxn = jsonDecode(response.body);
//         var sign =
//             tronPrivateKey.sign(hexBytes.hexToBytes(decodeTxn["raw_data_hex"]));
//         var signature = [hexBytes.bytesToHex(Uint8List.fromList(sign))];
//         decodeTxn.addAll({"signature": signature});
//         if (context.mounted) {
//           print(jsonEncode(decodeTxn));
//           trxMainnetSendAmount(
//               decodeTxn, context, coinData, userWallet, toAddress, enterAmount);
//         }
//       } else {
//         // print('Error: ${response.statusCode}');
//         // print('Response body: ${response.body}');
//       }
//     } catch (error) {
//       // print('Error sending transaction: $error');
//     }
//   }
//
//   trxMainnetSendAmount(
//       var data,
//       BuildContext context,
//       AssetModel coinData,
//       UserWalletDataModel userWallet,
//       String toAddress,
//       String enterAmount) async {
//     Map<String, dynamic> body = data;
//     try {
//       String jsonBody = encodeJson(body);
//       Map<String, String> headers = {
//         "Content-Type": "application/json",
//         "TRON-PRO-API-KEY": apiKeyService.tronproKEY
//       };
//       final response = await post(
//         Uri.parse("https://api.trongrid.io/wallet/broadcasttransaction"),
//         headers: headers,
//         body: jsonBody,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = jsonDecode(response.body);
//         // print(responseData);
//         if (responseData["result"] && context.mounted) {
//           await StoreHashDetails().hashDetails(
//               hash: responseData["txid"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => AppBottomNav()),
//                 (route) => false);
//           }
//         }
//       } else {
//         throw Exception('Failed to make POST request: ${response.body}');
//       }
//     } catch (error) {
//       // print('Error making POST request: $error');
//       rethrow;
//     }
//   }
// }
