import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CommonCalculationFunctions {
  static int otpSeconds = 120;

  static bool isValidDecimal(String value) {
    String regex = r'^\d+\.?\d*';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(value);
  }

  static bool isValidPanNo(String value) {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value);
  }

  static List<TextInputFormatter> fourDecimals() {
    return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}'))];
  }

  static List<TextInputFormatter> dynamicDecimals(int a) {
    return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,' '$a}'))];
  }

  static List<TextInputFormatter> twoDecimals() {
    return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
  }

  static List<TextInputFormatter> numericOnly() {
    return [FilteringTextInputFormatter.allow(RegExp(r'\d*'))];
  }

  static String maskEmail(String input) {
    String first = "${input.substring(0, 2)}**";
    String mid = "${input.substring(input.indexOf("@")).substring(0, 1)}**";
    String last = input.substring(input.lastIndexOf("."));
    return first + mid + last;
  }

  static String maskPhone(String input) {
    String first = "${input.substring(0, 5)}*****";
    // String mid = "${input.substring(input.indexOf("@")).substring(0, 3)}**";
    String last = input.characters.last;
    return first + last;
  }

  static String formatDateTimeGMT(String input) {
    DateTime dateTime =
        DateTime.parse(input).add(const Duration(hours: 5, minutes: 30));
    var formattedTime = DateFormat('yyyy-MMM-dd').add_jms().format(dateTime);
    return formattedTime.toString();
  }

  static String formatDateTimeGMTIndia(String input) {
    DateTime dateTime = DateTime.parse(input);
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    // Check if the input date is today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      var formattedTime = DateFormat.jm().format(dateTime);
      return 'Today $formattedTime';
    }
    // Check if the input date is yesterday
    else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      var formattedTime = DateFormat.jm().format(dateTime);
      return 'Yesterday $formattedTime';
    } else {
      var formattedTime = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedTime.toString();
    }
  }

  static DateTime dateTimeAddHours(String input) {
    DateTime dateTime = DateTime.parse(input.replaceAll("Z", ''))
        .add(const Duration(hours: 5, minutes: 30));
    return dateTime;
  }

  static Duration dateTimeDuration(String input) {
    DateTime dateTime = DateTime.parse(input.replaceAll("Z", ''))
        .add(const Duration(hours: 5, minutes: 30));
    Duration difference = dateTime.difference(DateTime.now());
    return difference;
  }

  static String formatTime(DateTime dateTime) {
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    if (hour == 0) {
      hour = 12; // 12 AM should be displayed as 12
    }
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  static String maskWalletAddress(String input) {
    String first = input.substring(0, 6); // Keep the first 6 characters
    String last =
        input.substring(input.length - 4); // Keep the last 4 characters
    String masked = first + '...' + last;
    return masked;
  }

  static String moneyFormat(String price) {
    final oCcy = NumberFormat("#,##0.0000", "en_US");
    String value = oCcy.format(double.parse(price));
    return value;
  }

  static String moneyFormat8Digits(String price) {
    final oCcy = NumberFormat("#,##0.00000000", "en_US");
    String value = oCcy.format(double.parse(price));
    return value;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  static String kmb(var value) {
    double num = double.parse(value.toString());
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(2)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(2)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(2)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(2)} B";
    } else {
      return num.toStringAsFixed(4);
    }
  }

  static String decimalsLimit(var value) {
    double num = double.parse(value.toString());
    if (num > 999 && num < 99999) {
      return num.toStringAsFixed(4);
    } else if (num > 99999 && num < 999999) {
      return num.toStringAsFixed(2);
    } else if (num > 999999 && num < 999999999) {
      return num.toStringAsFixed(2);
    } else if (num > 999999999) {
      return num.toStringAsFixed(1);
    } else {
      return num.toStringAsFixed(8);
    }
  }
}

extension TruncateDoubles on double {
  double truncateToDecimalPlaces(int fractionalDigits) =>
      (this * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
}
