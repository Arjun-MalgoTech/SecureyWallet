// lib/utils/explorer_launcher.dart
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:url_launcher/url_launcher.dart';

// adjust as needed
class LaunchExplorer {
  Future<void> launchExplorerAddressURL({
    required AssetModel coin,
    required String walletAddress,
  }) async {
    final address = coin.address;

    final explorerURL = coin.explorerURL!;
    print("${explorerURL}");
    final isTestnet = coin.coinSymbol!.startsWith("t");

    String? url;

    if (coin.coinType == "3") {
      if (coin.coinSymbol == "VET" || coin.coinSymbol == "tVET") {
        url = "${explorerURL}accounts/$address";
      } else if (coin.coinSymbol == "doge" || coin.coinSymbol == "tdoge") {
        url = "$explorerURL/search-results?q=$address";
      } else if (coin.coinSymbol == "TRX") {
        url = "${explorerURL}address/$address";
        print("naviiii ${explorerURL}address/$address");
      } else if (coin.coinSymbol == "XRP" || coin.coinSymbol == "tXRP") {
        url = "${explorerURL}accounts/$address";
      } else if (coin.coinSymbol == "tSOL") {
        url = "${explorerURL}address/$address?cluster=devnet";
      } else if (coin.coinSymbol == "LTC" || coin.coinSymbol == "tLTC") {
        url = "${explorerURL}address/$address";
      } else {
        url = "${explorerURL}address/$address";
        print(",,,,,,${explorerURL}address/$address");
      }
    } else if (coin.coinType == "2" &&
        (coin.gasPriceSymbol == "SOL" || coin.gasPriceSymbol == "tSOL")) {
      final cluster = coin.gasPriceSymbol == "SOL" ? "" : "?cluster=devnet";
      url = "${explorerURL}address/$address$cluster";
    } else if (coin.coinType == "2" &&
        (coin.gasPriceSymbol?.toUpperCase().contains("TRX") ?? false)) {
      url = "${explorerURL}address/$address";
    } else if (coin.coinSymbol == 'STRK') {
      url = "${explorerURL}tx/$walletAddress";
      print(",,,,,,$url");
    } else {
      url = "${explorerURL}/address/$walletAddress";
      print(",,,,,,$url");
    }

    if (url != null && !await launch(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

LaunchExplorer launchExplorer = LaunchExplorer();
