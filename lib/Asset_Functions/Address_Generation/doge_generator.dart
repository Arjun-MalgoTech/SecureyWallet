import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:flutter_bitcoin/src/ecpair.dart' show ECPair;
import 'package:flutter_bitcoin/src/payments/index.dart' show PaymentData;


final dogeTestnet = NetworkType(
  messagePrefix: '\x19Dogecoin Signed Message:\n',
  bech32: null,
  bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
  pubKeyHash: 0x71,
  scriptHash: 0xc4,
  wif: 0xf1,
);
final dogeTestnetBip32 = bip32.NetworkType(
  wif: 0xf1,
  bip32: bip32.Bip32Type(public: 0x043587cf, private: 0x04358394),
);

String generateAddressFromMnemonic(String mnemonic) {
  try {
    final seed = bip39.mnemonicToSeed(mnemonic);

    final root = bip32.BIP32.fromSeed(seed, dogeTestnetBip32);

    final child = root.derivePath("m/44'/1'/0'/0/0"); // '1' for testnets

    final wif = child.toWIF();

    final keyPair = ECPair.fromWIF(wif, network: dogeTestnet);

    final address = P2PKH(
      data: PaymentData(pubkey: keyPair.publicKey),
      network: dogeTestnet,
    ).data.address;

    print("Mnemonic: $mnemonic");
    print("Derived Private Key (WIF): $wif");
    print("Dogecoin Testnet Address: $address");

    return address!;
  } catch (e) {
    print("Error generating address: $e");
    return "Error";
  }
}


final dogeMainnetBitcoinFlutter = NetworkType(
  messagePrefix: '\x19Dogecoin Signed Message:\n',
  bech32: null,
  bip32: Bip32Type(public: 0x02facafd, private: 0x02fac398),
  pubKeyHash: 0x1E, // Dogecoin mainnet prefix (D...)
  scriptHash: 0x16,
  wif: 0x9E, // WIF prefix for Dogecoin mainnet
);

final dogeMainnetBip32 = bip32.NetworkType(
  wif: 0x9E,
  bip32: bip32.Bip32Type(public: 0x02facafd, private: 0x02fac398),
);

String generateMainnetAddressFromMnemonic(String mnemonic) {
  try {
    final seed = bip39.mnemonicToSeed(mnemonic);

    final root = bip32.BIP32.fromSeed(seed, dogeMainnetBip32);

    final child = root.derivePath("m/44'/3'/0'/0/0");

    final wif = child.toWIF();

    final keyPair = ECPair.fromWIF(wif, network: dogeMainnetBitcoinFlutter);

    final address = P2PKH(
      data: PaymentData(pubkey: keyPair.publicKey),
      network: dogeMainnetBitcoinFlutter,
    ).data.address;

    print("Mnemonic: $mnemonic");
    print("Derived Private Key (WIF): $wif");
    print("Dogecoin Mainnet Address: $address");

    return address!;
  } catch (e) {
    print("Error generating address: $e");
    return "Error";
  }
}