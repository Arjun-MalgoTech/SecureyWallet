import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/PasscodeScreen/View/PasscodeEntryView.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/View/Previous_Home_Screen_View.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletBackUp extends StatefulWidget {
  final UserWalletDataModel data;
  const WalletBackUp({super.key, required this.data});

  @override
  State<WalletBackUp> createState() => _WalletBackUpState();
}

class _WalletBackUpState extends State<WalletBackUp> {
  TextEditingController _controller = TextEditingController();
  String savedText = '';
  VaultStorageService vaultStorageService = VaultStorageService();
  LocalStorageService localStorageService = LocalStorageService();
  @override
  void initState() {
    super.initState();
    // Initialize the text field with some initial text if needed
    _controller.text = widget.data.walletName;
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // title: AppText(
        //   savedText,
        //   color: Theme.of(context).colorScheme.surfaceBright,
        // ),
        // centerTitle: true,
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final savedPasscode = prefs.getString('passcode');
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasscodeEntryView(
                            savedPasscode: savedPasscode!,
                            click: '123',
                            data: widget.data),
                      ),
                    );

                    if (result != true) {
                      // Remove data if passcode is correct

                      UserWalletDataModel? selected =
                          vaultStorageService.fetchSelectedList();
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<LocalStorageService>(context,
                                  listen: false)
                              .getData();
                          Provider.of<AssetTransactionAPI>(context,
                                  listen: false)
                              .getBalance(
                            localStorageService.assetList,
                            localStorageService.activeWalletData!.privateKey,
                          );
                        });
                        if (selected != null) {
                          // Navigator.pop(context);
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (builder) => PreHome()),
                            (route) => false,
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Color(0xFFB7B7B7),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        Map data = widget.data.toJson();

                        setState(() {
                          data["walletName"] = _controller.text;
                        });
                        await vaultStorageService.updateWalletToList(data);

                        if (mounted) {
                          Navigator.pop(context, {
                            'savedText': savedText,
                          });
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Color(0xFFB7B7B8),
                    )),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AppText(
                  "Name",
                  color: Color(0xFFB7B7B7),
                  fontSize: 13,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  decorationThickness: 0.0),
              controller: _controller,
              onChanged: (e) {
                widget.data.walletName = e;
                savedText = _controller.text;
                print("savedText :::: ${savedText}");
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.white30, // Focus color
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.white30, // Focus color
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.white30, // Focus color
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.clear();
                  },
                  icon: Icon(
                    Icons.close_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppText(
                  'Secret phrase backup',
                  color: Color(0xFFB7B7B7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final savedPasscode = prefs.getString('passcode');
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PasscodeEntryView(
                    savedPasscode: savedPasscode!,
                    click: 'wallet_backup',
                    data: widget.data);
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                      AppText(
                        'Manual',
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppText(
                        'Active',
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFB7B7B7),
                        size: 15,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
