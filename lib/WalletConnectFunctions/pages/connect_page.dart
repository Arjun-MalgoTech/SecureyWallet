import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/QRView/QRView_Android.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';

class ConnectPage extends StatefulWidget {
  final SignClient signClient;
  final UserWalletDataModel selectedWalletData;
  final bool enableScanView;
  String? wcURL;
  ConnectPage(
      {super.key,
      required this.signClient,
      required this.selectedWalletData,
      this.enableScanView = false,
      this.wcURL});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final TextEditingController _uriController = TextEditingController();

  late bool _scanView;

  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  void initState() {
    _scanView = widget.enableScanView;
    wcURLUpdate();
    super.initState();
  }

  wcURLUpdate() {
    walletConnectionRequest.wcURL = "AAA";
    if (widget.wcURL != null) {
      Future.delayed(Duration(), () async {
        if (mounted) {
          await _qrScanHandler(widget.wcURL!, context);
        }
      });
    } else {}
  }

  @override
  void didUpdateWidget(covariant ConnectPage oldWidget) {
    _scanView = widget.enableScanView;
    super.didUpdateWidget(oldWidget);
  }

  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context,
        autoWC: widget.wcURL != null ? true : false);
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset(-20, -150)),
      width: SizeConfig.height(context, 25),
      height: SizeConfig.height(context, 25),
    );
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: _scanView
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        children: [
                          ///android scanner
                          MobileScanner(
                            controller: controller,
                            fit: BoxFit.contain,
                            scanWindow: scanWindow,
                            overlayBuilder: (context, constraints) {
                              return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SizedBox());
                            },
                            // allowDuplicates: false,
                            onDetect: (barcode) {
                              Future.delayed(Duration(), () async {
                                if (context.mounted) {
                                  await _qrScanHandler(
                                      barcode.barcodes[0].rawValue.toString(),
                                      context);
                                }
                              });
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (context, value, child) {
                              if (!value.isInitialized ||
                                  !value.isRunning ||
                                  value.error != null) {
                                return const SizedBox();
                              }

                              return CustomPaint(
                                painter: ScannerOverlay(scanWindow: scanWindow),
                              );
                            },
                          ),

                          ///-----ios scanner

                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _scanView = false;
                                });
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 100.0,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          height: 42.0,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 0.2174, 0.5403, 0.8528],
                              colors: [
                                Color(0xFF912ECA),
                                Color(0xFF912ECA),
                                Color(0xFF793CDE),
                                Color(0xFF793CDE),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _scanView = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Scan QR code'),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const Text(
          'or connect with Wallet Connect uri',
          style: TextStyle(color: Colors.white70),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: _uriController,
            style: TextStyle(
              decorationThickness: 0.0,
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.surfaceBright,
              fontSize: 12,
            ),
            onTap: () {
              Clipboard.getData('text/plain').then((value) {
                if (_uriController.text.isEmpty &&
                    value?.text != null &&
                    Uri.tryParse(value!.text!) != null) {
                  _uriController.text = value.text!;
                }
              });
            },
            decoration: InputDecoration(
              focusColor: Color(0xFFB982FF),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFB982FF), width: 2.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Enter uri',
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 5.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.2174, 0.5403, 0.8528],
                    colors: [
                      Color(0xFF912ECA),
                      Color(0xFF912ECA),
                      Color(0xFF793CDE),
                      Color(0xFF793CDE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: TextButton(
                  onPressed: () async {
                    await _qrScanHandler(_uriController.text, context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Connect'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  _qrScanHandler(String value, context) async {
    if (Uri.tryParse(value) != null) {
      await widget.signClient.pair(value).catchError((e) {
        if (context.mounted) {
          Utils.snackBarErrorMessage(
              "Please check your network and try again.");
        }

        throw e;
      });
    }
  }

  bool validateWC(String text) {
    return text.contains("wc:");
  }
}
