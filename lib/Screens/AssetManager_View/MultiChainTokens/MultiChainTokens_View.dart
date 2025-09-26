import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/AssetManager_View/AssetJsonScreen/AssetJsonScreen.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/Coin_List_Config.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';

class MultiChainTokens extends StatefulWidget {
  const MultiChainTokens({super.key});

  @override
  State<MultiChainTokens> createState() => _MultiChainTokensState();
}

class _MultiChainTokensState extends State<MultiChainTokens> {
  @override
  void initState() {
    super.initState();
    coinData.addAll(CoinListConfig.coinModelList);
    coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
    coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'BTC');
    coinData.removeWhere((coin) => coin.coinSymbol == 'tBTC');
    coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'XRP');
    coinData.removeWhere((coin) => coin.network == 'Testnet');

    // coinData.removeWhere((coin) => coin.coinSymbol == 'sepETH');
    // coinData.removeWhere((coin) => coin.coinSymbol == 'tBNB');
    // coinData.removeWhere((coin) => coin.coinSymbol == 'tTRX');
    // coinData.removeWhere((coin) => coin.coinSymbol == 'tCelo');
    //     &&
    // coin.coinSymbol?.toUpperCase() == 'BTC' &&
    // coin.coinSymbol?.toUpperCase() == 'XRP'
  }

  TextEditingController searchController = TextEditingController();
  void clearSearch() {
    searchController.clear();
    setState(() {
      coinData = CoinListConfig.coinModelList;
      coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
      coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'BTC');
      coinData.removeWhere((coin) => coin.coinSymbol == 'tBTC');
      coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'XRP');
      coinData.removeWhere((coin) => coin.network == 'Testnet');
    });
  }

  void _filterData(String query) {
    setState(() {
      coinData.clear();
      if (query.isEmpty) {
        coinData.addAll(CoinListConfig.coinModelList);
        coinData
            .removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
        coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'BTC');
        coinData.removeWhere((coin) => coin.coinSymbol == 'tBTC');
        coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'XRP');
        coinData.removeWhere((coin) => coin.network == 'Testnet');
      } else {
        coinData.addAll(CoinListConfig.coinModelList
            .where((element) =>
                element.coinSymbol!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                element.coinName!.toLowerCase().contains(query.toLowerCase()))
            .toList());
        coinData = coinData.toSet().toList();
        coinData
            .removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'NVXO');
        coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'BTC');
        coinData.removeWhere((coin) => coin.coinSymbol == 'tBTC');
        coinData.removeWhere((coin) => coin.coinSymbol?.toUpperCase() == 'XRP');
        coinData.removeWhere((coin) => coin.network == 'Testnet');
      }
    });
  }

  List<AssetModel> coinData = [];
  LocalStorageService localStorageService = LocalStorageService();
  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    return Scaffold(
        appBar: AppBar(
          title: AppText(
            'All Network',
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: Center(
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterData,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).bottomAppBarTheme.color ??
                              Color(0xFFD4D4D4),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.surfaceBright,
                        size: 16,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                clearSearch();
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ))
                          : SizedBox(),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor: Theme.of(context).bottomAppBarTheme.color ??
                          Color(0xFFD4D4D4),
                      filled: true,
                    ),
                    style: TextStyle(
                      decorationThickness: 0.0,
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: coinData.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isExisting = localStorageService.assetList.any(
                      (element) =>
                          element.coinName!.toLowerCase() ==
                          coinData[index].coinName.toString().toLowerCase());

                  int existingIndex = localStorageService.assetList.indexWhere(
                      (element) =>
                          element.coinName!.toLowerCase() ==
                          coinData[index].coinName.toString().toLowerCase());
                  return GestureDetector(
                    onTap: () {
                      String fileName = coinData[index].coinSymbol!;
                      print(fileName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AssetJson(jsonFileName: fileName),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF202832),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              coinData[index].imageUrl!,
                              errorBuilder: (_, obj, trc) {
                                return AppText(
                                  coinData[index]
                                      .coinSymbol
                                      .toString()
                                      .characters
                                      .first,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                );
                              },
                            ),
                          )),
                      title: Row(
                        children: [
                          AppText(
                            coinData[index].coinName!,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.surfaceBright,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF262737),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0, right: 4.0),
                                child: AppText(
                                  coinData[index].network!,
                                  fontSize: 10,
                                  overflow: TextOverflow
                                      .ellipsis, // Ensure truncation here too
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // subtitle: AppText(
                      //   coinData[index].coinName!,
                      //   fontSize: 13,
                      //   color: Theme.of(context).colorScheme.surfaceBright,
                      // ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}

String getJsonFileName(String symbol) {
  switch (symbol.toLowerCase()) {
    case "eth":
      return "eth";
    case "bnb":
      return "bnb";
    case "usdt":
      return "usdt";
    default:
      return "default"; // Fallback file
  }
}
