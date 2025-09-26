import 'package:tonutils/tonutils.dart' as tonMnemonic;

String generateTonAddress(String mnemonic) {
  try {
    final List<String> mnemonicList = mnemonic.split(' ');
    final keyPair = tonMnemonic.Mnemonic.toKeyPair(mnemonicList);
    final wallet =
        tonMnemonic.WalletContractV4R2.create(publicKey: keyPair.publicKey);
    return wallet.address.toString();
  } catch (e) {
    return 'Error generating TON address';
  }
}
