import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Transaction_Action_Screen/View/Transaction_Action_view.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';

class TrendingTokens extends StatefulWidget {
  @override
  _TrendingTokensState createState() => _TrendingTokensState();
}

class _TrendingTokensState extends State<TrendingTokens> {
  late Future<List<Map<String, dynamic>>> trendingTokens;
  final String apiKey = '9b4cc00e-85f2-412f-8669-5b6b4ef12f0e';

  @override
  void initState() {
    super.initState();
    trendingTokens = fetchTrendingTokens();
  }

  LocalStorageService localStorageService = LocalStorageService();

  // Convert trending token Map to AssetModel
  AssetModel trendingToAssetModel(Map<String, dynamic> token) {
    final rpcURLs = {
      "Ethereum": "https://mainnet.infura.io/v3/${apiKeyService.infuraKey}",
      "BNB Smart Chain": "https://bsc-dataseed.binance.org",
      "Polygon": "https://polygon-rpc.com",
      "Avalanche": "https://api.avax.network/ext/bc/C/rpc",
      "Tron": "https://api.trongrid.io",
      "Solana": "https://api.mainnet-beta.solana.com",
      "Terra Classic": "https://terra-classic-lcd.publicnode.com",
    };

    return AssetModel(
      coinName: token['name'] ?? '',
      coinSymbol: token['symbol'] ?? '',
      imageUrl: token['logo'] ?? '',
      tokenAddress: token['tokenAddress'] ?? '',
      network: token['network'] ?? 'Binance',
      coinType: "2",
      gasPriceSymbol : "BNB",
      address: "",
      tokenDecimal: "18",
      // default balance
      rpcURL: rpcURLs[token['network']] ?? 'https://bsc-dataseed.binance.org',
    );
  }

  Future<List<Map<String, dynamic>>> fetchTrendingTokens() async {
    // 1️⃣ Fetch listings
    final listingsUrl =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=50';
    final listingsResp = await http.get(
      Uri.parse(listingsUrl),
      headers: {'X-CMC_PRO_API_KEY': apiKey},
    );

    if (listingsResp.statusCode != 200) {
      throw Exception('Failed to fetch trending tokens');
    }

    final listingsData = jsonDecode(listingsResp.body)['data'] as List;

    // Filter out SOL, TRX, LTC
    final filteredData = listingsData.where((token) {
      final symbol = token['symbol'] ?? '';
      return symbol != 'SOL' && symbol != 'TRX' && symbol != 'LTC';
    }).toList();

    // Sort by 24h % change
    filteredData.sort((a, b) {
      final changeA = a['quote']['USD']['percent_change_24h'] ?? 0.0;
      final changeB = b['quote']['USD']['percent_change_24h'] ?? 0.0;
      return changeB.compareTo(changeA);
    });

    final topTokens = filteredData.take(15).toList();

    // 2️⃣ Fetch token info (to get platform/contract address)
    final ids = topTokens.map((e) => e['id']).join(',');
    final infoUrl =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?id=$ids';
    final infoResp = await http.get(
      Uri.parse(infoUrl),
      headers: {'X-CMC_PRO_API_KEY': apiKey},
    );

    if (infoResp.statusCode != 200) {
      throw Exception('Failed to fetch token info');
    }

    final infoData = jsonDecode(infoResp.body)['data'] as Map<String, dynamic>;

    // Merge listings + info
    List<Map<String, dynamic>> tokens = [];
    for (var token in topTokens) {
      final info = infoData[token['id'].toString()];
      final platform = info['platform'];

      tokens.add({
        "id": token['id'],
        "name": token['name'],
        "symbol": token['symbol'],
        "price": token['quote']['USD']['price'],
        "volume_24h": token['quote']['USD']['volume_24h'],
        "percent_change_24h": token['quote']['USD']['percent_change_24h'],
        "network": platform?['name'] ?? "Native",
        "tokenAddress": platform?['token_address'] ?? "",
        "logo":
        "https://s2.coinmarketcap.com/static/img/coins/64x64/${token['id']}.png",
      });
    }

    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          "Trending Tokens",
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(

              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF27282B),
                  ),
                  child:  Padding(
                    padding: EdgeInsets.only(top: 6.0, bottom: 6, left: 12, right: 8),
                    child: Row(
                      children: [
                        AppText(
                          "24h",
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                // 🔹 Vertical Divider
                Container(
                  height: 28,
                  width: 1,
                  color: Colors.grey.withOpacity(0.4), // adjust opacity if needed
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF27282B),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 6, left: 12, right: 8),
                    child: Row(
                      children: [
                        AppText(
                          "All",
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFAF77F8),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFFAF77F8)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Color(0xFF27282B),)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 6, left: 12, right: 8),
                      child: Row(
                        children: [
                          Image.asset("assets/Images/bnb.png"),
                          AppText(
                            "BNB Smart Chain",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
SizedBox(height: 10,),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: trendingTokens,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No trending tokens found.'));
              }

              final tokens = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    final token = tokens[index];

                    return ListTile(
                      leading:
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(token['logo']),
                            child: AppText(
                              token['symbol'][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Image.asset("assets/Images/bnb.png")
                        ],
                      ),
              
                      title: AppText('${token['name']} ',
                          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                      subtitle: AppText(
                        '\$${_formatVolume(token['volume_24h'])}',
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText('\$${token['price'].toStringAsFixed(2)}',
                              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                          AppText(
                            '${token['percent_change_24h'].toStringAsFixed(2)}%',
                            color: token['percent_change_24h'] > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ],
                      ),
                      onTap: () async {
                        // Convert Map -> AssetModel
                        final asset = trendingToAssetModel(token);

                        // Navigate to TransactionAction with AssetModel
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionAction(
                              coinData: asset,
                              balance: "0.0",
                              userWallet: localStorageService.activeWalletData!,
                              usdPrice: 0.0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(2);
  }
}
