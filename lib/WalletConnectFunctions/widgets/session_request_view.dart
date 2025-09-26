import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:securywallet/WalletConnectFunctions/models/chain_metadata.dart';
import 'package:securywallet/WalletConnectFunctions/utils/eip155_data.dart';
import 'package:securywallet/WalletConnectFunctions/utils/helpers.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import '../models/accounts.dart';

class SessionRequestView extends StatefulWidget {
  final List<Account> accounts;
  final RequestSessionPropose proposal;
  final void Function(SessionNamespaces) onApprove;
  final void Function() onReject;

  const SessionRequestView({
    Key? key,
    required this.accounts,
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<SessionRequestView> createState() => _SessionRequestViewState();
}

class _SessionRequestViewState extends State<SessionRequestView> {
  late AppMetadata _metadata;
  late List<String> _selectedAccountIds;

  @override
  void initState() {
    _metadata = widget.proposal.proposer.metadata;
    _selectedAccountIds = [];
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final List<ChainMetadata> chainList = Eip155Data.chains.values.toList();
    return WillPopScope(
      onWillPop: () async {
        widget.onReject();
        return true; // allow popping the screen after calling onReject
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: AppText(
            "Connect DApp",
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
            onPressed: () {
              widget.onReject();
            },
          ),
        ),
        body: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50.0,
                    width: 50.0,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      image: _metadata.icons.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_metadata.icons.first))
                          : null,
                    ),
                    child: _metadata.icons.isNotEmpty
                        ? null
                        : Center(
                            child: Text(
                              _metadata.name.substring(0, 1),
                              style: const TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  AppText(
                      "${_metadata.name} wants to connect to your wallet",
                      overflow: TextOverflow.clip,
                      fontSize: 16.0,
                      textAlign: TextAlign.center,
                      color: Color(0xFFB982FF)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: AppText(
                      _metadata.url,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1.5,
                thickness: 1.5,
                color: Theme.of(context).colorScheme.surfaceBright),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppText("Networks:", color: Color(0xFFB982FF)),
                )),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: chainList.length,
                itemBuilder: (context, index) {
                  final chain = chainList[index];
                  return Card(
                    color: Theme.of(context).shadowColor,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white, //Color(0xFF202832),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            chain.logo,
                            errorBuilder: (_, obj, trc) {
                              return AppText(
                                chain.name.characters.first,
                                fontSize: 20,
                                color: Color(0xFFB982FF),
                                fontWeight: FontWeight.bold,
                              );
                            },
                          ),
                        ),
                      ),
                      title: AppText(
                        chain.name,
                        color: Theme.of(context).colorScheme.surfaceBright,
                        overflow: TextOverflow.clip,
                      ),
                      subtitle: AppText(
                        CommonCalculationFunctions.maskWalletAddress(
                            widget.accounts[0].details[0].address),
                        color: Theme.of(context).colorScheme.surfaceBright,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.featured_play_list_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  AppText(
                    "View your wallet balance and activity",
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  AppText(
                    "Request approval for transactions",
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Platform.isIOS ? 30 : 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: widget.onReject,
                        child: AppText(
                          'Cancel',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: Opacity(
                        opacity: isLoading ? 0.4 : 1,
                        child: ReuseElevatedButton(
                          onTap: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final SessionNamespaces params = {};
                                  for (final entry in widget
                                      .proposal.requiredNamespaces.entries) {
                                    final List<String> accounts = [];
                                    for (final idStr in _selectedAccountIds) {
                                      final accs = widget.accounts.where(
                                          (element) =>
                                              '${entry.key}:${element.id}' ==
                                              idStr);
                                      if (accs.isNotEmpty) {
                                        for (final chain in entry.value.chains
                                            .where((c) => accs.first.details
                                                .any((ad) => ad.chain == c))) {
                                          accounts.add(
                                              '$chain:${accs.first.details.firstWhere((e) => e.chain == chain).address}');
                                        }
                                      }
                                    }
                                    params[entry.key] = SessionNamespace(
                                      accounts: accounts,
                                      methods: entry.value.methods,
                                      events: entry.value.events,
                                    );
                                    log('SESSION: ${params[entry.key]!.toJson()}');
                                  }
                                  widget.onApprove(params);
                                },
                          text: 'Connect',
                          gradientColors: [],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final List<Account> accounts;
  final ProposalRequiredNamespace namespace;
  final List<String> selectedAccountIds;

  const NamespaceView({
    super.key,
    required this.type,
    required this.accounts,
    required this.namespace,
    required this.selectedAccountIds,
  });

  @override
  State<NamespaceView> createState() => _NamespaceViewState();
}

class _NamespaceViewState extends State<NamespaceView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review ${widget.type} permissions',
            style: const TextStyle(fontSize: 17.0, color: Color(0xFFB982FF)),
          ),
          const SizedBox(height: 8.0),
          ...widget.namespace.chains
              .map((chain) => Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getChainName(chain),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              color: Color(0xFFB982FF)),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            'Methods',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB982FF)),
                          ),
                        ),
                        Text(
                          widget.namespace.methods.isEmpty
                              ? '-'
                              : widget.namespace.methods.join(', '),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            'Events',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB982FF)),
                          ),
                        ),
                        Text(
                          widget.namespace.events.isEmpty
                              ? '-'
                              : widget.namespace.events.join(', '),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AppText(
              'Choose ${widget.type} accounts',
              style: const TextStyle(fontSize: 17.0, color: Color(0xFFB982FF)),
            ),
          ),
          ...widget.accounts
              .where((acc) => acc.details.any(
                  (accDetails) => accDetails.chain.startsWith(widget.type)))
              .map((acc) {
            final details =
                acc.details.firstWhere((e) => e.chain.startsWith(widget.type));
            final isSelected =
                widget.selectedAccountIds.contains('${widget.type}:${acc.id}');

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      if (isSelected) {
                        widget.selectedAccountIds
                            .remove('${widget.type}:${acc.id}');
                      } else {
                        widget.selectedAccountIds
                            .add('${widget.type}:${acc.id}');
                      }
                      setState(() {});
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  AppText(
                    '${acc.name} - ${details.address.substring(0, 6)}...${details.address.substring(details.address.length - 6)}',
                    fontSize: 14,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
