// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hex/hex.dart';
// import 'package:bip39/bip39.dart' as bip39;
// import 'package:http/http.dart' as http;
// import 'package:nvwallet/Api_Service/ApiUrl_Service.dart';
// import 'package:nvwallet/Api_Service/Apikey_Service.dart';
// import 'package:nvwallet/Asset_Functions/XrpHttpClient.dart';
// import 'package:nvwallet/UserWalletData/UserWalletData.dart';
// import 'package:pointycastle/export.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bitcoin/flutter_bitcoin.dart' as btc;
// import 'package:http/http.dart';
// import 'package:json_bigint/json_bigint.dart';
// import 'package:on_chain/tron/src/keys/private_key.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:solana_web3/programs.dart';
// import 'package:solana_web3/solana_web3.dart' as sol;
// import 'package:thor_request_dart/connect.dart' as wallet;
// import 'package:thor_request_dart/wallet.dart' as thor_wallet;
// import 'package:web3dart/web3dart.dart';
// import 'package:bip32/bip32.dart' as bip32;
// import 'package:blockchain_utils/blockchain_utils.dart';
// import 'package:xrpl_dart/xrpl_dart.dart';
// import 'package:http/http.dart' as http;
// import 'package:solana/src/solana_client.dart';
// import 'package:solana/src/programs/token_program/solana_client_ext.dart';
// import 'package:solana_wallet/src/type.dart';
// import 'package:solana/src/crypto/ed25519_hd_public_key.dart';
// import 'package:solana/src/crypto/ed25519_hd_keypair.dart';
// import 'package:solana/solana.dart' as sol;
// import 'package:cryptography/cryptography.dart' as crypto;
//
// import '../../Screens/pre_home_screen/Model/Asset_Model/Asset_Model.dart';
// import '../../crypto_utils/appToastMsg/AppToast.dart';
//
// class CoinTransaction {
//   GetHashStorage getHashStorage = GetHashStorage();
//   dynamic xPub;
//   void processTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet,
//       required String privateKeyHex,
//       required String contractAddress,
//       required String rpcUrl}) async {
//     if (coinData.coinSymbol == 'tVET' && coinData.coinType == '3') {
//       tVETTransaction(context,
//           coinData: coinData,
//           enterAmount: enterAmount,
//           toAddress: toAddress,
//           userWallet: userWallet);
//     }
//     if (coinData.coinSymbol == 'VET' && coinData.coinType == '3') {
//       VETTransaction(context,
//           coinData: coinData,
//           enterAmount: enterAmount,
//           toAddress: toAddress,
//           userWallet: userWallet);
//     }
//     if (coinData.coinType == "2") {
//       if (coinData.rpcURL != "") {
//         await evmTokenTransaction(context,
//             coinData: coinData,
//             enterAmount: enterAmount,
//             toAddress: toAddress,
//             userWallet: userWallet);
//       } else if (coinData.coinType == "2" &&
//           (coinData.gasPriceSymbol == "SOL" ||
//               coinData.gasPriceSymbol == "tSOL")) {
//         await solanaTokenTransaction(context,
//             coinData: coinData,
//             enterAmount: num.parse(enterAmount),
//             toAddress: toAddress,
//             userWallet: userWallet);
//       } else if (coinData.coinType == "2" &&
//           (coinData.gasPriceSymbol == "TRX" ||
//               coinData.gasPriceSymbol == "tTRX")) {
//         await trxTestnetTokenTransaction(
//             context: context,
//             toAddress: toAddress,
//             tokenContractAddress: contractAddress,
//             mnemonic: userWallet.mnemonic,
//             amount: double.parse(enterAmount),
//             coinData: coinData,
//             enterAmount: enterAmount,
//             userWallet: userWallet);
//       }
//     } else {
//       switch (coinData.coinSymbol) {
//         case 'tBTC':
//           await btcTestnetTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'BTC':
//           await btcMainnetTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'tTRX':
//           await trxTestnetTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'TRX':
//           await trxMainnetTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'tSOL':
//           await solanaTestnetTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'SOL':
//           await solanaTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'XRP' || 'tXRP':
//           await xrpTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//         case 'DOGE' || 'tDOGE':
//           await sendDogecoinTransaction(
//               fromAddress: coinData.address!,
//               privateKey: privateKeyHex,
//               toAddress: toAddress,
//               amount: double.parse(enterAmount),
//               xpub:
//                   "xprv9s21ZrQH143K3gbA7pWuWUEKNxfQ7pD9dUDr4956idmkKNqPVXbhqVW19wR8qboUheCK91KV7jt8qbvqwSTWKxd6L1zVdbcEMFxzthZs1ve",
//               index: 0);
//           break;
//         case 'LTC' || 'tLTC':
//           await sendLitecoinTransaction(
//               privateKeyWIF: privateKeyHex,
//               fromAddress: coinData.address!,
//               toAddress: toAddress,
//               amountSatoshis: int.parse(enterAmount),
//               feeSatoshis: 500);
//           break;
//         case "tTON":
//           await sendTonTransaction(
//               coinData.address!, toAddress, enterAmount, privateKeyHex);
//         default:
//           await evmTransaction(context,
//               coinData: coinData,
//               enterAmount: enterAmount,
//               toAddress: toAddress,
//               userWallet: userWallet);
//           break;
//       }
//     }
//   }
//
//   Future storeHashDetails(
//       {required String hash,
//       required String fromAddress,
//       required CoinModel coinData,
//       required String toAddress,
//       required String amount}) async {
//     await getHashStorage.updateHashToList(
//         "$fromAddress${coinData.coinType}${coinData.coinType == "2" ? coinData.tokenAddress : ""}${coinData.coinSymbol}${coinData.coinName}",
//         {
//           "hash": hash,
//           "toAddress": toAddress,
//           "amount": amount,
//           "time": DateTime.now().millisecondsSinceEpoch
//         });
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var status = prefs.getBool(AppConstant.notificationStatus) ?? true;
//     // bool notificationStatus = true;
//     if (status) {
//       var urlLink = "";
//       if (coinData.gasPriceSymbol == "TRX" ||
//           coinData.gasPriceSymbol == "tTRX") {
//         urlLink = "${coinData.explorerURL!}transaction/$hash";
//       } else if (coinData.gasPriceSymbol == "tSOL") {
//         urlLink = "${coinData.explorerURL!}tx/$hash?cluster=devnet";
//       } else if (coinData.gasPriceSymbol == "DCX") {
//         urlLink = "${coinData.explorerURL!}/tx/$hash";
//       } else if (coinData.rpcURL == 'https://mainnetcoin.d-ecosystem.io/' &&
//           coinData.coinType == '2') {
//         urlLink = "${coinData.explorerURL!}/tx/$hash";
//       } else if (coinData.coinSymbol == "tXRP" ||
//           coinData.coinSymbol == "XRP") {
//         urlLink = "${coinData.explorerURL!}transactions/$hash";
//       } else if (coinData.coinSymbol == "tBTC" ||
//           coinData.coinSymbol == "BTC") {
//         urlLink = "${coinData.explorerURL!}tx/$hash";
//       } else {
//         urlLink = "${coinData.explorerURL!}/tx/$hash";
//       }
//       await showNotificationWithLink(
//           id: DateTime.now().millisecondsSinceEpoch,
//           title: 'Transaction is processed ✅',
//           body: '$amount ${coinData.coinSymbol} is sent to $toAddress',
//           url: urlLink);
//     }
//   }
//
//   Future<void> showNotificationWithLink(
//       {required int id,
//       required String title,
//       required String body,
//       required String url}) async {
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'This channel is used for notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const DarwinNotificationDetails iosNotificationDetails =
//         DarwinNotificationDetails();
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       Random().nextInt(9999 + 1), // Notification ID
//       title, // Title
//       body, // Body
//       notificationDetails,
//       payload: url, // Link as payload
//     );
//   }
//
//   evmTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     String rpcUrl = coinData.rpcURL!;
//
//     final client = Web3Client(rpcUrl, Client());
//     final credentials = EthPrivateKey.fromHex(userWallet.privateKey);
//     final address = credentials.address;
//     double amt = double.parse(enterAmount);
//     print("Notify-------------------------------------------------------");
//     // Convert the amount to Wei
//     String amountStr = enterAmount;
//
//     BigInt weiAmount = etherToWei(amountStr);
//     final amount = EtherAmount.inWei(weiAmount);
//     // print('amount:::????:::::::::$amount');
//
//     final chainID = await client.getChainId();
//     final gasEstimate = await client.estimateGas(
//       sender: address,
//       to: EthereumAddress.fromHex(toAddress),
//       value: amount,
//     );
//     // print('gasEstimate:::????:::::::::$gasEstimate');
//     final transaction = Transaction(
//       from: address,
//       to: EthereumAddress.fromHex(toAddress),
//       maxGas: gasEstimate.toInt(), // Set gas limit
//       value: amount, // Set value to send (1 ETC)
//     );
//
//     final signedTransaction = await client
//         .signTransaction(credentials, transaction, chainId: chainID.toInt());
//
//     try {
//       final response = await client.sendRawTransaction(signedTransaction);
//       // print('Transaction hash: ${response}');
//       await storeHashDetails(
//           hash: response.toString(),
//           fromAddress: userWallet.walletAddress,
//           coinData: coinData,
//           toAddress: toAddress,
//           amount: enterAmount);
//       if (context.mounted) {
//         Utils.snackBar("Transaction is proceed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     } on Exception catch (e) {
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Transaction failed");
//         print('$e');
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     }
//     await client.dispose();
//   }
//
//   Uint8List fromHex(String hex) {
//     final length = hex.length ~/ 2;
//     final result = Uint8List(length);
//
//     for (int i = 0; i < length; i++) {
//       result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
//     }
//
//     return result;
//   }
//
//   VETTransaction(
//     BuildContext context, {
//     required AssetModel coinData,
//     required String toAddress,
//     required UserWalletDataModel userWallet,
//     required String enterAmount,
//   }) async {
//     var connector = wallet.Connect(apiUrlService.VETTransactionUrl);
//
//     var _sender = thor_wallet.Wallet.fromMnemonic([userWallet.mnemonic]);
//     BigInt tVETBalance = await connector.getVthoBalance(
//         coinData.address!); // Assuming it returns Future<BigInt>
//
//     // Assuming the balance needs to be divided by 10^18 to get the actual value in human-readable format
//     BigInt base =
//         BigInt.from(pow(10, 18)); // For 18 decimal places (adjust if needed)
//     double balanceInVet = tVETBalance.toDouble() / base.toDouble();
//
//     // Format the balance to 6 decimal places
//     String formattedBalance = balanceInVet.toString();
//     print("formattedBalance $formattedBalance");
// // gas payer wallet
//     var _payer = thor_wallet.Wallet.fromPrivateKey(userWallet.privateKey);
//     BigInt amount = BigInt.from(double.parse(enterAmount));
//     print("amount $amount");
//
//     BigInt valueInWei = amount * BigInt.from(10).pow(12);
//
//     print('valueInWei $valueInWei');
//     final tx = await connector.transferVet(_sender, toAddress,
//         value: valueInWei, gasPayer: _payer);
//
//     // final tx1 = await connector.transferVtho(
//     //   _sender,
//     //   toAddress,
//     // );
//     print("tx  ${tx["id"]}");
//     await storeHashDetails(
//         hash: tx["id"].toString(),
//         fromAddress: coinData.address!,
//         coinData: coinData,
//         toAddress: toAddress,
//         amount: enterAmount.toString());
//     if (context.mounted) {
//       Utils.snackBar("Transaction is proceed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => BottomNavBar()),
//           (route) => false);
//     } else {
//       Utils.snackBarErrorMessage("Transaction is failed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => BottomNavBar()),
//           (route) => false);
//     }
//
//     return;
//   }
//
//   tVETTransaction(
//     BuildContext context, {
//     required AssetModel coinData,
//     required String toAddress,
//     required UserWalletDataModel userWallet,
//     required String enterAmount,
//   }) async {
//     var connector = wallet.Connect(apiUrlService.tVETTransactionUrl);
//
//     var _sender = thor_wallet.Wallet.fromMnemonic([userWallet.mnemonic]);
//     BigInt tVETBalance = await connector.getVthoBalance(
//         coinData.address!); // Assuming it returns Future<BigInt>
//
//     // Assuming the balance needs to be divided by 10^18 to get the actual value in human-readable format
//     BigInt base =
//         BigInt.from(pow(10, 18)); // For 18 decimal places (adjust if needed)
//     double balanceInVet = tVETBalance.toDouble() / base.toDouble();
//
//     // Format the balance to 6 decimal places
//     String formattedBalance = balanceInVet.toString();
//     print("formattedBalance $formattedBalance");
// // gas payer wallet
//     var _payer = thor_wallet.Wallet.fromPrivateKey(userWallet.privateKey);
//     BigInt amount = BigInt.from(double.parse(enterAmount));
//     print("amount $amount");
//
//     BigInt valueInWei = amount * BigInt.from(10).pow(12);
//
//     print('valueInWei $valueInWei');
//     final tx = await connector.transferVet(_sender, toAddress,
//         value: valueInWei, gasPayer: _payer);
//
//     // final tx1 = await connector.transferVtho(
//     //   _sender,
//     //   toAddress,
//     // );
//     print("tx  ${tx["id"]}");
//     await storeHashDetails(
//         hash: tx["id"].toString(),
//         fromAddress: coinData.address!,
//         coinData: coinData,
//         toAddress: toAddress,
//         amount: enterAmount.toString());
//     if (context.mounted) {
//       Utils.snackBar("Transaction is proceed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => BottomNavBar()),
//           (route) => false);
//     } else {
//       Utils.snackBarErrorMessage("Transaction is failed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => BottomNavBar()),
//           (route) => false);
//     }
//
//     return;
//   }
//
//   evmTokenTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     String rpcUrl = coinData.rpcURL!;
//     print('rpcUrl $rpcUrl');
//     print('tokenDecimal ${coinData.tokenDecimal}');
//     final client = Web3Client(rpcUrl, Client());
//     final credentials = EthPrivateKey.fromHex(userWallet.privateKey);
//     final address = credentials.address;
//
//     // Token contract details
//     EthereumAddress tokenAddress =
//         EthereumAddress.fromHex(coinData.tokenAddress!);
//     final contract = DeployedContract(
//       ContractAbi.fromJson(
//           '[{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]',
//           ''),
//       tokenAddress,
//     );
//
//     // Convert the entered amount to a double
//     double amt = double.parse(enterAmount);
//
// // Convert the amount to Wei
//     String amountStr = enterAmount;
//
//     BigInt weiAmount =
//         etherTokenToWei(amountStr, int.parse(coinData.tokenDecimal!));
//     print("weiAmount $weiAmount");
//
//     var function = contract.function('transfer');
//
//     var params = [EthereumAddress.fromHex(toAddress), weiAmount];
//     // print('params:::::::::::$params');
//
//     final chainID = await client.getChainId();
//     final gas = (await client.getGasPrice());
//     final estGas = (await client.estimateGas(
//       sender: address,
//     ));
//     // print('gas::::::::$gas');
//     final gasPriceInWei = gas.getInWei;
//     final buffer = BigInt.from(1000000000); // 1 Gwei buffer
//     final adjustedGasPrice = (gasPriceInWei + buffer);
//
//     // print('adjustedGasPrice:::::::::$adjustedGasPrice');
//     final transaction = Transaction.callContract(
//       contract: contract,
//       function: function,
//       parameters: params,
//       gasPrice: EtherAmount.inWei(adjustedGasPrice),
//       maxGas: estGas.toInt() + 10000, // Add some buffer to estimated gas
//     );
//
//     final signedTransaction = await client.signTransaction(
//       credentials,
//       transaction,
//       chainId: chainID.toInt(),
//     );
//
//     try {
//       final response = await client.sendRawTransaction(signedTransaction);
//
//       // print('Transaction hash: ${response}');
//
//       TransactionReceipt? receipt;
//       do {
//         await Future.delayed(Duration(
//             seconds: 3)); // Wait for a few seconds before checking again
//         receipt = await client.getTransactionReceipt(response);
//       } while (receipt == null);
//
//       // Check the status of the transaction
//       bool success = receipt.status ?? false;
//       // print('receipt:::::::$receipt');
//       if (context.mounted && success) {
//         await storeHashDetails(
//             hash: response.toString(),
//             fromAddress: userWallet.walletAddress,
//             coinData: coinData,
//             toAddress: toAddress,
//             amount: enterAmount);
//
//         if (context.mounted && success) {
//           if (success) {
//             Utils.snackBar("Token transfer is successful");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
//                 (route) => false);
//           } else {
//             Utils.snackBarErrorMessage("Token transfer is failed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
//                 (route) => false);
//           }
//         }
//       } else {
//         Utils.snackBarErrorMessage("Token transfer is failed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     } on Exception catch (e) {
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Insufficient Gas Fee In Network");
//
//         print("Token transfer failed: $e");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     }
//     await client.dispose();
//   }
//
//   bool isValidEthereumAddress(String address) {
//     // Check if the address is 42 characters long and starts with '0x'
//     return address.length == 42 && address.startsWith('0x');
//   }
//
//   // Dogecoin send transaction
//   String generateDogecoinAddress(String mnemonic) {
//     final seed = bip39.mnemonicToSeed(mnemonic);
//     final root = bip32.BIP32.fromSeed(seed, dogeNetwork);
//     final child = root.derivePath("m/44'/3'/0'/0/0");
//
//     // Public Key Hashing (P2PKH)
//     final pubKeyHash = _hash160(child.publicKey);
//     return _base58CheckEncode(0x1e, pubKeyHash);
//   }
//
//   final dogeNetwork = bip32.NetworkType(
//     wif: 0x9e,
//     bip32: bip32.Bip32Type(public: 0x02facafd, private: 0x02fac398),
//   );
//
//   Future<List<dynamic>> getDogecoinUTXOs(String xpub, int index) async {
//     final url = Uri.parse('${apiUrlService.DogecoinUTXOsUrl}$xpub/$index');
//     final headers = {
//       'x-api-key': apiKeyService.dogecoinUTXOsKey // Use your API key
//     };
//
//     final response = await http.get(url, headers: headers);
//
//     if (response.statusCode == 200) {
//       final result = json.decode(response.body);
//       return result['utxos']; // Return the UTXOs
//     } else {
//       print('Error fetching UTXOs: ${response.body}');
//       return [];
//     }
//   }
//
//   String getXpubFromSeed(String mnemonic) {
//     // Convert mnemonic to seed (BIP39 standard)
//     final seed = bip39.mnemonicToSeed(mnemonic);
//
//     // Use BIP32 to derive the root key from the seed
//     final rootKey = bip32.BIP32.fromSeed(seed);
//
//     // Derive the xpub from the root key (using BIP44 standard for Dogecoin)
//     final xpub = rootKey.toBase58();
//     print("Generated xpub: $xpub");
//
//     // Update the xPub state using setState
//
//     return xpub;
//   }
//
//   Future<String> sendDogecoinTransaction({
//     required String fromAddress,
//     required String privateKey,
//     required String toAddress,
//     required double amount,
//     required String xpub, // New parameter for xpub
//     required int index, // New parameter for index
//   }) async {
//     // Step 1: Fetch the UTXOs for the sender's xpub and index
//     List<dynamic> utxos = await getDogecoinUTXOs(xpub, index);
//
//     if (utxos.isEmpty) {
//       print("No UTXOs available for the sender's address.");
//       return "No UTXOs found";
//     }
//
//     // Step 2: Select a UTXO (for simplicity, we'll just use the first one)
//     var utxo = utxos[0]; // Choose the first UTXO (ensure sufficient balance)
//
//     final url = Uri.parse('https://api.tatum.io/v3/dogecoin/transaction');
//     final headers = {
//       'x-api-key':
//           't-679cc3141db825b185ad236b-80b6380f557f4fcd9268c908' // Use your API key
//     };
//
//     // Step 3: Build the request payload
//     final payload = {
//       'from': fromAddress,
//       'privateKey': privateKey,
//       'to': toAddress,
//       'amount': amount,
//       'fromUTXO': utxo['txHash'], // Specify the UTXO transaction hash
//       'fromIndex': utxo['index'], // Specify the UTXO output index
//       'testnet': true, // true for Dogecoin testnet
//     };
//
//     // Step 4: Send the request to Tatum API
//     final response =
//         await http.post(url, headers: headers, body: json.encode(payload));
//
//     if (response.statusCode == 200) {
//       final result = json.decode(response.body);
//       return result['txId']; // Return the transaction ID
//     } else {
//       print('Error sending Dogecoin transaction: ${response.statusCode}');
//       print('Response: ${response.body}');
//       return 'Transaction failed';
//     }
//   }
//
//   Future<List> getUtxos(String address) async {
//     final url = Uri.parse(
//         'https://api.gomaestro.org/v1/dogecoin/address/$address/utxos');
//     final headers = {
//       'Authorization': 'Bearer sRiJHOZsBlhvlX8Ue1DSOoFUK1XgfHj5',
//     };
//     final response = await http.get(url, headers: headers);
//     if (response.statusCode == 200) {
//       final result = json.decode(response.body);
//       return result['utxos'];
//     } else {
//       print('Failed to fetch UTXOs: ${response.statusCode}');
//       return [];
//     }
//   }
//
//   /// Helper function: Perform RIPEMD-160(SHA-256(pubKey))
//   List<int> _hash160(List<int> data) {
//     final sha256 = SHA256Digest().process(Uint8List.fromList(data));
//     return RIPEMD160Digest().process(sha256);
//   }
//
//   /// Helper function: Base58Check encoding
//   String _base58CheckEncode(int version, List<int> payload) {
//     final List<int> versionedPayload = [version, ...payload];
//     final checksum = SHA256Digest()
//         .process(SHA256Digest().process(Uint8List.fromList(versionedPayload)))
//         .sublist(0, 4);
//     return base58Encode(Uint8List.fromList([...versionedPayload, ...checksum]));
//   }
//
//   /// Helper function: Base58 Encoding
//   String base58Encode(List<int> bytes) {
//     const String alphabet =
//         '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
//     BigInt value = BigInt.parse(HEX.encode(bytes), radix: 16);
//     String result = '';
//     while (value > BigInt.zero) {
//       final mod = value % BigInt.from(58);
//       result = alphabet[mod.toInt()] + result;
//       value ~/= BigInt.from(58);
//     }
//     for (int i = 0; i < bytes.length && bytes[i] == 0; i++) {
//       result = '1' + result;
//     }
//     return result;
//   }
//
//   /// Helper function: Sign transaction (Dummy function, needs actual implementation)
//   String _signTransaction1(Map<String, dynamic> rawTx, String privateKey) {
//     // In reality, you need to sign each input using the private key
//     return "SignedRawTransactionHex"; // Placeholder, replace with actual signing logic
//   }
//
//   Future<List<Map<String, dynamic>>> fetchUTXOs(String address) async {
//     final url = "https://api.blockcypher.com/v1/doge/main/addrs/$address";
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['data'][address]['address']['utxo'] == null) return [];
//
//       return (data['data'][address]['address']['utxo'] as List)
//           .map((tx) => {
//                 "txid": tx["transaction_hash"],
//                 "vout": tx["index"],
//                 "value": tx["value"],
//               })
//           .toList();
//     } else {
//       print("Failed to fetch UTXOs: ${response.body}");
//       return [];
//     }
//   }
//
//   Future<String> broadcastTransaction(String txHex) async {
//     final url = Uri.parse('https://api.tatum.io/v3/dogecoin/broadcast');
//     final headers = {'x-api-key': 'your-api-key'};
//     final body = jsonEncode({'txData': txHex});
//
//     final response = await http.post(url, headers: headers, body: body);
//     final result = json.decode(response.body);
//
//     if (response.statusCode == 200) {
//       print('Transaction Hash: ${result['txId']}');
//       return result['txId'];
//     } else {
//       throw Exception('Transaction broadcast failed: ${result['message']}');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> fetchLTCUTXOs(String address) async {
//     final url =
//         'https://api.blockcypher.com/v1/ltc/main/addrs/$address?unspentOnly=true';
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data['txrefs'] != null
//           ? List<Map<String, dynamic>>.from(data['txrefs'])
//           : [];
//     } else {
//       throw Exception('Failed to fetch UTXOs');
//     }
//   }
//
//   final litecoinNetwork = bip32.NetworkType(
//     wif: 0xb0,
//     bip32: bip32.Bip32Type(public: 0x019da462, private: 0x019d9cfe),
//   );
//   Future<void> sendLitecoinTransaction({
//     required String privateKeyWIF,
//     required String fromAddress,
//     required String toAddress,
//     required int amountSatoshis,
//     required int feeSatoshis,
//   }) async {
//     try {
//       List<Map<String, dynamic>> utxos = await fetchLTCUTXOs(fromAddress);
//
//       if (utxos.isEmpty) {
//         print("No UTXOs available. Please fund your wallet.");
//         return;
//       }
//
//       String rawTx = await createSignedLTCTransaction(
//         privateKeyWIF: privateKeyWIF,
//         utxos: utxos,
//         toAddress: toAddress,
//         amountSatoshis: amountSatoshis,
//         feeSatoshis: feeSatoshis,
//         changeAddress: fromAddress,
//       );
//
//       await broadcastLTCTransaction(rawTx);
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//
//   Future<String> createSignedLTCTransaction({
//     required String privateKeyWIF,
//     required List<Map<String, dynamic>> utxos,
//     required String toAddress,
//     required int amountSatoshis,
//     required int feeSatoshis,
//     required String changeAddress,
//   }) async {
//     final keyPair = btc.ECPair.fromWIF(privateKeyWIF);
//     final txb = btc.TransactionBuilder();
//     txb.setVersion(1);
//
//     int totalInput = 0;
//
//     // Add UTXOs as inputs
//     for (var utxo in utxos) {
//       txb.addInput(utxo['tx_hash'], utxo['tx_output_n']);
//       totalInput += (utxo['value'] as num).toInt(); // Fix num to int
//     }
//
//     // Add recipient output
//     txb.addOutput(toAddress, amountSatoshis);
//
//     // Calculate change
//     int change = totalInput - amountSatoshis - feeSatoshis;
//     if (change > 0) {
//       txb.addOutput(changeAddress, change);
//     }
//
//     // Sign each input
//     for (int i = 0; i < utxos.length; i++) {
//       txb.sign(vin: i, keyPair: keyPair);
//     }
//     final rawTx = txb.build().toHex();
//     print("✅ Signed TX: $rawTx");
//     return rawTx; // Return raw signed transaction hex
//   }
//
//   Future<void> broadcastLTCTransaction(String rawTx) async {
//     final url = 'https://api.blockcypher.com/v1/ltc/main/txs/push';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'tx': rawTx}),
//     );
//
//     if (response.statusCode == 200) {
//       print(
//           'Transaction broadcasted successfully: ${json.decode(response.body)}');
//     } else {
//       throw Exception('Failed to broadcast LTC transaction: ${response.body}');
//     }
//   }
//
//   //  TON Transaction.  -----------------------------------------------------------
//   final String tonRpcUrl =
//       "https://testnet.toncenter.com/api/v2/jsonRPC"; // TON Center RPC endpoint
//
//   // Step 1: Sign and construct the BOC
//   Future<String> signTransaction(String sender, String recipient, String amount,
//       String privateKeyHex) async {
//     final privateKeyBytes = Uint8List.fromList(hex.decode(privateKeyHex));
//
//     // Construct the TON transaction cell (transaction data in the correct format)
//     final transactionCell = constructTonTransaction(sender, recipient, amount);
//
//     // Sign the transaction with Ed25519
//     final signature = await _signEd25519(privateKeyBytes, transactionCell);
//
//     // Prepend the signature to the transaction cell
//     final signedTransaction =
//         Uint8List.fromList([...signature, ...transactionCell]);
//
//     // Ensure proper Base64 encoding with padding
//     String boc = base64.encode(signedTransaction);
//
//     print("Final BOC (Base64 with padding): $boc");
//     return boc;
//   }
//
//   // Step 2: Sign with Ed25519
//   Future<List<int>> _signEd25519(
//       Uint8List privateKeyBytes, Uint8List message) async {
//     final algorithm = crypto.Ed25519();
//     final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);
//     final signature = await algorithm.sign(message, keyPair: keyPair);
//
//     print("Signature: ${hex.encode(signature.bytes)}");
//     return signature.bytes;
//   }
//
//   // Step 3: Correctly construct the TON transaction cell
//   Uint8List constructTonTransaction(
//       String sender, String recipient, String amount) {
//     List<int> transactionData = [];
//
//     // Encode TON Addresses (decode base64 address and extract data)
//     Uint8List senderBytes = _decodeTonAddress(sender);
//     Uint8List recipientBytes = _decodeTonAddress(recipient);
//
//     // Add sender and recipient addresses to the transaction data
//     transactionData.addAll(senderBytes);
//     transactionData.addAll(recipientBytes);
//
//     // Convert amount to nanoTON
//     int amountNanotons = (double.parse(amount) * 1e9).toInt();
//
//     // Encode amount as 64-bit Big Endian integer
//     ByteData amountData = ByteData(8);
//     amountData.setUint64(0, amountNanotons, Endian.big);
//     transactionData.addAll(amountData.buffer.asUint8List());
//
//     // Correct the TON BOC header format
//     List<int> bocHeader = [
//       0xB5,
//       0xEE,
//       0x9C,
//       0x72
//     ]; // Standard BOC header (fixed for TON)
//     Uint8List bocFinal = Uint8List.fromList([...bocHeader, ...transactionData]);
//
//     print("BOC Final (Hex): ${hex.encode(bocFinal)}");
//     return bocFinal;
//   }
//
//   // Step 4: Decode TON Address correctly (Base64 to Uint8List)
//   Uint8List _decodeTonAddress(String address) {
//     try {
//       Uint8List decoded = base64.decode(address);
//       if (decoded.length == 36) {
//         return decoded.sublist(0, 32); // Remove checksum from address
//       }
//       return decoded;
//     } catch (e) {
//       throw Exception("Invalid TON address format: $address");
//     }
//   }
//
//   // Step 5: Send the TON transaction to the network
//   Future<void> sendTonTransaction(
//       String sender, String recipient, String amount, String privateKey) async {
//     final url = Uri.parse(tonRpcUrl);
//     final String apiKey =
//         "1df673a23f5859b227c49c903fff6fc5f11b36d031c8467e1d1aacad22bc2f22";
//
//     // Sign the transaction and get the BOC
//     final boc = await signTransaction(sender, recipient, amount, privateKey);
//
//     print("BOC to Send: $boc");
//
//     // Send the BOC-encoded transaction to TON network
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $apiKey",
//       },
//       body: jsonEncode({
//         "jsonrpc": "2.0",
//         "id": 1,
//         "method": "sendBoc",
//         "params": {
//           "boc": boc,
//         }
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("Transaction Sent: ${data['result']}");
//     } else {
//       print("Error: ${response.body}");
//     }
//   }
//
//   solanaTokenTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required num enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     SolanaClient client = SolanaClient(
//       rpcUrl: Uri.parse(coinData.network == "Testnet"
//           ? apiUrlService.solanaDevnetURL
//           : apiUrlService.solanaMainnetURL),
//       websocketUrl: Uri.parse(coinData.network == "Testnet"
//           ? apiUrlService.solanaDevnetWS
//           : apiUrlService.solanaMainnetWS),
//     );
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     final solDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
//     final senderWallet = await Ed25519HDKeyPair.fromPrivateKeyBytes(
//         privateKey: solDefaultPath.privateKey.raw);
//
//     final to = sol.Pubkey.fromString(toAddress).toBytes();
//     int amount = solToLamports(enterAmount).toInt() ~/ 1000;
//
//     var recipientATA = await client.getAssociatedTokenAccount(
//         owner: Ed25519HDPublicKey(to),
//         mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!));
//     if (recipientATA == null) {
//       print('Recipient ATA does not exist. Creating ATA...');
//       await client.createAssociatedTokenAccount(
//         mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!),
//         owner: Ed25519HDPublicKey(to),
//         funder: senderWallet,
//       );
//     }
//     try {
//       var transaction = await client.transferSplToken(
//           amount: amount,
//           destination: Ed25519HDPublicKey(
//               to), //Ed25519HDPublicKey.fromBase58(toAddress),
//           mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!),
//           owner: senderWallet);
//
//       print("transaction::$transaction");
//       await storeHashDetails(
//           hash: transaction.toString(),
//           fromAddress: coinData.address!,
//           coinData: coinData,
//           toAddress: toAddress,
//           amount: enterAmount.toString());
//       if (context.mounted) {
//         Utils.snackBar("Token transfer is successful");
//
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     } catch (e) {
//       // print("SOLLLLLLL::e$e");
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Transfer failed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     }
//   }
//
//   dogecoinTestnetNewTx(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     const String apiUrl = "https://api.blockcypher.com/v1/doge/test3/txs/new";
//
//     double value = double.parse(enterAmount);
//     BigInt dogeAmount =
//         BigInt.from((value * 100000000).toInt()); // Convert to satoshis
//
//     Map<String, Object> requestBody = {
//       "inputs": [
//         {
//           "addresses": [coinData.address]
//         }
//       ],
//       "outputs": [
//         {
//           "addresses": [toAddress],
//           "value": dogeAmount
//         }
//       ],
//       "preference": "low",
//     };
//
//     final encSettings = EncoderSettings(
//       indent: "  ",
//       singleLineLimit: 30,
//       afterKeyIndent: " ",
//     );
//
//     // Convert request body to JSON
//     String requestBodyJson = encodeJson(requestBody, settings: encSettings);
//
//     // Define request headers
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//     };
//
//     try {
//       final response = await post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: requestBodyJson,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var newtx = jsonDecode(response.body);
//         newtx.addAll({"pubkeys": []});
//         newtx.addAll({"signatures": []});
//         List tosign = newtx["tosign"];
//
//         // Sign the transaction using the private key
//         String seedPhrase = userWallet.mnemonic.trim();
//         var seed = bip39.mnemonicToSeed(seedPhrase);
//         final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
//         var privateKey = wallet.derivePath("m/84'/1'/0'/0/0").toWIF();
//         final keyPair = btc.ECPair.fromWIF(privateKey);
//
//         for (var sign in tosign) {
//           newtx["pubkeys"].add(bytesToHex(keyPair.publicKey));
//           print(newtx["pubkeys"]);
//           var s = keyPair.sign(hexToBytes(sign));
//           var fsig = bytesToHex(btc.encodeSignature(s, 1));
//
//           newtx["signatures"].add(fsig);
//           print(newtx["signatures"]);
//         }
//
//         if (context.mounted) {
//           dogecoinTestnetSendAmount(
//               newtx, context, coinData, userWallet, toAddress, enterAmount);
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (error) {
//       // Handle error
//       print('Error: $error');
//     }
//   }
//
//   dogecoinTestnetSendAmount(
//       var data,
//       BuildContext context,
//       AssetModel coinData,
//       UserWalletDataModel userWallet,
//       String toAddress,
//       String enterAmount) async {
//     Map<String, dynamic> body = data;
//
//     try {
//       String jsonBody = encodeJson(body);
//       Map<String, String> headers = {
//         "Content-Type": "application/json",
//       };
//
//       final response = await post(
//         Uri.parse("https://api.blockcypher.com/v1/doge/test3/txs/send"),
//         headers: headers,
//         body: jsonBody,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = jsonDecode(response.body);
//         print(responseData);
//
//         if (context.mounted) {
//           await storeHashDetails(
//               hash: responseData["tx"]["hash"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//
//           if (context.mounted) {
//             Utils.snackBar("Transaction is processing");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
//                 (route) => false);
//           }
//         }
//       } else {
//         throw Exception('Failed to make POST request: ${response.body}');
//       }
//     } catch (error) {
//       print('Error making POST request: $error');
//       rethrow;
//     }
//   }
//
//   btcTestnetTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     String apiUrl = apiUrlService.btcTestnetApiUrl;
//
//     double value = double.parse(enterAmount);
//
//     BigInt satoshiAmount = BigInt.from((value * 100000000).toInt());
//     Map<String, Object> requestBody = {
//       "inputs": [
//         {
//           "addresses": [coinAddressGenerate.btcTestnet(userWallet.mnemonic)]
//         }
//       ],
//       "outputs": [
//         {
//           "addresses": [toAddress],
//           "value": satoshiAmount
//         }
//       ],
//       "confirmations": 7,
//       "preference": "low",
//     };
//     final encSettings = EncoderSettings(
//       indent: "  ",
//       singleLineLimit: 30,
//       afterKeyIndent: " ",
//     );
//     // Convert request body to JSON
//     String requestBodyJson = encodeJson(requestBody, settings: encSettings);
//
//     // print(requestBodyJson);
//     // Define request headers
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//     };
//
//     try {
//       final response = await post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: requestBodyJson,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var newtx = jsonDecode(response.body);
//         newtx.addAll({"pubkeys": []});
//         newtx.addAll({"signatures": []});
//         List tosign = newtx["tosign"];
//
//         //------------------btc----------------------------------------------------
//         String seedPhrase = userWallet.mnemonic.trim();
//         var seed = bip39.mnemonicToSeed(seedPhrase);
//         final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
//         var privateKey = wallet.derivePath("m/84'/1'/0'/0/0").toWIF();
//         final keyPair = btc.ECPair.fromWIF(privateKey);
//
//         for (var sign in tosign) {
//           newtx["pubkeys"].add(bytesToHex(keyPair.publicKey));
//           print(newtx["pubkeys"]);
//           var s = keyPair.sign(hexToBytes(sign));
//           var fsig = bytesToHex(btc.encodeSignature(s, 1));
//
//           newtx["signatures"].add(fsig);
//           print(newtx["signatures"]);
//           // final keyPair = btc.ECPair.fromPublicKey();
//         }
//
//         if (context.mounted) {
//           btcTestnetSendAmount(
//               newtx, context, coinData, userWallet, toAddress, enterAmount);
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (error) {
//       // print('Error sending transaction: $error');
//     }
//   }
//
//   btcTestnetSendAmount(
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
//       };
//       final response = await post(
//         Uri.parse(apiUrlService.btcTestnetSendApiUrl),
//         headers: headers,
//         body: jsonBody,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = jsonDecode(response.body);
//         // print('wefvev');
//         print(responseData);
//         if (context.mounted) {
//           await storeHashDetails(
//               hash: responseData["tx"]["hash"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
//                 (route) => false);
//           }
//         }
//       } else {
//         throw Exception('Failed to make POST request: ${response.body}');
//       }
//     } catch (error) {
//       print('Error making POST request: $error');
//       rethrow;
//     }
//   }
//
//   btcMainnetTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     String apiUrl = apiUrlService.btcMainnetApiUrl;
//
//     double value = double.parse(enterAmount);
//
//     BigInt satoshiAmount = BigInt.from((value * 100000000).toInt());
//     Map<String, Object> requestBody = {
//       "inputs": [
//         {
//           "addresses": [coinAddressGenerate.btcMainnet(userWallet.mnemonic)]
//         }
//       ],
//       "outputs": [
//         {
//           "addresses": [toAddress],
//           "value": satoshiAmount
//         }
//       ],
//       "confirmations": 2,
//       "preference": "low",
//     };
//     final encSettings = EncoderSettings(
//       indent: "  ",
//       singleLineLimit: 30,
//       afterKeyIndent: " ",
//     );
//     // Convert request body to JSON
//     String requestBodyJson = encodeJson(requestBody, settings: encSettings);
//
//     // print(requestBodyJson);
//     // Define request headers
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//     };
//
//     try {
//       final response = await post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: requestBodyJson,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var newtx = jsonDecode(response.body);
//         newtx.addAll({"pubkeys": []});
//         newtx.addAll({"signatures": []});
//         List tosign = newtx["tosign"];
//
//         //------------------btc----------------------------------------------------
//         String seedPhrase = userWallet.mnemonic.trim();
//         var seed = bip39.mnemonicToSeed(seedPhrase);
//         final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
//         var privateKey = wallet.derivePath("m/84'/0'/0'/0/0").toWIF();
//         final keyPair = btc.ECPair.fromWIF(privateKey);
//
//         for (var sign in tosign) {
//           newtx["pubkeys"].add(bytesToHex(keyPair.publicKey));
//           // print(newtx["pubkeys"]);
//           var s = keyPair.sign(hexToBytes(sign));
//           var fsig = bytesToHex(btc.encodeSignature(s, 1));
//
//           newtx["signatures"].add(fsig);
//           // print(newtx["signatures"]);
//           // final keyPair = btc.ECPair.fromPublicKey();
//         }
//
//         if (context.mounted) {
//           btcMainnetSendAmount(
//               newtx, context, coinData, userWallet, toAddress, enterAmount);
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (error) {
//       print('Error sending transaction: $error');
//     }
//   }
//
//   btcMainnetSendAmount(
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
//       };
//       final response = await post(
//         Uri.parse(apiUrlService.btcMainnetSendApiUrl),
//         headers: headers,
//         body: jsonBody,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = jsonDecode(response.body);
//         // print(responseData);
//         if (context.mounted) {
//           await storeHashDetails(
//               hash: responseData["tx"]["hash"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
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
//   bool _isValidHex(String hexString) {
//     final validHexPattern = RegExp(r'^[0-9a-fA-F]+$');
//     return validHexPattern.hasMatch(hexString);
//   }
//
// // Get TRON private key from seed
//   TronPrivateKey _getTronPrivateKey(List<int> seed) {
//     final tronDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.tron).deriveDefaultPath;
//     return TronPrivateKey.fromBytes(tronDefaultPath.privateKey.raw);
//   }
//
//   // SecureRandom getSecureRandom() {
//   //   final secureRandom = FortunaRandom();
//   //   final seed = Uint8List.fromList(
//   //       List.generate(32, (_) => Random.secure().nextInt(256)));
//   //   secureRandom.seed(KeyParameter(seed));
//   //   return secureRandom;
//   // }
//
//   /// Decode a Base58 encoded string to bytes.
//   String base58Alphabet =
//       '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
//
//   Uint8List base58Decode(String input) {
//     BigInt decoded = BigInt.zero;
//     for (int i = 0; i < input.length; i++) {
//       final index = base58Alphabet.indexOf(input[i]);
//       if (index == -1)
//         throw FormatException("Invalid Base58 character: ${input[i]}");
//       decoded = decoded * BigInt.from(58) + BigInt.from(index);
//     }
//     final result = <int>[];
//     while (decoded > BigInt.zero) {
//       result.insert(0, (decoded % BigInt.from(256)).toInt());
//       decoded = decoded ~/ BigInt.from(256);
//     }
//     final leadingZeros =
//         input.split('').takeWhile((char) => char == '1').length;
//     return Uint8List.fromList(List.filled(leadingZeros, 0) + result);
//   }
//
//   String _toHexAddress(String tronAddress) {
//     final hexAddress = base58Decode(tronAddress)
//         .sublist(0, 20) // Extract first 20 bytes
//         .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
//         .join('');
//     return hexAddress.padLeft(64, '0');
//   }
//
//   Future<void> trxTestnetTokenTransaction({
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
//         await storeHashDetails(
//             hash: result["txid"].toString(),
//             fromAddress: coinData.address!,
//             coinData: coinData,
//             toAddress: toAddress,
//             amount: enterAmount);
//         Utils.snackBar("Transaction is proceed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//         print("Transaction successful! TXID: ${result["txid"].toString()}");
//         // Optional: Add your post-transaction logic here (e.g., storing the hash)
//       } else {
//         Utils.snackBarErrorMessage("Transaction is failed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
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
//       final sign = tronPrivateKey.sign(hexToBytes(rawDataHex));
//       return bytesToHex(Uint8List.fromList(sign));
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
//
//   Future<void> trxTestnetTransaction(BuildContext context,
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
//       // print('Response status: ${response.statusCode}');
//       // print('Response body: ${response.body}');
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
//         var sign = tronPrivateKey.sign(hexToBytes(rawDataHex));
//         var signature = [bytesToHex(Uint8List.fromList(sign))];
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
//           await storeHashDetails(
//               hash: responseData["txid"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
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
//   trxMainnetTransaction(BuildContext context,
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
//         var sign = tronPrivateKey.sign(hexToBytes(decodeTxn["raw_data_hex"]));
//         var signature = [bytesToHex(Uint8List.fromList(sign))];
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
//           await storeHashDetails(
//               hash: responseData["txid"].toString(),
//               fromAddress: coinData.address!,
//               coinData: coinData,
//               toAddress: toAddress,
//               amount: enterAmount);
//           if (context.mounted) {
//             Utils.snackBar("Transaction is proceed");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (builder) => BottomNavBar()),
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
//   solanaTestnetTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     final cluster = sol.Cluster.devnet;
//     final connection = sol.Connection(cluster);
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     final solDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
//     final solPrivateKey =
//         TronPrivateKey.fromBytes(solDefaultPath.privateKey.raw);
//     final wallet1 =
//         sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
//     final address1 = wallet1.pubkey;
//     final wallet2 =
//         sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
//     final address2 = wallet2.pubkey;
//     double value = double.parse(enterAmount);
//     final balance = await connection.getBalance(wallet1.pubkey);
//     // print('Account $address1 has an initial balance of $balance lamports.');
//
//     final sol.BlockhashWithExpiryBlockHeight blockhash =
//         await connection.getLatestBlockhash();
//
//     final transaction = sol.Transaction.v0(
//         payer: wallet1.pubkey,
//         recentBlockhash: blockhash.blockhash,
//         instructions: [
//           SystemProgram.transfer(
//             fromPubkey: address1,
//             toPubkey: sol.Pubkey.fromString(toAddress),
//             lamports: sol.solToLamports(value),
//           ),
//         ]);
//
//     transaction.sign([wallet1]);
//
//     try {
//       var txid = await connection.sendAndConfirmTransaction(transaction);
//
//       // print(txid);
//       if (txid.isNotEmpty) {
//         await storeHashDetails(
//             hash: txid.toString(),
//             fromAddress: coinData.address!,
//             coinData: coinData,
//             toAddress: toAddress,
//             amount: enterAmount);
//         if (context.mounted) {
//           Utils.snackBar("Transaction is proceed");
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (builder) => BottomNavBar()),
//               (route) => false);
//         }
//       } else {
//         if (context.mounted) {
//           Utils.snackBarErrorMessage("Something went wrong");
//           Navigator.pop(context);
//         }
//       }
//     } on Exception catch (e) {
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Something went wrong");
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   Future<num> solEstGas(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async
//   {
//     final cluster = sol.Cluster.devnet;
//     final connection = sol.Connection(cluster);
//     double value = double.parse(enterAmount);
//
//     final sol.BlockhashWithExpiryBlockHeight blockhash =
//         await connection.getLatestBlockhash();
//
//     final transaction = sol.Transaction.v0(
//         payer: sol.Pubkey.fromString(coinData.address!),
//         recentBlockhash: blockhash.blockhash,
//         instructions: [
//           SystemProgram.transfer(
//             fromPubkey: sol.Pubkey.fromString(coinData.address!),
//             toPubkey: sol.Pubkey.fromString(toAddress),
//             lamports: sol.solToLamports(value),
//           ),
//         ]);
//
//     try {
//       var gas = await connection.getFeeForMessage(transaction.message);
//
//       return sol.lamportsToSol(BigInt.from(gas));
//     } on Exception catch (e) {
//       return 0;
//     }
//   }
//
//   solanaTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     final cluster = sol.Cluster.mainnet;
//     final connection = sol.Connection(cluster);
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     final solDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
//     final solPrivateKey =
//         TronPrivateKey.fromBytes(solDefaultPath.privateKey.raw);
//     final wallet1 =
//         sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
//     final address1 = wallet1.pubkey;
//     double value = double.parse(enterAmount);
//
//     final sol.BlockhashWithExpiryBlockHeight blockhash =
//         await connection.getLatestBlockhash();
//
//     final transaction = sol.Transaction.v0(
//         payer: wallet1.pubkey,
//         recentBlockhash: blockhash.blockhash,
//         instructions: [
//           SystemProgram.transfer(
//             fromPubkey: address1,
//             toPubkey: sol.Pubkey.fromString(toAddress),
//             lamports: sol.solToLamports(value),
//           ),
//         ]);
//
//     transaction.sign([wallet1]);
//
//     var txid = await connection.sendAndConfirmTransaction(
//       transaction,
//     );
//     if (txid.isNotEmpty) {
//       await storeHashDetails(
//           hash: txid.toString(),
//           fromAddress: coinData.address!,
//           coinData: coinData,
//           toAddress: toAddress,
//           amount: enterAmount);
//       if (context.mounted) {
//         Utils.snackBar("Transaction is proceed");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (builder) => BottomNavBar()),
//             (route) => false);
//       }
//     } else {
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Something went wrong");
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   xrpTransaction(BuildContext context,
//       {required AssetModel coinData,
//       required String enterAmount,
//       required String toAddress,
//       required UserWalletDataModel userWallet}) async {
//     var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
//     final seed = Bip39SeedGenerator(mnemonic).generate();
//     final xrpDefaultPath =
//         Bip44.fromSeed(seed, Bip44Coins.ripple).deriveDefaultPath;
//     final xrpPrivateKey = XRPPrivateKey.fromBytes(xrpDefaultPath.privateKey.raw,
//         algorithm: XRPKeyAlgorithm.secp256k1);
//     XRPHTTPClient? service;
//     final rpc = coinData.network == "Testnet"
//         ? await XRPProvider.testNet((httpUri, websocketUri) async {
//             print("httpUri  :::::::::$httpUri");
//             service = XRPHTTPClient(httpUri, http.Client());
//             print("service  :::: ${service!}");
//             return service!;
//           })
//         : await XRPProvider.mainnet((httpUri, websocketUri) async {
//             service = XRPHTTPClient(httpUri, http.Client());
//             return service!;
//           });
//     String memoData = BytesUtils.toHexString(
//         utf8.encode("https://github.com/mrtnetwork/xrpl_dart"));
//     String memoType = BytesUtils.toHexString(utf8.encode("Text"));
//     String mempFormat = BytesUtils.toHexString(utf8.encode("text/plain"));
//     final exampleMemo = XRPLMemo(
//         memoData: memoData, memoFormat: mempFormat, memoType: memoType);
//     try {
//       var hash;
//
//       final transaction = Payment(
//         account: coinData.address.toString(),
//         destination: toAddress,
//         amount: CurrencyAmount.xrp(XRPHelper.xrpDecimalToDrop(enterAmount)),
//         signer: XRPLSignature.signer(xrpPrivateKey.getPublic().toHex()),
//         memos: [exampleMemo],
//       );
//       print('transaction:::::::::::::::::${transaction.amount}');
//       print(" rpc ::::::$rpc");
//       print(" transaction ::::::$transaction");
//       await XRPHelper.autoFill(rpc, transaction);
//       final blob = transaction.toBlob();
//       final sig = xrpPrivateKey.sign(blob);
//       transaction.setSignature(sig);
//       final trBlob = transaction.toBlob(forSigning: false);
//       final result = await rpc.request(XRPRequestSubmitOnly(txBlob: trBlob));
//       print("transaction hash: ${result.txJson.hash}");
//       hash = result.txJson.hash;
//
//       if (result.isSuccess && hash != null) {
//         await storeHashDetails(
//             hash: hash,
//             fromAddress: coinData.address!,
//             coinData: coinData,
//             toAddress: toAddress,
//             amount: enterAmount);
//         if (context.mounted) {
//           Utils.snackBar("Transaction is proceed");
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (builder) => BottomNavBar()),
//               (route) => false);
//         }
//       } else {
//         if (context.mounted) {
//           Utils.snackBarErrorMessage("Transaction is failed");
//           Navigator.pop(context);
//         }
//       }
//     } on Exception catch (e) {
//       if (context.mounted) {
//         Utils.snackBarErrorMessage("Transaction is failed");
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   Uint8List hexToBytes(String hexString) {
//     return Uint8List.fromList(List.generate(hexString.length ~/ 2,
//         (i) => int.parse(hexString.substring(2 * i, 2 * i + 2), radix: 16)));
//   }
//
//   String bytesToHex(Uint8List bytes) {
//     return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
//   }
// }
//
// CoinTransaction coinTransaction = CoinTransaction();
// BigInt etherToWei(String etherStr) {
//   // Split the amount into integer and fractional parts
//   List<String> parts = etherStr.split('.');
//
//   // Handle the integer part
//   BigInt integerPart = BigInt.parse(parts[0]);
//
//   // Handle the fractional part
//   // If there is no fractional part, default to zero
//   BigInt fractionalPart = BigInt.zero;
//   if (parts.length > 1) {
//     // Pad the fractional part to ensure it has 18 digits
//     String fractionalStr = parts[1].padRight(18, '0').substring(0, 18);
//     fractionalPart = BigInt.parse(fractionalStr);
//   }
//
//   // Calculate total Wei
//   BigInt weiAmount = (integerPart * BigInt.from(10).pow(18)) + fractionalPart;
//
//   return weiAmount;
// }
//
// BigInt etherTokenToWei(String etherStr, int decimals) {
//   // Split the amount into integer and fractional parts
//   List<String> parts = etherStr.split('.');
//
//   // Handle the integer part
//   BigInt integerPart = BigInt.parse(parts[0]);
//
//   // Handle the fractional part
//   // If there is no fractional part, default to zero
//   BigInt fractionalPart = BigInt.zero;
//   if (parts.length > 1) {
//     // Pad the fractional part to ensure it has the required number of digits
//     String fractionalStr =
//         parts[1].padRight(decimals, '0').substring(0, decimals);
//     fractionalPart = BigInt.parse(fractionalStr);
//   }
//
//   // Calculate total Wei using the provided decimals
//   BigInt weiAmount =
//       (integerPart * BigInt.from(10).pow(decimals)) + fractionalPart;
//   print("weiAmount $weiAmount");
//   return weiAmount;
// }
