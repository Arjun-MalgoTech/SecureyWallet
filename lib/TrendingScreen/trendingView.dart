import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalanceFunction.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Transaction_Action_Screen/View/Transaction_Action_view.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';

class TrendingTokens extends StatefulWidget {
  const TrendingTokens({super.key});

  @override
  _TrendingTokensState createState() => _TrendingTokensState();
}

class _TrendingTokensState extends State<TrendingTokens> {
  String selectedNetwork = "BNB";
  LocalStorageService localStorageService = LocalStorageService();

  /// 🔹 Static Testnet Tokens
  final Map<String, List<Map<String, dynamic>>> testnetTokens = {
    "BNB": [
      {
        "name": "BNB Testnet",
        "symbol": "BNB",
        "tokenAddress": "",
        "network": "BNB Smart Chain",
        "rpcURL": "https://data-seed-prebsc-1-s1.binance.org:8545/",
        "image":
        "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970",
      },
      {
        "name": "BUSD Testnet",
        "symbol": "BUSD",
        "tokenAddress": "0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee",
        "network": "BNB Smart Chain",
        "rpcURL": "https://data-seed-prebsc-1-s1.binance.org:8545/",
        "image":
        "https://s2.coinmarketcap.com/static/img/coins/64x64/4687.png",
      },
    ],
    "ETH": [
      {
        "name": "Ethereum Goerli",
        "symbol": "ETH",
        "tokenAddress": "",
        "network": "Ethereum",
        "rpcURL": "https://rpc.ankr.com/eth_goerli",
        "image":
        "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
      },
      {
        "name": "USDT Goerli",
        "symbol": "USDT",
        "tokenAddress": "0x509ee0d083ddf8ac028f2a56731412edd63223b9",
        "network": "Ethereum",
        "rpcURL": "https://rpc.ankr.com/eth_goerli",
        "image":
        "https://s2.coinmarketcap.com/static/img/coins/64x64/825.png",
      },
    ],
    "TRX": [
      {
        "name": "Tron Shasta",
        "symbol": "TRX",
        "tokenAddress": "",
        "network": "Tron",
        "rpcURL": "https://api.shasta.trongrid.io",
        "image":
        "https://s2.coinmarketcap.com/static/img/coins/64x64/1958.png",
      },
    ],
    "SOL": [
      {
        "name": "Solana Devnet",
        "symbol": "SOL",
        "tokenAddress": "",
        "network": "Solana",
        "rpcURL": "https://api.devnet.solana.com",
        "image":
        "https://assets.coingecko.com/coins/images/4128/large/solana.png",
      },
    ],
  };

  final networkOptions = [
    {
      "name": "BNB",
      "icon":
      "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970"
    },
    {
      "name": "ETH",
      "icon":
      "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
    },
    {
      "name": "TRX",
      "icon": "https://s2.coinmarketcap.com/static/img/coins/128x128/1958.png"
    },
    {
      "name": "SOL",
      "icon":
      "https://assets.coingecko.com/coins/images/4128/large/solana.png"
    },
  ];

  String getNetworkIcon(String networkName) {
    return networkOptions
        .firstWhere((n) => n['name'] == networkName, orElse: () => networkOptions[0])["icon"] ??
        "";
  }

  AssetModel trendingToAssetModel(Map<String, dynamic> token) {
    return AssetModel(
      coinName: token['name'] ?? '',
      coinSymbol: token['symbol'] ?? '',
      imageUrl: token['image'] ?? '',
      tokenAddress: token['tokenAddress'] ?? '',
      network: token['network'] ?? selectedNetwork,
      coinType: "2",
      gasPriceSymbol: selectedNetwork,
      address: (selectedNetwork == "ETH" || selectedNetwork == "BNB")
          ? ""
          : assetAddressGenerate.generateAddress(
        selectedNetwork,
        localStorageService.activeWalletData!.mnemonic,
      ),
      tokenDecimal: "18",
      rpcURL: token['rpcURL'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();

    final tokens = testnetTokens[selectedNetwork] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          "Testnet Tokens",
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                AppText("Select Network:",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF27282B),
                  value: selectedNetwork,
                  iconEnabledColor: Colors.white,
                  underline: const SizedBox(),
                  items: networkOptions.map((network) {
                    return DropdownMenuItem<String>(
                      value: network["name"],
                      child: Row(
                        children: [
                          Image.network(network["icon"]!, width: 20, height: 20),
                          const SizedBox(width: 10),
                          Text(
                            network["name"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedNetwork = value);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView.builder(
              itemCount: tokens.length,
              itemBuilder: (context, index) {
                final token = tokens[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(token['image']),
                    backgroundColor: Colors.transparent,
                  ),
                  title: AppText(token['name'],
                      color: Colors.white, fontWeight: FontWeight.w600),
                  subtitle: AppText(token['network'],
                      color: Colors.white70, fontSize: 14),
                  trailing: AppText(token['symbol'],
                      color: Colors.orangeAccent, fontSize: 16),
                  onTap: () async {
                    final asset = trendingToAssetModel(token);
                    String liveBalance = "0.0";

                    print("🧩 Selected Asset: ${asset.toJson()}");

                    // Fetch balance if RPC and token are set
                    if (asset.rpcURL != null && asset.rpcURL!.isNotEmpty) {
                      try {
                        liveBalance = await assetBalanceFunction.evmTokenBalance(
                          asset,
                          localStorageService.activeWalletData!.privateKey,
                        );
                      } catch (e) {
                        print("⚠️ Error fetching balance: $e");
                      }
                    }

                    // Navigate to transaction screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionAction(
                          coinData: asset,
                          balance: liveBalance,
                          userWallet: localStorageService.activeWalletData!,
                          usdPrice: 0.0,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E1E1E),
    );
  }
}
