import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Store_Hash.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class StoreHashDetails {
  GetHashStorage getHashStorage = GetHashStorage();
  Future hashDetails(
      {required String hash,
      required String fromAddress,
      required AssetModel coinData,
      required String toAddress,
      required String amount}) async {
    await getHashStorage.updateHashToList(
        "$fromAddress${coinData.coinType}${coinData.coinType == "2" ? coinData.tokenAddress : ""}${coinData.coinSymbol}${coinData.coinName}",
        {
          "hash": hash,
          "toAddress": toAddress,
          "amount": amount,
          "time": DateTime.now().millisecondsSinceEpoch
        });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool(ApiKeyService.notificationStatus) ?? true;
    // bool notificationStatus = true;
    if (status) {
      var urlLink = "";
      if (coinData.gasPriceSymbol == "TRX" ||
          coinData.gasPriceSymbol == "tTRX") {
        urlLink = "${coinData.explorerURL!}transaction/$hash";
      } else if (coinData.gasPriceSymbol == "tSOL") {
        urlLink = "${coinData.explorerURL!}tx/$hash?cluster=devnet";
      } else if (coinData.gasPriceSymbol == "DCX") {
        urlLink = "${coinData.explorerURL!}/tx/$hash";
      } else if (coinData.rpcURL == 'https://mainnetcoin.d-ecosystem.io/' &&
          coinData.coinType == '2') {
        urlLink = "${coinData.explorerURL!}/tx/$hash";
      } else if (coinData.coinSymbol == "tXRP" ||
          coinData.coinSymbol == "XRP") {
        urlLink = "${coinData.explorerURL!}transactions/$hash";
      } else if (coinData.coinSymbol == "tBTC" ||
          coinData.coinSymbol == "BTC") {
        urlLink = "${coinData.explorerURL!}tx/$hash";
      } else {
        urlLink = "${coinData.explorerURL!}/tx/$hash";
      }
      await showNotificationWithLink(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Transaction is processed ✅',
          body:
              '${formatBalanceToString(amount)} ${coinData.coinSymbol} is sent to $toAddress',
          url: urlLink);
    }
  }

  String formatBalanceToString(String balance) {
    Decimal parsedBalance = Decimal.parse(balance);
    String formattedBalance = parsedBalance.toStringAsFixed(8);
    if (formattedBalance.contains('.')) {
      formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
      if (formattedBalance.endsWith('.')) {
        formattedBalance =
            formattedBalance.substring(0, formattedBalance.length - 1);
      }
    }

    return formattedBalance;
  }

  Future<void> showNotificationWithLink(
      {required int id,
      required String title,
      required String body,
      required String url}) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This channel is used for notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(9999 + 1), // Notification ID
      title, // Title
      body, // Body
      notificationDetails,
      payload: url, // Link as payload
    );
  }
}
