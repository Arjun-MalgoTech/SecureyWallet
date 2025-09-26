import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:flutter_bitcoin/src/ecpair.dart' show ECPair;
import 'package:flutter_bitcoin/src/payments/index.dart' show PaymentData;



final litecoinTestnet = NetworkType(
  messagePrefix: '\x19Litecoin Signed Message:\n',
  bip32: Bip32Type(public: 0x043587CF, private: 0x04358394), // Testnet
  pubKeyHash: 0x6F,
  scriptHash: 0x3A,
  wif: 0xEF,
);

final litecoinTestnetBip32 = bip32.NetworkType(
  wif: 0xEF,
  bip32: bip32.Bip32Type(public: 0x043587CF, private: 0x04358394),
);

String generateLTCAddressFromMnemonic(String mnemonic) {
  try {
    final seed = bip39.mnemonicToSeed(mnemonic);

    final root = bip32.BIP32.fromSeed(seed, litecoinTestnetBip32);

    final child = root.derivePath("m/44'/1'/0'/0/0"); // '1' for testnets

    final wif = child.toWIF();

    final keyPair = ECPair.fromWIF(wif, network: litecoinTestnet);

    final address = P2PKH(
      data: PaymentData(pubkey: keyPair.publicKey),
      network: litecoinTestnet,
    ).data.address;

    print("Mnemonic: $mnemonic");
    print("Derived Private Key (WIF): $wif");
    print("Litecoin Testnet Address: $address");

    return address!;
  } catch (e) {
    print("Error generating address: $e");
    return "Error";
  }
}

final litecoinMainnet = NetworkType(
  messagePrefix: '\x19Litecoin Signed Message:\n',
  bip32: Bip32Type(public: 0x0488B21E, private: 0x0488ADE4), // Mainnet
  pubKeyHash: 0x30,
  scriptHash: 0x32,
  wif: 0xB0,
);
final litecoinMainnetBip32 = bip32.NetworkType(
  wif: 0xB0,
  bip32: bip32.Bip32Type(public: 0x0488B21E, private: 0x0488ADE4),
);
String generateLTCMainnetAddress(String mnemonic) {
  final seed = bip39.mnemonicToSeed(mnemonic);

  final root = bip32.BIP32.fromSeed(seed, litecoinMainnetBip32);

  final child = root.derivePath("m/44'/1'/0'/0/0"); // '1' for testnets

  final wif = child.toWIF();

  final keyPair = ECPair.fromWIF(wif, network: litecoinMainnet);
  final address = P2PKH(
    data: PaymentData(pubkey: keyPair.publicKey),
    network: litecoinMainnet,
  ).data.address;
  print("litecoin address ::$address");
  return address!;
}
