// import 'dart:math';
// import 'package:nvwallet/Api_Service/ApiUrl_Service.dart';
// import 'package:nvwallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
// import 'package:nvwallet/Crypto_Utils/AppToastMsg/AppToast.dart';
// import 'package:nvwallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
// import 'package:nvwallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
// import 'package:nvwallet/UserWalletData/UserWalletData.dart';
// import 'package:flutter/material.dart';
// import 'package:thor_request_dart/connect.dart' as wallet;
// import 'package:thor_request_dart/wallet.dart' as thor_wallet;
//
// class VechainTransaction {
//   sendTestnet(
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
//     await StoreHashDetails().hashDetails(
//         hash: tx["id"].toString(),
//         fromAddress: coinData.address!,
//         coinData: coinData,
//         toAddress: toAddress,
//         amount: enterAmount.toString());
//     if (context.mounted) {
//       Utils.snackBar("Transaction is proceed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => AppBottomNav()),
//           (route) => false);
//     } else {
//       Utils.snackBarErrorMessage("Transaction is failed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => AppBottomNav()),
//           (route) => false);
//     }
//
//     return;
//   }
//
//   sendMainnet(
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
//     await StoreHashDetails().hashDetails(
//         hash: tx["id"].toString(),
//         fromAddress: coinData.address!,
//         coinData: coinData,
//         toAddress: toAddress,
//         amount: enterAmount.toString());
//     if (context.mounted) {
//       Utils.snackBar("Transaction is proceed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => AppBottomNav()),
//           (route) => false);
//     } else {
//       Utils.snackBarErrorMessage("Transaction is failed");
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (builder) => AppBottomNav()),
//           (route) => false);
//     }
//
//     return;
//   }
// }
