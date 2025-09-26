// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:bip39/bip39.dart' as bip39;
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'package:on_chain/tron/src/keys/private_key.dart';
// import 'package:blockchain_utils/blockchain_utils.dart';
// import 'package:http/http.dart' as http;
// import 'package:securywallet/Api_Service/Apikey_Service.dart';
// import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/TronUtils.dart';
// import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
// import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
// import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
// import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
// import 'package:securywallet/UserWalletData/UserWalletData.dart';
//
// import 'Hex_Bytes.dart';
//
// class TrxTokenTransaction {
//   Future<void> send({
//     required BuildContext context,
//     required AssetModel coinData,
//     required String enterAmount,
//     required String toAddress,
//     required UserWalletDataModel userWallet,
//     required String mnemonic,
//     required double amount,
//     required String tokenContractAddress,
//   }) async {
//     try {
//       // Step 1: Generate the private key from the mnemonic
//       final seed = bip39.mnemonicToSeed(mnemonic);
//       final privateKeyHex = hex.encode(seed.sublist(0, 32)); // First 32 bytes
//
//       // Step 2: Validate recipient address
//       final toAddressHex = TronUtils.base58ToHex(toAddress).padLeft(64, '0');
//       if (!_isValidHex(toAddressHex)) {
//         throw Exception("Invalid recipient address format.");
//       }
//
//       // Step 3: Format the transfer data
//       final transferMethodId =
//           "a9059cbb"; // `transfer(address,uint256)` function selector
//       final amountBigInt = BigInt.from(amount *
//           pow(10, int.parse(coinData.tokenDecimal!))
//               .toDouble()); // Convert to smallest unit (SUN)
//       final amountHex = amountBigInt.toRadixString(16).padLeft(64, '0');
//
//       if (!_isValidHex(amountHex)) {
//         throw Exception("Invalid amount format.");
//       }
//       //transferMethodId +
//       final dataPayload = toAddressHex + amountHex;
//       print("dataPayload::::::::$dataPayload");
//       // Step 4: Build the transaction request body
//       final tronPrivateKey = _getTronPrivateKey(seed);
//       final requestBody = {
//         "owner_address": tronPrivateKey.publicKey().toAddress().toAddress(),
//         "contract_address": tokenContractAddress,
//         "function_selector": "transfer(address,uint256)",
//         "parameter": dataPayload,
//         "fee_limit": 100000000, // Gas fee limit
//         "call_value": 0, // No TRX transfer
//         "visible": true,
//       };
//
//       print(jsonEncode(requestBody));
//
//       // Step 5: Create transaction via TRON API
//       final createTransactionResponse =
//           await _createTransaction(requestBody, coinData);
//       print('createTransactionResponse : $createTransactionResponse');
//       if (createTransactionResponse == null) {
//         throw Exception("Transaction creation failed.");
//       }
//
//       // Step 6: Sign the transaction
//       final rawDataHex =
//           createTransactionResponse['transaction']?['raw_data_hex'];
//       if (rawDataHex == null) {
//         throw Exception("Missing 'raw_data_hex' in response.");
//       }
//
//       print('rawDataHex: $rawDataHex');
//       print('tronPrivateKey: $tronPrivateKey');
//
//       final signedTransaction =
//           await _signTransaction(rawDataHex, tronPrivateKey);
//
//       var createtxRes = createTransactionResponse['transaction'];
//       createtxRes.addAll({
//         "signature": [signedTransaction]
//       });
//
//       print("createtxRes::${createtxRes["signature"]}");
//       // Step 7: Broadcast the signed transaction
//       final result = await _broadcastTransaction(createtxRes, coinData);
//       if (result["result"] == true) {
//         await StoreHashDetails().hashDetails(
//             hash: result["txid"].toString(),
//             fromAddress: coinData.address!,
//             coinData: coinData,
//             toAddress: toAddress,
//             amount: enterAmount);
//         Utils.snackBar("Transaction is proceed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => AppBottomNav()),
//             (route) => false);
//         print("Transaction successful! TXID: ${result["txid"].toString()}");
//         // Optional: Add your post-transaction logic here (e.g., storing the hash)
//       } else {
//         Utils.snackBarErrorMessage("Transaction is failed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => AppBottomNav()),
//             (route) => false);
//         throw Exception("Transaction failed: ${result["error"]}");
//       }
//     } catch (e) {
//       print('Error: $e');
//       rethrow;
//     }
//   }
//
// // Helper function to create the transaction
//   Future<Map<String, dynamic>?> _createTransaction(
//       Map<String, dynamic> requestBody, AssetModel coinData) async {
//     final url = coinData.gasPriceSymbol == 'TRX'
//         ? "https://api.trongrid.io/wallet/triggersmartcontract"
//         : "https://nile.trongrid.io/wallet/triggersmartcontract";
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "TRON-PRO-API-KEY": apiKeyService.tronproKEY, // Use actual API key
//         },
//         body: jsonEncode(requestBody),
//       );
//       print(url);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception(
//             "Failed to create transaction. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error in transaction creation: $e");
//       return null;
//     }
//   }
//
// // Helper function to sign the transaction
//   String _signTransaction(String rawDataHex, TronPrivateKey tronPrivateKey) {
//     try {
//       if (rawDataHex == null || rawDataHex.isEmpty) {
//         print("rawDataHex is null or empty!");
//         throw Exception("rawDataHex is null or empty!");
//       }
//       final sign = tronPrivateKey.sign(hexBytes.hexToBytes(rawDataHex));
//       return hexBytes.bytesToHex(Uint8List.fromList(sign));
//     } catch (e) {
//       print("Error in signing the transaction: $e");
//       throw Exception("Transaction signing failed.");
//     }
//   }
//
// // Helper function to broadcast the transaction
//   Future<Map<String, dynamic>> _broadcastTransaction(
//       var signedTransaction, AssetModel coinData) async {
//     try {
//       // Map<String, dynamic> requestBody = {
//       //   "transaction": signedTransaction,
//       // };
//       final url = coinData.gasPriceSymbol == "TRX"
//           ? "https://api.trongrid.io/wallet/broadcasttransaction"
//           : "https://nile.trongrid.io/wallet/broadcasttransaction";
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "TRON-PRO-API-KEY":
//               'b762cc80-de25-458d-8993-d28c5ea28926', // Use actual API key
//         },
//         body: jsonEncode(signedTransaction),
//       );
//       print('url;;;;;;;;$url');
//       print('response.statusCode;;;;;;;;${response.statusCode}');
//       print('requestBody;;;;;;;;$signedTransaction');
//       print('jsonEncode(requestBody);;;;;;;;${jsonEncode(signedTransaction)}');
//       print('signedTransaction;;;;;;;;$signedTransaction');
//       print('response.body;;;;;;;;${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception(
//             "Failed to broadcast transaction. Status code: ${response.statusCode}, Response: ${response.body}");
//       }
//     } catch (e) {
//       print("Error in broadcasting the transaction: $e");
//       throw Exception("Transaction broadcasting failed.");
//     }
//   }
// }
//
// bool _isValidHex(String hexString) {
//   final validHexPattern = RegExp(r'^[0-9a-fA-F]+$');
//   return validHexPattern.hasMatch(hexString);
// }
//
// // Get TRON private key from seed
// TronPrivateKey _getTronPrivateKey(List<int> seed) {
//   final tronDefaultPath =
//       Bip44.fromSeed(seed, Bip44Coins.tron).deriveDefaultPath;
//   return TronPrivateKey.fromBytes(tronDefaultPath.privateKey.raw);
// }
