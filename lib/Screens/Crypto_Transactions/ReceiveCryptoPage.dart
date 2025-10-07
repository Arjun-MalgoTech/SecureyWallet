import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/ColorHandlers/AppColors.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveCrypto extends StatefulWidget {
  final AssetModel coinData;

  const ReceiveCrypto({
    Key? key,
    required this.coinData,
  }) : super(key: key);

  @override
  State<ReceiveCrypto> createState() => _ReceiveCryptoState();
}

class _ReceiveCryptoState extends State<ReceiveCrypto> {
  LocalStorageService localStorageService = LocalStorageService();
  String? Address;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocalStorageService>(context, listen: false).getData();
    });
print("////${widget.coinData.address!}");
    super.initState();
  }

  static GlobalKey previewContainer = GlobalKey();
  takeScreenShot() async {
    RenderRepaintBoundary? boundary = previewContainer.currentContext!
        .findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    share(pngBytes, _qrText);
  }

  Future<void> share(Uint8List bytes, String address) async {
    final directory = await getTemporaryDirectory();
    final image = File('${directory.path}/screenshot.png');
    XFile xFile = XFile(image.path);
    image.writeAsBytesSync(bytes);
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      'Address: ${widget.coinData.rpcURL != "" ? localStorageService.activeWalletData!.walletAddress : widget.coinData.address!}',
    );

    await Share.shareXFiles([xFile], text: buffer.toString());
  }

  TextEditingController qrcontroller = TextEditingController();
  String _qrText = '';

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);

    return localStorageService.isLoading
        ? const CircularProgressIndicator(
            color: Color(0xFF30DCF9),
          )
        : RepaintBoundary(
            key: previewContainer,
            child: Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(Icons.arrow_back,
                          color: Theme.of(context).indicatorColor),
                    ),
                  ),
                  title: AppText(
                    "Receive",
                    fontFamily: 'LexendDeca',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  actions: [
                    CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF202832),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            widget.coinData.imageUrl!,
                            errorBuilder: (_, obj, trc) {
                              return AppText(
                                widget.coinData.coinSymbol
                                    .toString()
                                    .characters
                                    .first,
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              );
                            },
                          ),
                        )),
                    SizedBox(
                      width: SizeConfig.width(context, 2),
                    ),
                    AppText(
                      "${widget.coinData.coinSymbol}",
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontSize: 14,
                    ),
                    SizedBox(
                      width: SizeConfig.width(context, 4),
                    ),
                  ]),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 70,
                        width: SizeConfig.width(context, 105),
                        decoration: BoxDecoration(
                          color: Theme.of(context).bottomAppBarTheme.color ??
                              const Color(0xFFD4D4D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFCB500),
                              ),
                              SizedBox(
                                width: SizeConfig.width(context, 4),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppText(
                                  "Only Send On ${widget.coinData.coinSymbol} Network Assets "
                                  "to this \naddress. Other assets will be lost forever",
                                  fontFamily: 'LexendDeca',
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFCB500),
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 4),
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 3),
                      ),
                      Center(
                        child: Container(
                          color: Colors.white,
                          child: QrImageView(
                            foregroundColor: Colors.black,
                            dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: Colors.black),
                            data: _qrText.isNotEmpty
                                ? "${widget.coinData.coinName!.toLowerCase()}:${widget.coinData.rpcURL != "" ? localStorageService.activeWalletData!.walletAddress : widget.coinData.address!}?amount=$_qrText"
                                : widget.coinData.rpcURL != ""
                                    ? localStorageService
                                        .activeWalletData!.walletAddress
                                    : widget.coinData.address!,
                            // embeddedImage: AssetImage('assets/Images/bitcoin.png',),
                            version: QrVersions.auto,
                            // backgroundColor: Theme.of(context).errorColor,
                            size: SizeConfig.height(context, 30),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 3),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              AppText(
                                "Address",
                                fontWeight: FontWeight.bold,
                              )
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.height(context, 1),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white24.withOpacity(0.5),
                                  width: 0.5),
                              color: Colors.white24.withOpacity(0.1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: AppText(
                                  widget.coinData.coinSymbol == "DOGE" ||
                                          widget.coinData.coinSymbol == "tDOGE"
                                      ? widget.coinData.address!
                                      : widget.coinData.coinSymbol == "tVET" ||
                                              widget.coinData.coinSymbol ==
                                                  "VET"
                                          ? widget.coinData.address!
                                          : widget.coinData.rpcURL != ""
                                              ? localStorageService
                                                  .activeWalletData!
                                                  .walletAddress
                                              : widget.coinData.address!,
                                  fontFamily: 'LexendDeca',
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: _qrText.isNotEmpty,
                        child: Column(
                          children: [
                            SizedBox(
                              height: SizeConfig.height(context, 2),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    "Set Amount is $_qrText ${widget.coinData.coinSymbol}",
                                    fontFamily: 'LexendDeca',
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                    fontSize: 12,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _qrText = "";
                                      });
                                    },
                                    icon: Icon(
                                      Icons.highlight_remove_outlined,
                                      color: appColors.red,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.height(context, 4),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print(
                                      '${widget.coinData.rpcURL != "" ? localStorageService.activeWalletData!.walletAddress.length : widget.coinData.address!.length}');
                                  Clipboard.setData(ClipboardData(
                                      text: widget.coinData.rpcURL != ""
                                          ? localStorageService
                                              .activeWalletData!.walletAddress
                                          : widget.coinData.address!));
                                  Utils.snackBar("Copied to Clipboard");
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Theme.of(context)
                                          .bottomAppBarTheme
                                          .color ??
                                      const Color(0xFFD4D4D4),
                                  child: Icon(
                                    Icons.copy,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.height(context, 2),
                              ),
                              AppText(
                                "Copy",
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                fontSize: 12,
                              )
                            ],
                          ),
                          SizedBox(
                            width: SizeConfig.width(context, 6),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Theme.of(context)
                                              .bottomAppBarTheme
                                              .color,
                                          title: AppText(
                                            'Enter Amount',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceBright,
                                            fontSize: 15,
                                          ),
                                          content: TextField(
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceBright,
                                                decorationThickness: 0.0,
                                                fontSize: 15),
                                            controller: qrcontroller,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .grey, // Change this to your desired color
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                    8.0), // Optional: Customize the border radius
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .grey, // Change this to your desired color
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                    8.0), // Optional: Customize the border radius
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                qrcontroller.clear();
                                                Navigator.of(context).pop();
                                              },
                                              child: AppText(
                                                'Cancel',
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _qrText = qrcontroller.text;
                                                });
                                                qrcontroller.clear();
                                                Navigator.of(context).pop();
                                              },
                                              child: AppText(
                                                'OK',
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Theme.of(context)
                                          .bottomAppBarTheme
                                          .color ??
                                      const Color(0xFFD4D4D4),
                                  child: Icon(
                                    Icons.front_hand_sharp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.height(context, 2),
                              ),
                              AppText(
                                "Set Amount",
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                fontSize: 12,
                              )
                            ],
                          ),
                          SizedBox(
                            width: SizeConfig.width(context, 6),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  takeScreenShot();
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Theme.of(context)
                                          .bottomAppBarTheme
                                          .color ??
                                      const Color(0xFFD4D4D4),
                                  child: Icon(
                                    Icons.share,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.height(context, 2),
                              ),
                              AppText(
                                "Share",
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                fontSize: 12,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
