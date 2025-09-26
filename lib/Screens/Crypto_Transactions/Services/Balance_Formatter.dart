import 'package:decimal/decimal.dart';

class BalanceFormat {
  String formatBalance(String balance) {
    Decimal parsedBalance = Decimal.parse(balance);
    String formattedBalance = parsedBalance.toString();

    if (formattedBalance.contains('.')) {
      formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
      if (formattedBalance.endsWith('.')) {
        formattedBalance =
            formattedBalance.substring(0, formattedBalance.length - 1);
      }
    }

    return formattedBalance;
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
}

BalanceFormat balanceFormat = BalanceFormat();
