import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/smart_web_screen/smart_web_screen.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class SmartWebView extends StatefulWidget {
  const SmartWebView({Key? key}) : super(key: key);

  @override
  State<SmartWebView> createState() => _SmartWebViewState();
}

class _SmartWebViewState extends State<SmartWebView> {
  final List<Map<String, String>> items = [
    {
      "title": "PancakeSwap",
      "image": "https://pancakeswap.finance/logo.png",
      "subtitle":
          "The flippening is coming. Stack \$Cake on Binance\nSmart Chain",
      "description": "Description 2",
      "link": "https://pancakeswap.finance/swap"
    },
    {
      "title": "Venus",
      "image": "https://venus.io/120x120.png",
      "subtitle":
          "A Decentralized Marketplace for Lenders and Borrowers\nwith Bordeerless Stablecoins. ",
      "description": "Description 1",
      "link": "https://app.venus.io/"
    },
    {
      "title": "Sushi Swap",
      "image": "https://www.sushi.com/favicon-32x32.png?v=1",
      "subtitle": "Swap your coins",
      "link": "https://www.sushi.com/swap",
    },
    {
      "title": "Beefy",
      "image": "https://avatars.githubusercontent.com/u/71276150?s=200&v=4",
      "subtitle": "The Multichain Yeild Optimizer",
      "description": "Description 2",
      "link": "https://app.beefy.finance/"
    },
    {
      "title": "Chainflip",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/icrypt-8cc00.appspot.com/o/chainflip.png?alt=media&token=54a83acb-e325-4a11-af5c-b4b015f623d6",
      "subtitle":
          "An efficient cross-chain AMM enabling native asset swaps without wrapped tokens or specialized wallets.",
      "link": "https://swap.perseverance.chainflip.io/",
    },

    // Add more items as needed
  ];
  void num() {
    List<int> numbers = [1, 2, 3, 4, 5];
    List<int> evennum = numbers.where((n) => n.isEven).toList();
    print(" evennum : $evennum");
    List<int> squares = numbers.map((n) => n * n).toList();
    print(" squares : $squares");
    int sum = numbers.fold(0, (a, b) => a + b);
    print(" sum : $sum");
    Map<String, int> scores = {"Math": 80, "Science": 90, "English": 70};
    scores.updateAll((key, value) => value + 5);
    print("scores : $scores");
    scores['History'] = 85;
    print("scores11 : $scores");
    scores.remove("English");
    print("remove : ${scores.values.toList()}");
    String number = '123';
    String price = '19.99';
    int numint = int.parse(number);
    double doubleprice = double.parse(price);
    print("numint : $numint");
    print("doubleprice : $doubleprice");
    int updateInt = numint + 100;
    print("updateInt : $updateInt");
    double updateDouble = doubleprice * 2;
    print("updateDouble : $updateDouble");
    List<Map<String, dynamic>> users = [
      {"name": "Alice", "age": 25},
      {"name": "Bob", "age": 30},
      {"name": "Carol", "ag": 22}
    ];
    // dynamic averageAge =
    //     users.map((user) => user["age"] as int).reduce((a, b) => a + b) /
    //         users.length;
    // print("averageAge :$averageAge");
  }

  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    // num();
    filteredItems = items; // Initialize filtered list with original items
  }

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AppText(
          "Browser",

          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: SizeConfig.height(context, 7),
              child: TextField(
                controller: searchController,
                onSubmitted: (v) {
                  if (v.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => SmartWebScreen(
                              url: v,
                            )));
                  }
                },
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // No border
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).bottomAppBarTheme.color ??
                          Color(0xFFD4D4D4), // Focus color
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    size: 16,
                  ),
                  hintText: 'Search DApps...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // No border
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (searchController.text.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => SmartWebScreen(
                                  url: searchController.text,
                                )));
                      }
                    },
                    icon: Icon(Icons.forward),
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  fillColor: Theme.of(context).bottomAppBarTheme.color ??
                      Color(0xFFD4D4D4), // Color without border
                  filled:
                      true, // Required to fill the TextField background with color
                ),
                style: TextStyle(
                  fontFamily: 'LexendDeca',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surfaceBright,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New DApps",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchController.text.isEmpty
                  ? items.length
                  : filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: AppText(
                    items[index]['title']!,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  subtitle: AppText(
                    items[index]['subtitle']!,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  leading: CircleAvatar(
                      backgroundColor: const Color(0xFF202832),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          items[index]['image']!,
                          errorBuilder: (_, obj, trc) {
                            return AppText(
                              items[index]['title'].toString().characters.first,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            );
                          },
                        ),
                      )),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => SmartWebScreen(
                              url: items[index]['link']!,
                            )));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
