import 'package:flutter/material.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

class TrendingTokens extends StatefulWidget {
  const TrendingTokens({super.key});

  @override
  State<TrendingTokens> createState() => _TrendingTokensState();
}

class _TrendingTokensState extends State<TrendingTokens> {
  final List<Map<String, dynamic>> tokens = [
    {
      "name": "GMX Dynamics",
      "symbol": "\$45.12M",
      "image": "assets/Images/Frame 254.png",
      "balance": "\$45,230.75",
      "per": "+3.44%",
    },
    {
      "name": "FRGX",
      "symbol": "\$63.78M",
      "image": "assets/Images/Frame 255.png",
      "balance": "\$3,540.20",
      "per": "+6.44%",
    },
    {
      "name": "PLXY",
      "symbol": "\$24.55M",
      "image": "assets/Images/Frame 256.png",
      "balance": "\$610.12",
      "per": "+8.47%",
    },
    {
      "name": "APEX",
      "symbol": "\$12.87M",
      "image": "assets/Images/Frame 257.png",
      "balance": "\$145.34",
      "per": "+3.44%",
    },
    {
      "name": "NANOS",
      "symbol": "\$36.22M",
      "image": "assets/Images/Frame 258.png",
      "balance": "\$0.52",
      "per": "+9.44%",
    },
    {
      "name": "XRP",
      "symbol": "XRP",
      "image": "assets/Images/Frame 259.png",
      "balance": "\$0.52",
      "per": "+1.44%",
    },
    {
      "name": "XRP",
      "symbol": "XRP",
      "image": "assets/Images/Frame 260.png",
      "balance": "\$0.52",
      "per": "+9.44%",
    },
    {
      "name": "XRP",
      "symbol": "XRP",
      "image": "assets/Images/Frame 261.png",
      "balance": "\$0.52",
      "per": "+10.44%",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF0a0d11),
      appBar: AppBar(
        backgroundColor: const Color(0XFF0a0d11),
        title: AppText("Trending Tokens"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Image.asset("assets/Images/dummy.png"),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: tokens.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final token = tokens[index];
                return Card(
                  color: const Color(0xFF14181E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(token["image"]),
                      radius: 24,
                    ),
                    title: Text(
                      token["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      token["symbol"],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          token["balance"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          token["per"],
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
