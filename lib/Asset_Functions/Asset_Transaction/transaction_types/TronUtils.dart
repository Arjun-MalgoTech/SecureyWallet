import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:convert/convert.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';


class TronUtils {
  static const String _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  /// Decode a Base58 string into bytes
  static Uint8List _base58Decode(String input) {
    BigInt decoded = BigInt.zero;

    for (int i = 0; i < input.length; i++) {
      final int index = _base58Alphabet.indexOf(input[i]);
      if (index == -1) {
        throw FormatException("Invalid Base58 character: ${input[i]}");
      }
      decoded = decoded * BigInt.from(58) + BigInt.from(index);
    }

    final result = <int>[];
    while (decoded > BigInt.zero) {
      result.insert(0, (decoded % BigInt.from(256)).toInt());
      decoded = decoded ~/ BigInt.from(256);
    }

    final int leadingZeros =
        input.split('').takeWhile((char) => char == '1').length;
    return Uint8List.fromList(List.filled(leadingZeros, 0) + result);
  }

  /// Validate the checksum of a TRON Base58 address
  static bool _validateChecksum(Uint8List data) {
    final checksum = data.sublist(data.length - 4);
    final payload = data.sublist(0, data.length - 4);

    final hash = sha256.convert(sha256.convert(payload).bytes).bytes;
    return List.generate(4, (i) => checksum[i] == hash[i]).every((v) => v);
  }

  /// Convert a TRON Base58 address to Hex
  static String base58ToHex(String base58Address) {
    final decoded = _base58Decode(base58Address);

    if (decoded.length != 25 || decoded[0] != 0x41) {
      throw FormatException("Invalid TRON Base58 address format");
    }

    if (!_validateChecksum(decoded)) {
      throw FormatException("Invalid TRON address checksum");
    }

    return hex.encode(decoded.sublist(0, 21)).toLowerCase();
  }

  /// Fetch TRON token information (decimals, name, symbol)
  static Future<Map<String, dynamic>> getTokenInfo(
      {required String rpcurl,
      required String contractAddress,
      required AssetModel coinData,
      required UserWalletDataModel selectedWalletData}) async {
    var coinAddress = coinData.address == ""
        ? assetAddressGenerate.generateAddress(
            coinData.coinSymbol!, selectedWalletData.mnemonic)
        : coinData.address!;

    final String rpcUrl = rpcurl;

    print("ownerAddress$coinAddress");
    // Convert addresses to Hex if necessary
    final String hexContractAddress = contractAddress.startsWith('41')
        ? contractAddress
        : base58ToHex(contractAddress);
    final String hexOwnerAddress =
        coinAddress.startsWith('41') ? coinAddress : base58ToHex(coinAddress);

    final methods = ['decimals()', 'name()', 'symbol()'];
    final result = <String, dynamic>{};

    try {
      for (final method in methods) {
        result[method.replaceAll('()', '')] = await _callContractMethod(
            rpcUrl, hexContractAddress, hexOwnerAddress, method);
      }
      return result;
    } catch (e) {
      throw Exception("Failed to fetch token data: $e");
    }
  }

  /// Call a contract method
  static Future<String> _callContractMethod(String rpcUrl,
      String contractAddress, String ownerAddress, String method) async {
    final String url = "$rpcUrl/wallet/triggerconstantcontract";

    final Map<String, dynamic> requestData = {
      'owner_address': ownerAddress,
      'contract_address': contractAddress,
      'function_selector': method,
      'parameter': '',
      'call_value': 0,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['constant_result'] != null &&
          responseData['constant_result'].isNotEmpty) {
        final rawData = responseData['constant_result'][0];

        if (method == 'decimals()') {
          return BigInt.parse(rawData, radix: 16).toString();
        }
        return _hexToAscii(rawData);
      } else {
        throw Exception('Error in response: ${responseData['message']}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Convert a hex string to ASCII
  static String _hexToAscii(String hex) {
    hex = hex.replaceAll('0x', '').replaceAll(RegExp(r'0+$'), '');
    final bytes = List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    );
    return String.fromCharCodes(bytes);
  }
}
