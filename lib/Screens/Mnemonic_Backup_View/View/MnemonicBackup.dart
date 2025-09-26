import 'package:flutter/material.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';

class MnemonicBackup extends StatefulWidget {
  final UserWalletDataModel userWallet;

  MnemonicBackup({super.key, required this.userWallet});

  @override
  State<MnemonicBackup> createState() => _MnemonicBackupState();
}

class _MnemonicBackupState extends State<MnemonicBackup> {
  @override
  void initState() {
    super.initState();
    _disableScreenshots();
  }

  @override
  void dispose() {
    _enableScreenshots();
    super.dispose();
  }

  Future<void> _disableScreenshots() async {
    await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE);
  }

  Future<void> _enableScreenshots() async {
    await FlutterWindowManagerPlus.clearFlags(
        FlutterWindowManagerPlus.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    final privateKey = widget.userWallet.privateKey;
    final mnemonicWords = widget.userWallet.mnemonic.split(' ');
    // print('mnemonicWords::::::$mnemonicWords');
    final int halfLength = (mnemonicWords.length / 2).ceil();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).indicatorColor,
          ),
        ),
        title: AppText(
          "Secret Phrase",
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(halfLength, (idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${idx + 1}.',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).primaryColorLight,
                            ),
                            child: FilterChip(
                              side: BorderSide(
                                color: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              label: Text(
                                '${mnemonicWords[idx]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                ),
                              ),
                              onSelected: (bool value) {},
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      List.generate(mnemonicWords.length - halfLength, (idx) {
                    final int secondColumnIndex = halfLength + idx;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${secondColumnIndex + 1}.',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).primaryColorLight,
                            ),
                            child: FilterChip(
                              side: BorderSide(
                                color: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              label: Text(
                                '${mnemonicWords[secondColumnIndex]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                ),
                              ),
                              onSelected: (bool value) {},
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF231D0B),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.info,
                        color: Color(0xFFFCB500),
                      ),
                      AppText(
                        "Never Share Your Secret Phrase With Anyone And\nStore It Securly",
                        color: Color(0xFFFCB500),
                        fontSize: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFFCB500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
