import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/WalletConnectFunctions/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';

class SignMessageView extends StatefulWidget {
  final SessionStruct session;
  final String title;
  final WCEthereumSignMessage message;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const SignMessageView({
    super.key,
    required this.session,
    required this.title,
    required this.onConfirm,
    required this.onReject,
    required this.message,
  });

  @override
  _SignMessageViewState createState() => _SignMessageViewState();
}

class _SignMessageViewState extends State<SignMessageView> {
  bool isLoading = false;

  var messageData;

  @override
  void initState() {
    super.initState();
    setState(() {
      messageData = jsonDecode(widget.message.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          widget.title,
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back,
                color: Theme.of(context).indicatorColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(height: SizeConfig.height(context, 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white, //Color(0xFF202832),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    widget.session.peer.metadata.icons.isNotEmpty
                        ? widget.session.peer.metadata.icons.first
                        : "",
                    errorBuilder: (_, obj, trc) {
                      return AppText(
                        widget.session.peer.metadata.name.characters.first,
                        fontSize: 20,
                        color: Color(0xFFB982FF),
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.width(context, 3)),
              AppText(
                widget.session.peer.metadata.name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.blueAccent,
                  fontSize: 20.0,
                ),
              )
            ],
          ),
          SizedBox(
            height: SizeConfig.height(context, 5),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText(
                    'Chain ID',
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                Expanded(
                  child: AppText(
                    messageData == null
                        ? ""
                        : messageData["domain"]["chainId"].toString(),
                    color: Theme.of(context).colorScheme.surfaceBright,
                    // style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.height(context, 1),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText(
                    'Verifying Contract',
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                Expanded(
                  child: AppText(
                    messageData == null
                        ? ""
                        : messageData["domain"]["verifyingContract"],
                    color: Theme.of(context).colorScheme.surfaceBright,
                    overflow: TextOverflow.visible,
                    // style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.height(context, 1),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText(
                    'Token Address',
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                Expanded(
                  child: AppText(
                    messageData == null
                        ? ""
                        : messageData["message"]["details"]["token"].toString(),
                    color: Theme.of(context).colorScheme.surfaceBright,
                    overflow: TextOverflow.visible,
                    // style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.height(context, 1),
          ),
          Expanded(child: SizedBox()),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: isLoading ? 0.4 : 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFB982FF),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isLoading = true;
                            });
                            widget.onConfirm();
                          },
                    child: AppText('SIGN'),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFEF96FF),
                  ),
                  onPressed: widget.onReject,
                  child: AppText('REJECT'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: SizeConfig.height(context, 2),
          ),
        ]),
      ),
    );
  }
}
