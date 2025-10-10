import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/solana/src/keypair/private_key.dart';
import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/btc_generator.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/doge_generator.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/ltc_generator.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/ton_generator.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/vechain_generator.dart';

class AssetAddressGenerate {
  String generateAddress(String coin, String mnemonic) {
    var e = Bip39Mnemonic.fromString(mnemonic);
    final seed = Bip39SeedGenerator(e).generate();

    switch (coin) {
      case "BTC":
        return btcMainnet(mnemonic);
      case "tBTC":
        return btcTestnet(mnemonic);
      case "LTC":
        return generateLTCMainnetAddress(mnemonic);
      case "tLTC":
        return generateLTCAddressFromMnemonic(mnemonic);
      case "tDOGE":
        return generateAddressFromMnemonic(mnemonic);
      case "tTON":
        return generateTonAddress(mnemonic);
      case "DOGE":
        return generateMainnetAddressFromMnemonic(mnemonic);

      // case 'SOL' || 'tSOL':
      //   final solanaDefaultPath =
      //       Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
      //   final solanaPrivateKey =
      //       SolanaPrivateKey.fromSeed(solanaDefaultPath.privateKey.raw);
      //   return solanaPrivateKey.publicKey().toAddress().address;
      // // case 'tVET' || 'VET':
      // //   return generateVeChainAddressFromMnemonic([mnemonic]);
      case 'TRX' || 'tTRX':
        final tronDefaultPath =
            Bip44.fromSeed(seed, Bip44Coins.tron).deriveDefaultPath;
        final tronPrivateKey =
            TronPrivateKey.fromBytes(tronDefaultPath.privateKey.raw);
        return tronPrivateKey.publicKey().toAddress().toAddress();
      case 'XRP' || 'tXRP':
        final xrpDefaultPath =
            Bip44.fromSeed(seed, Bip44Coins.ripple).deriveDefaultPath;
        return xrpDefaultPath.publicKey.toAddress;
      default:
        throw Exception("Unsupported coin: $coin");
    }
  }
}

AssetAddressGenerate assetAddressGenerate = AssetAddressGenerate();
