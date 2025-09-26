import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:flutter_bitcoin/src/models/networks.dart' as NETWORKS;
import 'package:flutter_bitcoin/src/ecpair.dart' show ECPair;
import 'package:flutter_bitcoin/src/payments/index.dart' show PaymentData;
import 'package:flutter_bitcoin/src/payments/p2wpkh.dart' show P2WPKH;

String btcTestnet(String mnemonic) {
  final testnet = NETWORKS.testnet;
  String seedPhrase = mnemonic.trim();
  var seed = bip39.mnemonicToSeed(seedPhrase);
  final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
  var privateKey = wallet.derivePath("m/84'/1'/0'/0/0").toWIF();
  final keyPair = ECPair.fromWIF(privateKey);
  final publickey = keyPair.publicKey;
  final address = P2WPKH(data: PaymentData(pubkey: publickey), network: testnet)
      .data
      .address;
  return address!;
}

String btcMainnet(String mnemonic) {
  final mainnet = NETWORKS.bitcoin;
  String seedPhrase = mnemonic.trim();
  var seed = bip39.mnemonicToSeed(seedPhrase);
  final bip32.BIP32 wallet = bip32.BIP32.fromSeed(seed);
  var privateKey = wallet.derivePath("m/84'/0'/0'/0/0").toWIF();
  final keyPair = ECPair.fromWIF(privateKey);
  final publickey = keyPair.publicKey;
  final address = P2WPKH(data: PaymentData(pubkey: publickey), network: mainnet)
      .data
      .address;
  return address!;
}
