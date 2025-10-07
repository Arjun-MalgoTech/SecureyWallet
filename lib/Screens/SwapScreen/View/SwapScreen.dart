import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

class SwapScreen extends StatelessWidget {
  const SwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          'Swap',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: const Color(0XFF27282B),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.history, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0XFF131720),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SvgPicture.asset("assets/Images/custom.svg", height: 14),
                const SizedBox(width: 4),
                AppText('2%', color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Stack for cards + centered swap button ---
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: const [
                    FromSwapCard(),
                    SizedBox(height: 20), // spacing for the circle overlap
                    ToSwapCard(),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF31323b),
                    child: const Icon(Icons.swap_vert, color: Colors.white),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: AppText(
                  'Continue',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FROM SWAP CARD ----------------
class FromSwapCard extends StatelessWidget {
  const FromSwapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0XFF131720),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText('From',
                  color: Color(0XFF858585), fontSize: 14),
              const Spacer(),
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: Color(0xFFB4B1B2)),
              const SizedBox(width: 4),
              AppText('0.005742',
               color: Color(0xFFB4B1B2), fontSize: 13),
              const SizedBox(width: 6),
              _percentButton('25%'),
              const SizedBox(width: 6),
              _percentButton('50%'),
              const SizedBox(width: 6),
              _percentButton('Max'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset("assets/Images/eth1.png", height: 30),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText('Ethereum',
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                  AppText("ETH",
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText('0',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  AppText('\$0',
                      style: const TextStyle(
                          color: Color(0xFFB4B1B2), fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _percentButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131720),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0XFFAF77F8).withOpacity(0.3)),
      ),
      child: AppText(
        text,
        style: const TextStyle(color: Color(0XFFAF77F8), fontSize: 12),
      ),
    );
  }
}

// ---------------- TO SWAP CARD ----------------
class ToSwapCard extends StatelessWidget {
  const ToSwapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0XFF131720),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText('To',
                 color: Color(0XFF858585), fontSize: 14),
              const Spacer(),
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: Color(0xFFB4B1B2)),
              const SizedBox(width: 4),
              AppText('0',
                 color: Color(0xFFB4B1B2), fontSize: 13),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset("assets/Images/arb.png", height: 30),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText('Arbitrum',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                  AppText('ARB',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText('0',

                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                  AppText('\$0',

                          color: Color(0xFFB4B1B2), fontSize: 13),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
