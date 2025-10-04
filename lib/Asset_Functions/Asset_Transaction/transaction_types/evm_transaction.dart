import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Crypto_Transactions/TransactionReceipt/TransactionReceipt.dart';
import 'package:securywallet/Screens/Crypto_Transactions/confirmTransactionPage/View/confirmTransactionPage_View.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/Transaction_Action_Screen/View/Transaction_Action_view.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';

import 'package:web3dart/web3dart.dart';

import 'Hex_Bytes.dart';

class EvmTransaction {
  send(
    BuildContext context, {
    required AssetModel coinData,
    required String enterAmount,
    required String toAddress,
    required UserWalletDataModel userWallet,
  }) async {
    String rpcUrl = coinData.rpcURL!;

    final client = Web3Client(rpcUrl, Client());
    final credentials = EthPrivateKey.fromHex(userWallet.privateKey);
    final address = credentials.address;
    double amt = double.parse(enterAmount);
    print("Notify-------------------------------------------------------");
    // Convert the amount to Wei
    String amountStr = enterAmount;

    BigInt weiAmount = hexBytes.etherToWei(amountStr);
    final amount = EtherAmount.inWei(weiAmount);
    // print('amount:::????:::::::::$amount');

    final chainID = await client.getChainId();
    final gasEstimate = await client.estimateGas(
      sender: address,
      to: EthereumAddress.fromHex(toAddress),
      value: amount,
    );
    // print('gasEstimate:::????:::::::::$gasEstimate');
    final transaction = Transaction(
      from: address,
      to: EthereumAddress.fromHex(toAddress),
      maxGas: gasEstimate.toInt(), // Set gas limit
      value: amount, // Set value to send (1 ETC)
    );

    final signedTransaction = await client.signTransaction(
      credentials,
      transaction,
      chainId: chainID.toInt(),
    );

    try {
      final response = await client.sendRawTransaction(signedTransaction);
      // print('Transaction hash: ${response}');
      await StoreHashDetails().hashDetails(
        hash: response.toString(),
        fromAddress: userWallet.walletAddress,
        coinData: coinData,
        toAddress: toAddress,
        amount: enterAmount,
      );
      if (context.mounted) {
        // Utils.snackBar("Transaction is proceed");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => AppBottomNav()),
          (route) => false,
        );
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Processing',
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, anim1, anim2) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * anim1.value,
                sigmaY: 10 * anim1.value,
              ),
              child: Opacity(
                opacity: anim1.value,
                child: Stack(
                  children: [
                    // Semi-transparent blurred background
                    Container(color: Colors.black.withOpacity(0.3)),
                    const ProcessingDialogBottom(),
                  ],
                ),
              ),
            );
          },
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        // Utils.snackBarErrorMessage("Transaction failed");
        print('$e');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => AppBottomNav()),
          (route) => false,
        );
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Processing',
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, anim1, anim2) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * anim1.value,
                sigmaY: 10 * anim1.value,
              ),
              child: Opacity(
                opacity: anim1.value,
                child: Stack(
                  children: [
                    // Semi-transparent blurred background
                    Container(color: Colors.black.withOpacity(0.3)),
                    const ProcessingDialogBottom(),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
    await client.dispose();
  }
}
