import 'package:flutter/services.dart';

class HexBytes {
  Uint8List hexToBytes(String hexString) {
    return Uint8List.fromList(List.generate(hexString.length ~/ 2,
        (i) => int.parse(hexString.substring(2 * i, 2 * i + 2), radix: 16)));
  }

  String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  BigInt etherToWei(String etherStr) {
    // Split the amount into integer and fractional parts
    List<String> parts = etherStr.split('.');

    // Handle the integer part
    BigInt integerPart = BigInt.parse(parts[0]);

    // Handle the fractional part
    // If there is no fractional part, default to zero
    BigInt fractionalPart = BigInt.zero;
    if (parts.length > 1) {
      // Pad the fractional part to ensure it has 18 digits
      String fractionalStr = parts[1].padRight(18, '0').substring(0, 18);
      fractionalPart = BigInt.parse(fractionalStr);
    }

    // Calculate total Wei
    BigInt weiAmount = (integerPart * BigInt.from(10).pow(18)) + fractionalPart;

    return weiAmount;
  }

  BigInt etherTokenToWei(String etherStr, int decimals) {
    // Split the amount into integer and fractional parts
    List<String> parts = etherStr.split('.');

    // Handle the integer part
    BigInt integerPart = BigInt.parse(parts[0]);

    // Handle the fractional part
    // If there is no fractional part, default to zero
    BigInt fractionalPart = BigInt.zero;
    if (parts.length > 1) {
      // Pad the fractional part to ensure it has the required number of digits
      String fractionalStr =
          parts[1].padRight(decimals, '0').substring(0, decimals);
      fractionalPart = BigInt.parse(fractionalStr);
    }

    // Calculate total Wei using the provided decimals
    BigInt weiAmount =
        (integerPart * BigInt.from(10).pow(decimals)) + fractionalPart;
    print("weiAmount $weiAmount");
    return weiAmount;
  }

  double etherWeiToValue(BigInt value) {
    return value / BigInt.parse("1000000000000000000");
  }
}

HexBytes hexBytes = HexBytes();
