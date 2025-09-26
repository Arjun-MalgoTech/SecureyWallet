import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/ImportRecoveryPhrase_Screen/View/ImportRecoveryPhrase_View.dart';


class ConnectExistingWallet extends StatefulWidget {
  const ConnectExistingWallet({super.key});

  @override
  State<ConnectExistingWallet> createState() => _ConnectExistingWalletState();
}

class _ConnectExistingWalletState extends State<ConnectExistingWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          "Access Existing Wallet",
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).indicatorColor,
              ),
            )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RestoreWalletFromPhrase();
                }));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              tileColor: Theme.of(context).primaryColorLight,
              leading: CircleAvatar(
                backgroundColor: Color(0xFF3D353c),
                radius: 20,
                child: SvgPicture.asset(
                  "assets/Images/edit.svg",
                  color: Color(0xFFB982FF),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Secret phrase",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  AppText("Use a 12, 18 or 24-word seed phrase",
                      fontWeight: FontWeight.w300,
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.surfaceBright),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
