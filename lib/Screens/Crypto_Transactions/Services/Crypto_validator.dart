bool isValidCryptoAddress(String address, String coinSymbol) {
  // Ethereum address regex
  RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');

  // BTC address regex (P2PKH, P2SH, Bech32)
  RegExp btcAddressRegex =
  RegExp(r'^(1[a-km-zA-HJ-NP-Z1-9]{25,34}' + // Mainnet P2PKH addresses
      r'|3[a-km-zA-HJ-NP-Z1-9]{25,34}' + // Mainnet P2SH addresses
      r'|bc1[a-zA-HJ-NP-Z0-9]{39,59}' + // Mainnet Bech32 addresses
      r'|m[a-km-zA-HJ-NP-Z1-9]{25,34}' + // Testnet P2PKH addresses
      r'|n[a-km-zA-HJ-NP-Z1-9]{25,34}' + // Testnet P2PKH addresses
      r'|2[a-km-zA-HJ-NP-Z1-9]{25,34}' + // Testnet P2SH addresses
      r'|tb1[a-zA-HJ-NP-Z0-9]{39,59})$' // Testnet Bech32 addresses
  );

  // Tron address regex
  RegExp tronAddressRegex = RegExp(r'^T[a-zA-Z0-9]{33}$');

  // Solana address regex
  RegExp solanaAddressRegex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');

  // XRP address regex
  RegExp xrpAddressRegex = RegExp(r'^r[1-9A-HJ-NP-Za-km-z]{25,34}$');

  // Terra Classic (LUNC) address regex
  RegExp luncAddressRegex = RegExp(r'^terra1[a-z0-9]{38}$');

  // Kava address regex
  RegExp kavaAddressRegex = RegExp(r'^kava1[a-z0-9]{38}$');

  // Polkadot address regex
  RegExp polkadotAddressRegex = RegExp(r'^[1-9A-HJ-NP-Za-z]{48}$');

  // Cosmos address regex
  RegExp cosmosAddressRegex = RegExp(r'^cosmos1[a-z0-9]{38}$');

  // Dogecoin address regex (Mainnet and Testnet)
  RegExp dogecoinMainnetRegex =
  RegExp(r'^(D[a-km-zA-HJ-NP-Z1-9]{33,34})$'); // Mainnet
  RegExp dogecoinTestnetRegex =
  RegExp(r'^(n[a-km-zA-HJ-NP-Z1-9]{33,34})$'); // Testnet

  // Litecoin address regex (Mainnet and Testnet)
  // Litecoin Mainnet regex: Starts with 'L', followed by 33 to 34 alphanumeric characters.
  RegExp litecoinMainnetRegex = RegExp(r'^(L[a-km-zA-HJ-NP-Z1-9]{33,34})$');

// Litecoin Testnet regex: Starts with 'm' or 'n', followed by 33 to 34 alphanumeric characters.
  RegExp litecoinTestnetRegex =
  RegExp(r'^[mn][a-km-zA-HJ-NP-Z1-9]{33,34}$'); // Testnet

  // TON address regex (Mainnet and Testnet)
  RegExp tonAddressRegex =
  RegExp(r'^(EQ[a-zA-Z0-9_-]{39,40})$'); // TON addresses

  // ADA address regex (Mainnet and Testnet)
  RegExp adaAddressRegex = RegExp(
      r'^(addr1[a-z0-9]{58})$'); // Mainnet (For testnet, change the prefix to "addr_test")

  switch (coinSymbol) {
    case 'BTC':
    case 'tBTC':
      return btcAddressRegex.hasMatch(address);

    case 'TRX':
    case 'tTRX':
      return tronAddressRegex.hasMatch(address);

    case 'SOL':
    case 'tSOL':
      return solanaAddressRegex.hasMatch(address);

    case 'XRP':
    case 'tXRP':
      return xrpAddressRegex.hasMatch(address);

    case 'LUNC':
    case 'tLUNC':
      return luncAddressRegex.hasMatch(address);

    case 'KAVA':
      return kavaAddressRegex.hasMatch(address);

    case 'DOT':
    case 'tDOT':
      return polkadotAddressRegex.hasMatch(address);

    case 'ATOM':
      return cosmosAddressRegex.hasMatch(address);
    case 'DOGE':
      return dogecoinMainnetRegex.hasMatch(address);
    case 'tDOGE':
      return dogecoinTestnetRegex.hasMatch(address);

    case 'LTC':
      return litecoinMainnetRegex.hasMatch(address);
    case 'tLTC':
      return litecoinTestnetRegex.hasMatch(address);

    case 'TON':
    case 'tTON':
      return tonAddressRegex.hasMatch(address);

    case 'ADA':
    case 'tADA':
      return adaAddressRegex.hasMatch(address);

    default:
      return ethereumAddressRegex
          .hasMatch(address); // Invalid or unsupported coin symbol
  }
}