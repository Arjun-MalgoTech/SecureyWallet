

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';


import 'package:web3dart/web3dart.dart';

import 'Hex_Bytes.dart';

class EvmTransaction {
  send(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
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

    final signedTransaction = await client
        .signTransaction(credentials, transaction, chainId: chainID.toInt());

    try {
      final response = await client.sendRawTransaction(signedTransaction);
      // print('Transaction hash: ${response}');
      await StoreHashDetails().hashDetails(
          hash: response.toString(),
          fromAddress: userWallet.walletAddress,
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
    } on Exception catch (e) {
      if (context.mounted) {
        Utils.snackBarErrorMessage("Transaction failed");
        print('$e');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => AppBottomNav()),
            (route) => false);
      }
    }
    await client.dispose();
  }
}
