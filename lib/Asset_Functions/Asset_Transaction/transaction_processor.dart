import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/btc_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/evm_token_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/evm_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/sol_token_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/sol_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/trx_token_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/trx_transaction.dart';
import 'package:securywallet/Asset_Functions/Asset_Transaction/transaction_types/xrp_transaction.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';

class TransactionProcessor {
  dynamic xPub;

  void processTransaction(
    BuildContext context, {
    required AssetModel coinData,
    required String enterAmount,
    required String toAddress,
    required UserWalletDataModel userWallet,
    required String privateKeyHex,
    required String contractAddress,
    required String rpcUrl,
  }) async {
    print("svsdv");

    // if (coinData.coinSymbol == 'tVET' && coinData.coinType == '3') {
    //   VechainTransaction().sendTestnet(context,
    //       coinData: coinData,
    //       enterAmount: enterAmount,
    //       toAddress: toAddress,
    //       userWallet: userWallet);
    // }
    // if (coinData.coinSymbol == 'VET' && coinData.coinType == '3') {
    //   VechainTransaction().sendMainnet(context,
    //       coinData: coinData,
    //       enterAmount: enterAmount,
    //       toAddress: toAddress,
    //       userWallet: userWallet);
    // }
    if (coinData.coinType == "2") {
      if (coinData.rpcURL != "") {
        await EvmTokenTransaction().send(
          context,
          coinData: coinData,
          enterAmount: enterAmount,
          toAddress: toAddress,
          userWallet: userWallet,
        );
      } else if (coinData.coinType == "2" &&
          (coinData.gasPriceSymbol == "SOL" ||
              coinData.gasPriceSymbol == "tSOL")) {
        await SolTokenTransaction().send(
          context,
          coinData: coinData,
          enterAmount: num.parse(enterAmount),
          toAddress: toAddress,
          userWallet: userWallet,
        );
      }
      // else if (coinData.coinType == "2" &&
      //     (coinData.gasPriceSymbol == "TRX" ||
      //         coinData.gasPriceSymbol == "tTRX")) {
      //   await TrxTokenTransaction().send(
      //       context: context,
      //       toAddress: toAddress,
      //       tokenContractAddress: contractAddress,
      //       mnemonic: userWallet.mnemonic,
      //       amount: double.parse(enterAmount),
      //       coinData: coinData,
      //       enterAmount: enterAmount,
      //       userWallet: userWallet);
      // }
    } else {
      switch (coinData.coinSymbol) {
        case 'tBTC':
          await BtcTransaction().sendTestnet(
            context,
            coinData: coinData,
            enterAmount: enterAmount,
            toAddress: toAddress,
            userWallet: userWallet,
          );
          break;
        case 'BTC':
          await BtcTransaction().sendMainnet(
            context,
            coinData: coinData,
            enterAmount: enterAmount,
            toAddress: toAddress,
            userWallet: userWallet,
          );
          break;
        case 'tTRX':
          await TrxTransaction().sendTestnet(context,
              coinData: coinData,
              enterAmount: enterAmount,
              toAddress: toAddress,
              userWallet: userWallet);
          break;
        case 'TRX':
          await TrxTransaction().sendMainnet(context,
              coinData: coinData,
              enterAmount: enterAmount,
              toAddress: toAddress,
              userWallet: userWallet);
        //   break;
        // case 'tSOL':
        //   await SolTransaction().sendTestnet(context,
        //       coinData: coinData,
        //       enterAmount: enterAmount,
        //       toAddress: toAddress,
        //       userWallet: userWallet);
        //   break;
        // case 'SOL':
        //   await SolTransaction().sendMainnet(context,
        //       coinData: coinData,
        //       enterAmount: enterAmount,
        //       toAddress: toAddress,
        //       userWallet: userWallet);
        //   break;
        // case 'XRP' || 'tXRP':
        //   await XrpTransaction().send(
        //     context,
        //     coinData: coinData,
        //     enterAmount: enterAmount,
        //     toAddress: toAddress,
        //     userWallet: userWallet,
        //   );
          break;
        default:
          await EvmTransaction().send(
            context,
            coinData: coinData,
            enterAmount: enterAmount,
            toAddress: toAddress,
            userWallet: userWallet,
          );
          break;
      }
    }
  }
}

TransactionProcessor transactionProcessor = TransactionProcessor();
