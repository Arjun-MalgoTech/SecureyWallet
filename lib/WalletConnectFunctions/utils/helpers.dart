import 'package:flutter/material.dart';
import 'package:securywallet/WalletConnectFunctions/utils/eip155_data.dart';
import 'package:securywallet/WalletConnectFunctions/utils/solana_data.dart';

String getChainName(String value) {
  try {
    if (value.startsWith('eip155')) {
      return Eip155Data.chains[value]!.name;
    } else if (value.startsWith('solana')) {
      return SolanaData.chains[value]!.name;
    }
  } catch (e) {
    debugPrint('Invalid chain');
  }
  return 'Unknown';
}
