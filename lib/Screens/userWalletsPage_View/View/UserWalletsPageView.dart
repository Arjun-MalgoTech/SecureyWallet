import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Connect_Existing_Wallet/View/ConnectExistingWallet.dart';
import 'package:securywallet/Screens/Secure_Backup_Screen/View/Secure_Backup_View.dart';
import 'package:securywallet/Screens/app_bottom_nav/View/App_Bottom_nav_view.dart';
import 'package:securywallet/Screens/userWalletsPage_View/Backup_Vault_View/View/BackUpVaultView.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class UserWalletPage extends StatefulWidget {
  const UserWalletPage({
    super.key,
  });

  @override
  State<UserWalletPage> createState() => _UserWalletPageState();
}

class _UserWalletPageState extends State<UserWalletPage> {
  String privateKey = '';
  String dollar = '';

  VaultStorageService vaultStorageService = VaultStorageService();
  LocalStorageService localStorageService = LocalStorageService();
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocalStorageService>(context, listen: false).getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          "Wallets",
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFFB7B7B7),
              ),
            )),
        actions: [
          InkWell(
              onTap: () {
                showBottomSheet(context);
              },
              child: Container(
                color: Colors.transparent,
                child: Icon(
                  Icons.add,
                  color: Color(0xFFB7B7B7),
                ),
              )),
          SizedBox(
            width: SizeConfig.width(context, 5),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppText(
                "Multi-coin wallets",
                color: Color(0xFFB7B7B7),
              ),
            ),
            Expanded(
              child: localStorageService.walletListData.isEmpty
                  ? SizedBox()
                  : ListView.builder(
                      itemCount: localStorageService.walletListData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await vaultStorageService.selectedWallet(
                                  localStorageService.walletListData[index]
                                      .toJson());
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => AppBottomNav()),
                                    (route) => false);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).primaryColorLight,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.0,
                                            top: 16.0,
                                            bottom: 16.0,
                                            right: 16.0),
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 20,
                                              child: Icon(
                                                Icons.account_balance_wallet,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            localStorageService
                                                        .activeWalletData!
                                                        .walletAddress ==
                                                    localStorageService
                                                        .walletListData[index]
                                                        .walletAddress
                                                ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.green,
                                                            shape: BoxShape
                                                                .circle),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        child: AppText(
                                          localStorageService
                                                      .walletListData[index]
                                                      .walletName
                                                      .toString()
                                                      .length >
                                                  13
                                              ? '${localStorageService.walletListData[index].walletName.toString()}'
                                              : localStorageService
                                                  .walletListData[index]
                                                  .walletName
                                                  .toString(),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                          onPressed: () {
                                            print(
                                                'mnemonic::::${localStorageService.walletListData[index].mnemonic}');
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return WalletBackUp(
                                                  data: localStorageService
                                                      .walletListData[index]);
                                            })).then((result) {
                                              if (result != null) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  Provider.of<LocalStorageService>(
                                                          context,
                                                          listen: false)
                                                      .getData();
                                                });
                                                setState(() {
                                                  localStorageService
                                                          .walletListData[index]
                                                          .walletName =
                                                      result['savedText'];
                                                });
                                              }
                                            });
                                          },
                                          icon: Container(
                                              height: 40,
                                              color: Colors.transparent,
                                              child: Icon(Icons.more_vert)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      builder: (BuildContext context) {
        return Container(
          child: Center(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Center(
                      child: AppText(
                        "Connect wallet",
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                "assets/Images/coinwallet.png",
                height: SizeConfig.height(context, 24),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SecureBackup();
                    }));
                  },
                  tileColor: Color(0xFF242426),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF3D353C),
                    radius: 20,
                    child: Icon(
                      Icons.add,
                      color: Color(0xFFB982FF),
                    ),
                  ),
                  title: AppText(
                    "Set Up Your Wallet",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  subtitle: AppText(
                    "Secret Phrase",
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ConnectExistingWallet();
                    }));
                  },
                  tileColor: Color(0xFF242426),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF3D353c),
                    radius: 20,
                    child: Icon(
                      Icons.arrow_downward,
                      color: Color(0xFFB982FF),
                    ),
                  ),
                  title: AppText(
                    "Access Existing Wallet",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  subtitle: AppText(
                    "Recover, Import, or View-Only Access",
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          )),
        );
      },
    );
  }
}
