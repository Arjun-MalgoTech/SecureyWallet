import 'package:flutter/material.dart';
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/WalletConnectFunctions/models/ethereum/wc_ethereum_transaction.dart';
import 'package:securywallet/WalletConnectFunctions/utils/eip155_data.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:web3dart/web3dart.dart';

class TransactionDialog extends StatefulWidget {
  final SessionStruct session;
  final int chainId;
  final WCEthereumTransaction ethereumTransaction;
  final String title;
  final BigInt transactionFees;
  final BigInt value;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const TransactionDialog({
    super.key,
    required this.session,
    required this.chainId,
    required this.ethereumTransaction,
    required this.title,
    required this.transactionFees,
    required this.value,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  late String transactionFeesInEther;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    transactionFeesInEther =
        (widget.transactionFees / BigInt.parse("1000000000000000000"))
            .toStringAsFixed(10);
    print("trans....$transactionFeesInEther");
  }

  String enterAmount(BigInt amount) {
    return (amount / BigInt.parse("1000000000000000000")).toString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onReject();
        return true; // allow popping the screen after calling onReject
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: AppText(
            widget.title,

            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          centerTitle: true,
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
            onPressed: () {
              widget.onReject();
            },
          ),
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
                    flex: 2,
                    child: AppText(
                      'Asset',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      Eip155Data.chains["eip155:${widget.chainId}"]!.name
                          .toString(),
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
                    flex: 2,
                    child: AppText(
                      'From',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      CommonCalculationFunctions.maskWalletAddress(
                          widget.ethereumTransaction.from),
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
                    flex: 2,
                    child: AppText(
                      'Recipient',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      CommonCalculationFunctions.maskWalletAddress(
                          widget.ethereumTransaction.to!),
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
                    flex: 2,
                    child: AppText(
                      'Transaction Fee',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      '${transactionFeesInEther} ${Eip155Data.chains["eip155:${widget.chainId}"]!.symbol}',
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
                    flex: 2,
                    child: AppText(
                      'Transaction Amount',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      "${enterAmount(EtherAmount.inWei(widget.value).getInWei)} ${Eip155Data.chains["eip155:${widget.chainId}"]!.symbol}",
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppText(
                      'DApp',
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      widget.session.peer.metadata.url
                          .replaceFirst('https://', ''),
                      color: Theme.of(context).colorScheme.surfaceBright,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "Make sure you trust this site. By interacting with it,",
                            fontSize: 11,
                          ),
                          AppText(
                            "you allow this site to access you funds.",
                            fontSize: 11,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
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
                      child: AppText('CONFIRM'),
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
      ),
    );
  }
}
