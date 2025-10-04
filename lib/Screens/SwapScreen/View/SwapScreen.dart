import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/WalletConnectFunctions/WalletConnectPage.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SwapScreen extends StatefulWidget {
  SwapScreen({Key? key}) : super(key: key);

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  late final WebViewController _controller;

  bool _isValidUrl(String url) {
    // Regular expression to check URL format
    RegExp urlRegExp = RegExp(
      r"^(?:http|https):\/\/[^\s\.]+\.[^\s]{2,}$",
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegExp.hasMatch(url);
  }

  String urlListener = "";
  LocalStorageService localStorageService = LocalStorageService();
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  double _progress = 0;

  Timer? timer;

  void startQrCheckTimer() {
    String js = '''
   (function() {
      // Get the first shadow root
      var shadowRoot1 = document.querySelector("body > wcm-modal");
      if (!shadowRoot1) {
        return 'shadowRoot1 is null';
      }
      shadowRoot1 = shadowRoot1.shadowRoot;
      
      // Get the second shadow root
      var shadowRoot2 = shadowRoot1.querySelector("#wcm-modal > div > div > wcm-modal-router");
      if (!shadowRoot2) {
        return 'shadowRoot2 is null';
      }
      shadowRoot2 = shadowRoot2.shadowRoot;
      
      // Get the third shadow root
      var shadowRoot3 = shadowRoot2.querySelector("div > div > wcm-qrcode-view");
      if (!shadowRoot3) {
        return 'shadowRoot3 is null';
      }
      shadowRoot3 = shadowRoot3.shadowRoot;
      
      // Get the fourth shadow root
      var shadowRoot4 = shadowRoot3.querySelector("wcm-modal-content > wcm-walletconnect-qr");
      if (!shadowRoot4) {
        return 'shadowRoot4 is null';
      }
      shadowRoot4 = shadowRoot4.shadowRoot;
      
      // Get the QR code element
      var qrElement = shadowRoot4.querySelector("div > wcm-qrcode");
      if (!qrElement) {
        return 'qrElement is null';
      }
      
      // Return the URI attribute
      if (qrElement.getAttribute('uri')) {
        return qrElement.getAttribute('uri');
      } else {
        return 'URI attribute is missing';
      }
    })();
  ''';
    timer = Timer.periodic(Duration(seconds: 1), (t) async {
      if (!mounted) {
        timer!.cancel();
        return;
      }

      Object? uri = await _controller.runJavaScriptReturningResult(js);

      // print("qrContainerHtml$uri");

      if (uri.toString().contains("wc") && mounted) {
        timer!.cancel(); // Stop the timer once the desired condition is met
        if (!(timer!.isActive)) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (builder) => WalletConnectPage(
                    selectedWalletData: localStorageService.activeWalletData!,
                    wcURL: uri.toString(),
                  ),
                ),
              )
              .then((v) {
                if (mounted) {
                  walletConnectionRequest.initializeContext(context);
                }
              });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // _extractWalletConnectQr();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            startQrCheckTimer();
            print("request.url${request.url}");
            if (timer != null) {
              if (timer!.isActive) {
                timer!.cancel();
              }
            }
            if (request.url.contains(
                  "https://verify.walletconnect.org/v3/attestation?projectId",
                ) ||
                request.url.contains("https://verify.walletconnect.com/")) {
              startQrCheckTimer();
              return NavigationDecision.navigate;
            } else if (validateWC(request.url) &&
                !(request.url.contains("@2/wc"))) {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (builder) => WalletConnectPage(
                        selectedWalletData:
                            localStorageService.activeWalletData!,
                        wcURL: request.url,
                      ),
                    ),
                  )
                  .then((v) {
                    walletConnectionRequest.initializeContext(context);
                  });
              return NavigationDecision.prevent;
            } else if (request.url.contains("wc")) {
              return NavigationDecision.prevent;
            } else {
              setState(() {
                urlListener = request.url;
              });
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..clearCache()
      ..loadRequest(Uri.parse("https://defi.bitnevex.com/nvxoswap"));

    // browserController.addListener(_browserListener);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool validateWC(String text) {
    return text.contains("wc:");
  }

  String updateBrowserUrl(String data) {
    if (_isValidUrl(data)) {
      String url = data;
      if (!(url.contains("https://") || url.contains("http://"))) {
        url = "https://$url";
      }

      return url;
    } else {
      return "https://$data";
    }
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack(); // Navigate within the WebView
          return false; // Don't exit the screen
        }
        return true; // Exit the screen if no WebView history
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AppText("Swap", fontSize: 20, fontWeight: FontWeight.w600),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        // body: SafeArea(
        //   child: Stack(
        //     children: [
        //       WebViewWidget(controller: _controller),
        //       if (_progress < 0.8)
        //         Center(
        //           child: CircularProgressIndicator(
        //             // value: _progress,
        //             color: Colors.purpleAccent[100],
        //             strokeWidth: 3,
        //           ),
        //         ),
        //     ],
        //   ),
        // ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GradientAppText(text: 'Coming Soon...', fontSize: 40),
            ),
          ],
        ),
      ),
    );
  }
}
