import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Transaction_Details.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:solana_web3/programs.dart';
import 'package:solana_web3/solana_web3.dart' as sol;
import 'package:blockchain_utils/blockchain_utils.dart';

class SolTransaction {
  sendTestnet(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    final cluster = sol.Cluster.devnet;
    final connection = sol.Connection(cluster);
    var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
    final seed = Bip39SeedGenerator(mnemonic).generate();
    final solDefaultPath =
        Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
    final solPrivateKey =
        TronPrivateKey.fromBytes(solDefaultPath.privateKey.raw);
    final wallet1 =
        sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
    final address1 = wallet1.pubkey;
    final wallet2 =
        sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
    final address2 = wallet2.pubkey;
    double value = double.parse(enterAmount);
    final balance = await connection.getBalance(wallet1.pubkey);
    // print('Account $address1 has an initial balance of $balance lamports.');

    final sol.BlockhashWithExpiryBlockHeight blockhash =
        await connection.getLatestBlockhash();

    final transaction = sol.Transaction.v0(
        payer: wallet1.pubkey,
        recentBlockhash: blockhash.blockhash,
        instructions: [
          SystemProgram.transfer(
            fromPubkey: address1,
            toPubkey: sol.Pubkey.fromString(toAddress),
            lamports: sol.solToLamports(value),
          ),
        ]);

    transaction.sign([wallet1]);

    try {
      var txid = await connection.sendAndConfirmTransaction(transaction);

      // print(txid);
      if (txid.isNotEmpty) {
        await StoreHashDetails().hashDetails(
            hash: txid.toString(),
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
          Utils.snackBarErrorMessage("Something went wrong");
          Navigator.pop(context);
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        Utils.snackBarErrorMessage("Something went wrong");
        Navigator.pop(context);
      }
    }
  }

  sendMainnet(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    final cluster = sol.Cluster.mainnet;
    final connection = sol.Connection(cluster);
    var mnemonic = Bip39Mnemonic.fromString(userWallet.mnemonic.trim());
    final seed = Bip39SeedGenerator(mnemonic).generate();
    final solDefaultPath =
        Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
    final solPrivateKey =
        TronPrivateKey.fromBytes(solDefaultPath.privateKey.raw);
    final wallet1 =
        sol.Keypair.fromSeedSync(Uint8List.fromList(solPrivateKey.toBytes()));
    final address1 = wallet1.pubkey;
    double value = double.parse(enterAmount);

    final sol.BlockhashWithExpiryBlockHeight blockhash =
        await connection.getLatestBlockhash();

    final transaction = sol.Transaction.v0(
        payer: wallet1.pubkey,
        recentBlockhash: blockhash.blockhash,
        instructions: [
          SystemProgram.transfer(
            fromPubkey: address1,
            toPubkey: sol.Pubkey.fromString(toAddress),
            lamports: sol.solToLamports(value),
          ),
        ]);

    transaction.sign([wallet1]);

    var txid = await connection.sendAndConfirmTransaction(
      transaction,
    );
    if (txid.isNotEmpty) {
      await StoreHashDetails().hashDetails(
          hash: txid.toString(),
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
        Utils.snackBarErrorMessage("Something went wrong");
        Navigator.pop(context);
      }
    }
  }

  Future<num> solEstGas(BuildContext context,
      {required AssetModel coinData,
      required String enterAmount,
      required String toAddress,
      required UserWalletDataModel userWallet}) async {
    final cluster = sol.Cluster.devnet;
    final connection = sol.Connection(cluster);
    double value = double.parse(enterAmount);

    final sol.BlockhashWithExpiryBlockHeight blockhash =
        await connection.getLatestBlockhash();

    final transaction = sol.Transaction.v0(
        payer: sol.Pubkey.fromString(coinData.address!),
        recentBlockhash: blockhash.blockhash,
        instructions: [
          SystemProgram.transfer(
            fromPubkey: sol.Pubkey.fromString(coinData.address!),
            toPubkey: sol.Pubkey.fromString(toAddress),
            lamports: sol.solToLamports(value),
          ),
        ]);

    try {
      var gas = await connection.getFeeForMessage(transaction.message);

      return sol.lamportsToSol(BigInt.from(gas));
    } on Exception catch (e) {
      return 0;
    }
  }
}
