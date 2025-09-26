import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Asset_Functions/XrpHttpClient.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XrpTransaction {
  send(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
    final seed = Bip39SeedGenerator(mnemonic).generate();
    final xrpDefaultPath =
        Bip44.fromSeed(seed, Bip44Coins.ripple).deriveDefaultPath;
    final xrpPrivateKey = XRPPrivateKey.fromBytes(xrpDefaultPath.privateKey.raw,
        algorithm: XRPKeyAlgorithm.secp256k1);
    XRPHTTPClient? service;
    final rpc = coinData.network == "Testnet"
        ? await XRPProvider.testNet((httpUri, websocketUri) async {
            print("httpUri  :::::::::$httpUri");
            service = XRPHTTPClient(httpUri, http.Client());
            print("service  :::: ${service!}");
            return service!;
          })
        : await XRPProvider.mainnet((httpUri, websocketUri) async {
            service = XRPHTTPClient(httpUri, http.Client());
            return service!;
          });
    String memoData = BytesUtils.toHexString(
        utf8.encode("https://github.com/mrtnetwork/xrpl_dart"));
    String memoType = BytesUtils.toHexString(utf8.encode("Text"));
    String mempFormat = BytesUtils.toHexString(utf8.encode("text/plain"));
    final exampleMemo = XRPLMemo(
        memoData: memoData, memoFormat: mempFormat, memoType: memoType);
    try {
      var hash;

      final transaction = Payment(
        account: coinData.address.toString(),
        destination: toAddress,
        amount: CurrencyAmount.xrp(XRPHelper.xrpDecimalToDrop(enterAmount)),
        signer: XRPLSignature.signer(xrpPrivateKey.getPublic().toHex()),
        memos: [exampleMemo],
      );
      print('transaction:::::::::::::::::${transaction.amount}');
      print(" rpc ::::::$rpc");
      print(" transaction ::::::$transaction");
      await XRPHelper.autoFill(rpc, transaction);
      final blob = transaction.toBlob();
      final sig = xrpPrivateKey.sign(blob);
      transaction.setSignature(sig);
      final trBlob = transaction.toBlob(forSigning: false);
      final result = await rpc.request(XRPRequestSubmitOnly(txBlob: trBlob));
      print("transaction hash: ${result.txJson.hash}");
      hash = result.txJson.hash;

      if (result.isSuccess && hash != null) {
        await StoreHashDetails().hashDetails(
            hash: hash,
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
      } else {
        if (context.mounted) {
          Utils.snackBarErrorMessage("Transaction is failed");
          Navigator.pop(context);
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        Utils.snackBarErrorMessage("Transaction is failed");
        Navigator.pop(context);
      }
    }
  }
}
