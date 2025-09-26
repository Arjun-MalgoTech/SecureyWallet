import 'package:flutter/material.dart';
import 'package:securywallet/Api_Service/ApiUrl_Service.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:solana_web3/solana_web3.dart' as sol;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:solana/src/solana_client.dart';
import 'package:solana/src/programs/token_program/solana_client_ext.dart';
import 'package:solana_wallet/src/type.dart';
import 'package:solana/src/crypto/ed25519_hd_public_key.dart';
import 'package:solana/src/crypto/ed25519_hd_keypair.dart';
import 'package:solana/solana.dart' as sol;

class SolTokenTransaction {
  send(BuildContext context,
      {required AssetModel coinData,
      required num enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    SolanaClient client = SolanaClient(
      rpcUrl: Uri.parse(coinData.network == "Testnet"
          ? apiUrlService.solanaDevnetURL
          : apiUrlService.solanaMainnetURL),
      websocketUrl: Uri.parse(coinData.network == "Testnet"
          ? apiUrlService.solanaDevnetWS
          : apiUrlService.solanaMainnetWS),
    );
    var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
    final seed = Bip39SeedGenerator(mnemonic).generate();
    final solDefaultPath =
        Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
    final senderWallet = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: solDefaultPath.privateKey.raw);

    final to = sol.Pubkey.fromString(toAddress).toBytes();
    int amount = solToLamports(enterAmount).toInt() ~/ 1000;

    var recipientATA = await client.getAssociatedTokenAccount(
        owner: Ed25519HDPublicKey(to),
        mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!));
    if (recipientATA == null) {
      print('Recipient ATA does not exist. Creating ATA...');
      await client.createAssociatedTokenAccount(
        mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!),
        owner: Ed25519HDPublicKey(to),
        funder: senderWallet,
      );
    }
    try {
      var transaction = await client.transferSplToken(
          amount: amount,
          destination: Ed25519HDPublicKey(
              to), //Ed25519HDPublicKey.fromBase58(toAddress),
          mint: Ed25519HDPublicKey.fromBase58(coinData.tokenAddress!),
          owner: senderWallet);

      print("transaction::$transaction");
      await StoreHashDetails().hashDetails(
          hash: transaction.toString(),
          fromAddress: coinData.address!,
          coinData: coinData,
          toAddress: toAddress,
          amount: enterAmount.toString());
      if (context.mounted) {
        Utils.snackBar("Token transfer is successful");

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => AppBottomNav()),
            (route) => false);
      }
    } catch (e) {
      // print("SOLLLLLLL::e$e");
      if (context.mounted) {
        Utils.snackBarErrorMessage("Transfer failed");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => AppBottomNav()),
            (route) => false);
      }
    }
  }
}
