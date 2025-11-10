import 'package:flutter/material.dart';

///MediaQuery.sizeOf(context).width,
///MediaQuery.of(context).size.width,

class SizeConfig {
  static double height(BuildContext context, double value) {
    double height = MediaQuery.of(context).size.height / 100;
    return height * value;
  }

  static double width(BuildContext context, double value) {
    double width = MediaQuery.of(context).size.width / 100;
    return width * value;
  }
}


//import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:securywallet/Api_Service/Apikey_Service.dart';
// import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
// import 'package:securywallet/Asset_Functions/Address_Generation/coin_address_generate.dart';
// import 'package:securywallet/Asset_Functions/Asset_Balance/AssetBalanceFunction.dart';
// import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
// import 'package:securywallet/Screens/Transaction_Action_Screen/View/Transaction_Action_view.dart';
// import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
// import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
// import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
// import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
//
// class TrendingTokens extends StatefulWidget {
//   @override
//   _TrendingTokensState createState() => _TrendingTokensState();
// }
//
// class _TrendingTokensState extends State<TrendingTokens> {
//   late Future<List<Map<String, dynamic>>> trendingTokens;
//   final String apiKey = '9b4cc00e-85f2-412f-8669-5b6b4ef12f0e';
//
//   String selectedNetwork = "BNB";
//   LocalStorageService localStorageService = LocalStorageService();
//
//   final networkOptions = [
//     {
//       "name": "BNB",
//       "icon":
//       "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970"
//     },
//     {
//       "name": "ETH",
//       "icon":
//       "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1696501628"
//     },
//     {
//       "name": "TRX",
//       "icon":
//       "https://s2.coinmarketcap.com/static/img/coins/128x128/1958.png"
//     },
//     {
//       "name": "SOL",
//       "icon":
//       "https://assets.coingecko.com/coins/images/4128/large/solana.png?1696504756"
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     trendingTokens = fetchTrendingTokens(selectedNetwork);
//   }
//
//   AssetModel trendingToAssetModel(Map<String, dynamic> token) {
//     final rpcURLs = {
//       "Ethereum": "https://mainnet.infura.io/v3/${apiKeyService.infuraKey}",
//       "BNB Smart Chain": "https://bsc-dataseed.binance.org",
//       "Polygon": "https://polygon-rpc.com",
//       "Avalanche": "https://api.avax.network/ext/bc/C/rpc",
//       "Tron": "",
//       "Solana": "",
//       "Terra Classic": "https://terra-classic-lcd.publicnode.com",
//     };
//
//     return AssetModel(
//       coinName: token['name'] ?? '',
//       coinSymbol: token['symbol'] ?? '',
//       imageUrl: token['logo'] ?? '',
//       tokenAddress: token['tokenAddress'] ?? '',
//       network: token['network'] ?? selectedNetwork,
//       coinType: "2",
//       gasPriceSymbol: selectedNetwork,
//       address:  selectedNetwork == "ETH"||selectedNetwork == "BNB"?"": assetAddressGenerate
//           .generateAddress(
//           selectedNetwork,
//           localStorageService
//               .activeWalletData!
//               .mnemonic),
//       tokenDecimal: "18",
//       rpcURL: rpcURLs[token['network']] ??
//           '',
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> fetchTrendingTokens(
//       String selectedNetwork) async
//   {
//     final listingsUrl =
//         'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=50';
//     final listingsResp = await http.get(
//       Uri.parse(listingsUrl),
//       headers: {'X-CMC_PRO_API_KEY': apiKey},
//     );
//
//     if (listingsResp.statusCode != 200) {
//       throw Exception('Failed to fetch trending tokens');
//     }
//
//     final listingsData = jsonDecode(listingsResp.body)['data'] as List;
//
//     // Filter + sort
//     final filteredData = listingsData.where((token) {
//       final symbol = token['symbol'] ?? '';
//       return symbol != 'SOL' && symbol != 'TRX' && symbol != 'LTC';
//     }).toList();
//
//     filteredData.sort((a, b) {
//       final changeA = a['quote']['USD']['percent_change_24h'] ?? 0.0;
//       final changeB = b['quote']['USD']['percent_change_24h'] ?? 0.0;
//       return changeB.compareTo(changeA);
//     });
//
//     final topTokens = filteredData.take(15).toList();
//
//     final ids = topTokens.map((e) => e['id']).join(',');
//     final infoUrl =
//         'https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?id=$ids';
//     final infoResp = await http.get(
//       Uri.parse(infoUrl),
//       headers: {'X-CMC_PRO_API_KEY': apiKey},
//     );
//
//     if (infoResp.statusCode != 200) {
//       throw Exception('Failed to fetch token info');
//     }
//
//     final infoData = jsonDecode(infoResp.body)['data'] as Map<String, dynamic>;
//
//     List<Map<String, dynamic>> tokens = [];
//     for (var token in topTokens) {
//       final info = infoData[token['id'].toString()];
//       final platform = info['platform'];
//
//       // Optional: simulate filtering tokens by network (for UI demo)
//       final networkName = selectedNetwork == "BNB"
//           ? "BNB Smart Chain"
//           : selectedNetwork == "ETH"
//           ? "Ethereum"
//           : selectedNetwork == "TRX"
//           ? "Tron"
//           : "Solana";
//
//       tokens.add({
//         "id": token['id'],
//         "name": token['name'],
//         "symbol": token['symbol'],
//         "price": token['quote']['USD']['price'],
//         "volume_24h": token['quote']['USD']['volume_24h'],
//         "percent_change_24h": token['quote']['USD']['percent_change_24h'],
//         "network": networkName,
//         "tokenAddress": platform?['token_address'] ?? "",
//         "logo":
//         "https://s2.coinmarketcap.com/static/img/coins/64x64/${token['id']}.png",
//       });
//     }
//
//     return tokens;
//   }
//
//   String getNetworkIcon(String networkName) {
//     switch (networkName) {
//       case "BNB":
//         return networkOptions[0]["icon"]!;
//       case "ETH":
//         return networkOptions[1]["icon"]!;
//       case "TRX":
//         return networkOptions[2]["icon"]!;
//       case "SOL":
//         return networkOptions[3]["icon"]!;
//       default:
//         return networkOptions[0]["icon"]!;
//     }
//   }
//
//   String _formatVolume(double volume) {
//     if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
//     if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
//     if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
//     return volume.toStringAsFixed(2);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     localStorageService = context.watch<LocalStorageService>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: AppText(
//           "Trending Tokens",
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Row(
//               children: [
//                 // 24h filter (static)
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color: const Color(0xFF27282B),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 6.0, horizontal: 12),
//                     child: Row(
//                       children: [
//                         AppText("24h",
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white),
//                         const Icon(Icons.keyboard_arrow_down,
//                             color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Divider
//                 Container(
//                   height: 28,
//                   width: 1,
//                   color: Colors.grey.withOpacity(0.4),
//                   margin: const EdgeInsets.symmetric(horizontal: 10),
//                 ),
//
//                 // Network dropdown
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color: const Color(0xFF27282B),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 6.0, horizontal: 12),
//                     child: PopupMenuButton<String>(
//                       color: const Color(0xFF27282B),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       onSelected: (value) {
//
//
//                         setState(() {
//                           selectedNetwork = value;
//                           trendingTokens = fetchTrendingTokens(value);
//                         });
//                       },
//                       itemBuilder: (context) {
//                         return networkOptions.map((network) {
//                           return PopupMenuItem<String>(
//                             value: network["name"]!,
//                             child: Row(
//                               children: [
//                                 Image.network(network["icon"]!,
//                                     width: 20, height: 20),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   network["name"]!,
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 if (selectedNetwork == network["name"]) ...[
//                                   const Spacer(),
//                                   const Icon(Icons.check,
//                                       color: Colors.green, size: 18),
//                                 ],
//                               ],
//                             ),
//                           );
//                         }).toList();
//                       },
//                       child: Row(
//                         children: [
//                           Image.network(
//                             getNetworkIcon(selectedNetwork),
//                             width: 20,
//                             height: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             selectedNetwork,
//                             style: const TextStyle(
//                               color: Color(0xFFAF77F8),
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           const Icon(Icons.keyboard_arrow_down,
//                               color: Color(0xFFAF77F8)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 10),
//
//           // Token list
//           FutureBuilder<List<Map<String, dynamic>>>(
//             future: trendingTokens,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Expanded(
//                     child: Center(child: CircularProgressIndicator()));
//               } else if (snapshot.hasError) {
//                 return Expanded(
//                     child: Center(child: Text('Error: ${snapshot.error}')));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Expanded(
//                     child: Center(child: Text('No trending tokens found.')));
//               }
//
//               final tokens = snapshot.data!;
//
//               return Expanded(
//                 child: ListView.builder(
//                   itemCount: tokens.length,
//                   itemBuilder: (context, index) {
//                     final token = tokens[index];
//                     return ListTile(
//                       leading: Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.transparent,
//                             backgroundImage: NetworkImage(token['logo']),
//                             child: AppText(token['symbol'][0],
//                                 style: const TextStyle(color: Colors.white)),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Image.network(
//                               getNetworkIcon(selectedNetwork),
//                               width: 18,
//                               height: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                       title: AppText(
//                         '${token['name']}',
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       subtitle: AppText(
//                         '\$${_formatVolume(token['volume_24h'])}',
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                       trailing: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           AppText('\$${token['price'].toStringAsFixed(2)}',
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600),
//                           AppText(
//                             '${token['percent_change_24h'].toStringAsFixed(2)}%',
//                             color: token['percent_change_24h'] > 0
//                                 ? Colors.green
//                                 : Colors.red,
//                             fontSize: 14,
//                           ),
//                         ],
//                       ),
//                       onTap: () async {
//                         final asset = trendingToAssetModel(token);
//                         String liveBalance = "0.0";
//                         print("Asset details: ${asset.toJson()}");
// // Only fetch balance for EVM tokens
//                         if (asset.rpcURL != null &&
//                             asset.rpcURL!.isNotEmpty &&
//                             asset.tokenAddress != null &&
//                             asset.tokenAddress!.isNotEmpty) {
//                           liveBalance = await assetBalanceFunction.evmTokenBalance(
//                             asset,
//                             localStorageService.activeWalletData!.privateKey,
//                           );
//                         }
//
// // Navigate with the live balance
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => TransactionAction(
//                               coinData: asset,
//                               balance: liveBalance,
//                               userWallet: localStorageService.activeWalletData!,
//                               usdPrice: 0.0,
//                             ),
//                           ),
//                         );
//
//                       },
//
//
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }