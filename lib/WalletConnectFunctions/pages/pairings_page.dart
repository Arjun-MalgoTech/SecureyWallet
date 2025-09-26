import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';

class PairingsPage extends StatefulWidget {
  final SignClient signClient;

  const PairingsPage({
    super.key,
    required this.signClient,
  });

  @override
  State<PairingsPage> createState() => _PairingsPageState();
}

class _PairingsPageState extends State<PairingsPage> {
  WalletConnectionRequest walletConnectionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    walletConnectionRequest = context.watch<WalletConnectionRequest>();
    walletConnectionRequest.initializeContext(context);
    final pairings = walletConnectionRequest.signClient!.session.getAll();

    return pairings.isEmpty
        ? const Center(
            child: Text(
            'No pairings found.',
            style: TextStyle(color: Color(0xFFB982FF)),
          ))
        : ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, idx) {
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                tileColor: Theme.of(context).cardColor,
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: pairings[idx].peer.metadata.icons.isEmpty
                      ? null
                      : NetworkImage(pairings[idx].peer.metadata.icons[0]),
                  child: Image.network(
                    pairings[idx].peer.metadata.icons.isEmpty
                        ? ""
                        : pairings[idx].peer.metadata.icons[0].toString(),
                    errorBuilder: (_, obj, trc) {
                      return AppText(
                        pairings[idx].peer.metadata.name.characters.first,
                        fontSize: 20,
                        color: Color(0xFFB982FF),
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                ),
                title: AppText(pairings[idx].peer.metadata.name ?? 'Unnamed'),
                subtitle: AppText(
                  pairings[idx].peer.metadata.url ?? '',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
                trailing: IconButton(
                  onPressed: () {
                    walletConnectionRequest.signClient!.engine
                        .disconnect(
                            topic: pairings[idx].topic,
                            reason: const ErrorResponse(
                              message: "User disconnected.",
                              code: 9999,
                            ))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Pairing delete successfully.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Colors.green,
                      ));
                      setState(() {});
                    }).catchError((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Failed to delete pairing. Please reconnect'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Colors.red,
                      ));
                      setState(() {});
                    });
                  },
                  icon: Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.red.shade300,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemCount: pairings.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
          );
  }
}
