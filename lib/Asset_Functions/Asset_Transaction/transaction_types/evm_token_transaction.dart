import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:web3dart/web3dart.dart';

import 'Hex_Bytes.dart';

class EvmTokenTransaction {
  send(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    String rpcUrl = coinData.rpcURL!;
    print('rpcUrl $rpcUrl');
    print('tokenDecimal ${coinData.tokenDecimal}');
    final client = Web3Client(rpcUrl, Client());
    final credentials = EthPrivateKey.fromHex(userWallet.privateKey);
    final address = credentials.address;

    // Token contract details
    EthereumAddress tokenAddress =
        EthereumAddress.fromHex(coinData.tokenAddress!);
    final contract = DeployedContract(
      ContractAbi.fromJson(
          '[{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]',
          ''),
      tokenAddress,
    );

    // Convert the entered amount to a double
    double amt = double.parse(enterAmount);

// Convert the amount to Wei
    String amountStr = enterAmount;

    BigInt weiAmount =
        hexBytes.etherTokenToWei(amountStr, int.parse(coinData.tokenDecimal!));
    print("weiAmount $weiAmount");

    var function = contract.function('transfer');

    var params = [EthereumAddress.fromHex(toAddress), weiAmount];
    // print('params:::::::::::$params');

    final chainID = await client.getChainId();
    final gas = (await client.getGasPrice());
    final estGas = (await client.estimateGas(
      sender: address,
    ));
    print('gas::::::::$gas');
    final gasPriceInWei = gas.getInWei;
    final buffer = BigInt.from(1000000000); // 1 Gwei buffer
    final adjustedGasPrice = (gasPriceInWei + buffer);

    print('adjustedGasPrice:::::::::$adjustedGasPrice');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: params,
      gasPrice: EtherAmount.inWei(adjustedGasPrice),
      maxGas: 200000, // GasLimit 200000
    );
    final signedTransaction = await client.signTransaction(
      credentials,
      transaction,
      chainId: chainID.toInt(),
    );

    try {
      final response = await client.sendRawTransaction(signedTransaction);
      print("response : $response");
      TransactionReceipt? receipt;
      do {
        await Future.delayed(Duration(
            seconds: 3)); // Wait for a few seconds before checking again
        receipt = await client.getTransactionReceipt(response);
      } while (receipt == null);

      // Check the status of the transaction
      bool success = receipt.status ?? false;
      // print('receipt:::::::$receipt');
      if (context.mounted && success) {
        await StoreHashDetails().hashDetails(
            hash: response.toString(),
            fromAddress: userWallet.walletAddress,
            coinData: coinData,
            toAddress: toAddress,
            amount: enterAmount);

        if (context.mounted && success) {
          if (success) {
            Utils.snackBar("Token transfer is successful");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => AppBottomNav()),
                (route) => false);
          } else {
            Utils.snackBarErrorMessage("Token transfer is failed");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => AppBottomNav()),
                (route) => false);
          }
        }
      } else {
        Utils.snackBarErrorMessage("Token transfer is failed");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => AppBottomNav()),
            (route) => false);
      }
      // print("/////${estGas.toInt() + 10000}");
    } on Exception catch (e) {
      if (context.mounted) {
        Utils.snackBarErrorMessage("Insufficient Gas Fee In Network");

        print("Token transfer failed: $e");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => AppBottomNav()),
            (route) => false);
      }
    }
    await client.dispose();
  }
}
