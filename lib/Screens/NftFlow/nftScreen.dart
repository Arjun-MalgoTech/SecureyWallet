// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
// import 'package:web3dart/web3dart.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:securywallet/Api_Service/Apikey_Service.dart';
//
// // ----------------------- CONFIG -----------------------
// // Replace these with your RPC and target contract info
// final String RPC_URL =
//     'https://mainnet.infura.io/v3/${apiKeyService.infuraKey}'; // public RPC for testing
// const int CHAIN_ID = 1; // mainnet chain id; change for testnets
// const String ERC721_CONTRACT_ADDRESS =
//     '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d'; // put contract address to test
//
// // Minimal ERC-721 ABI with needed functions and events
// const String erc721Abi = '''[
//   {
//     "constant": true,
//     "inputs": [{"name": "owner", "type": "address"}],
//     "name": "balanceOf",
//     "outputs": [{"name": "balance", "type": "uint256"}],
//     "type": "function"
//   },
//   {
//     "constant": true,
//     "inputs": [{"name": "tokenId", "type": "uint256"}],
//     "name": "ownerOf",
//     "outputs": [{"name": "owner", "type": "address"}],
//     "type": "function"
//   },
//   {
//     "constant": true,
//     "inputs": [{"name": "owner", "type": "address"}, {"name": "index", "type": "uint256"}],
//     "name": "tokenOfOwnerByIndex",
//     "outputs": [{"name": "tokenId", "type": "uint256"}],
//     "type": "function"
//   },
//   {
//     "constant": true,
//     "inputs": [{"name": "tokenId", "type": "uint256"}],
//     "name": "tokenURI",
//     "outputs": [{"name": "", "type": "string"}],
//     "type": "function"
//   }
// ]
// ''';
//
// // Optional: configure an IPFS gateway to resolve ipfs:// URIs
// const String IPFS_GATEWAY = 'https://ipfs.io/ipfs/';
//
// // ----------------------- MODELS -----------------------
// class NFT {
//   final String contract;
//   final BigInt tokenId;
//   final String name;
//   final String description;
//   final String image; // resolved URL (http/ipfs)
//   final String rawTokenURI;
//
//   NFT({
//     required this.contract,
//     required this.tokenId,
//     required this.name,
//     required this.description,
//     required this.image,
//     required this.rawTokenURI,
//   });
// }
//
// // ----------------------- SERVICE -----------------------
// class NFTService {
//   final Web3Client client;
//   final DeployedContract contract;
//
//   NFTService._(this.client, this.contract);
//
//   static Future<NFTService> create(
//     String rpcUrl,
//     String contractAddress,
//   ) async {
//     final httpClient = http.Client();
//     final client = Web3Client(rpcUrl, httpClient);
//
//     final block = await client.getBlockNumber();
//     print('Block: $block');
//
//     final contract = DeployedContract(
//       ContractAbi.fromJson(erc721Abi, 'ERC721'),
//       EthereumAddress.fromHex(contractAddress),
//     );
//     return NFTService._(client, contract);
//   }
//
//   Future<int> balanceOf(EthereumAddress owner) async {
//     final func = contract.function('balanceOf');
//     try {
//       final res = await client.call(
//         contract: contract,
//         function: func,
//         params: [owner],
//       );
//
//       if (res.isEmpty) return 0;
//       if (res.first is BigInt) {
//         return (res.first as BigInt).toInt();
//       }
//
//       print('⚠️ Unexpected balanceOf result: ${res.first}');
//       return 0;
//     } catch (e) {
//       print('⚠️ balanceOf error: $e');
//       return 0;
//     }
//   }
//
//   Future<BigInt?> tokenOfOwnerByIndex(EthereumAddress owner, int index) async {
//     try {
//       final func = contract.function('tokenOfOwnerByIndex');
//       final res = await client.call(
//         contract: contract,
//         function: func,
//         params: [owner, BigInt.from(index)],
//       );
//       return res.first as BigInt;
//     } catch (e) {
//       print("⚠️ Contract does not support ERC721Enumerable: $e");
//       return null;
//     }
//   }
//
//   Future<String> tokenURI(BigInt tokenId) async {
//     final func = contract.function('tokenURI');
//     final res = await client.call(
//       contract: contract,
//       function: func,
//       params: [tokenId],
//     );
//     return res.first as String;
//   }
//
//   Future<Map<String, dynamic>> fetchMetadata(String tokenUri) async {
//     if (tokenUri.startsWith('ipfs://')) {
//       final path = tokenUri.substring(7);
//       final url = IPFS_GATEWAY + path;
//       final resp = await http.get(Uri.parse(url));
//       if (resp.statusCode == 200) {
//         return json.decode(resp.body) as Map<String, dynamic>;
//       }
//       throw Exception('Failed to fetch IPFS metadata');
//     }
//
//     if (tokenUri.startsWith('data:application/json;base64,')) {
//       final b64 = tokenUri.substring('data:application/json;base64,'.length);
//       final jsonStr = utf8.decode(base64.decode(b64));
//       return json.decode(jsonStr) as Map<String, dynamic>;
//     }
//
//     final resp = await http.get(Uri.parse(tokenUri));
//     if (resp.statusCode == 200) {
//       return json.decode(resp.body) as Map<String, dynamic>;
//     }
//     throw Exception('Failed to fetch metadata: ${resp.statusCode}');
//   }
//
//   String resolveImageUrl(String rawImage) {
//     if (rawImage.startsWith('ipfs://')) {
//       return IPFS_GATEWAY + rawImage.substring(7);
//     }
//     return rawImage;
//   }
//
//   Future<List<NFT>> fetchOwnerNFTs(EthereumAddress owner) async {
//     final bal = await balanceOf(owner);
//     if (bal == 0) {
//       print("✅ No NFTs owned by this wallet.");
//       return [];
//     }
//
//     final out = <NFT>[];
//     for (var i = 0; i < bal; i++) {
//       final tokenId = await tokenOfOwnerByIndex(owner, i);
//
//       if (tokenId == null) {
//         print("⚠️ Cannot enumerate NFTs for this contract.");
//         return []; // stop early
//       }
//
//       final uri = await tokenURI(tokenId);
//       Map<String, dynamic> meta;
//       try {
//         meta = await fetchMetadata(uri);
//       } catch (e) {
//         meta = {
//           'name': 'Token #${tokenId.toString()}',
//           'description': '',
//           'image': '',
//         };
//       }
//
//       final imageField =
//           meta['image'] ?? meta['image_url'] ?? meta['animation_url'] ?? '';
//       final resolvedImage = imageField is String
//           ? resolveImageUrl(imageField)
//           : '';
//
//       out.add(
//         NFT(
//           contract: contract.address.hex,
//           tokenId: tokenId,
//           name: meta['name']?.toString() ?? 'Token #${tokenId.toString()}',
//           description: meta['description']?.toString() ?? '',
//           image: resolvedImage,
//           rawTokenURI: uri,
//         ),
//       );
//     }
//     return out;
//   }
//
//   Future<String> transferNFT({
//     required Credentials credentials,
//     required EthereumAddress from,
//     required EthereumAddress to,
//     required BigInt tokenId,
//   }) async {
//     final function = contract.function('safeTransferFrom');
//     final tx = Transaction.callContract(
//       contract: contract,
//       function: function,
//       parameters: [from, to, tokenId],
//     );
//     final hash = await client.sendTransaction(
//       credentials,
//       tx,
//       chainId: CHAIN_ID,
//       fetchChainIdFromNetworkId: false,
//     );
//     return hash;
//   }
// }
//
// // ----------------------- PROVIDER -----------------------
// class NFTProvider with ChangeNotifier {
//   final String rpcUrl;
//   final String contractAddress;
//   NFTService? _service;
//   List<NFT> nfts = [];
//   bool loading = false;
//
//   NFTProvider({required this.rpcUrl, required this.contractAddress});
//
//   Future<void> ensureService() async {
//     if (_service == null) {
//       _service = await NFTService.create(rpcUrl, contractAddress);
//     }
//   }
//
//   Future<void> loadNFTsForAddress(String addressHex) async {
//     loading = true;
//     notifyListeners();
//     try {
//       await ensureService();
//       final owner = EthereumAddress.fromHex(addressHex);
//       nfts = await _service!.fetchOwnerNFTs(owner);
//     } finally {
//       loading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<String> sendNFT(
//     String privateKeyHex,
//     String fromHex,
//     String toHex,
//     BigInt tokenId,
//   ) async {
//     await ensureService();
//     final creds = EthPrivateKey.fromHex(privateKeyHex);
//     final from = EthereumAddress.fromHex(fromHex);
//     final to = EthereumAddress.fromHex(toHex);
//     final txHash = await _service!.transferNFT(
//       credentials: creds,
//       from: from,
//       to: to,
//       tokenId: tokenId,
//     );
//     return txHash;
//   }
// }
//
// // ----------------------- UI -----------------------
// // void main() {
// //   runApp(
// //     MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider(
// //           create: (_) => NFTProvider(
// //             rpcUrl: RPC_URL,
// //             contractAddress: ERC721_CONTRACT_ADDRESS,
// //           ),
// //         ),
// //       ],
// //       child: const MyApp(),
// //     ),
// //   );
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'NFT Wallet Example',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       home: const HomePage(),
// //     );
// //   }
// // }
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final _addressController = TextEditingController();
//   final _contractController = TextEditingController(
//     text: ERC721_CONTRACT_ADDRESS,
//   );
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     fetchAllNFTs(_addressController.text);
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     _contractController.dispose();
//     super.dispose();
//   }
//
//   Future<List<NFT>> fetchAllNFTs(String ownerAddress) async {
//     final apiKey = 'gSBUx520RvEVfp8EK9XqfP2mvdlqYRaz';
//     final url =
//         'https://eth-mainnet.alchemyapi.io/v2/$apiKey/getNFTs?owner=$ownerAddress';
//
//     final resp = await http.get(Uri.parse(url));
//     print("${resp.statusCode}");
//     print("${resp.body}");
//     if (resp.statusCode != 200) throw Exception('Failed to fetch NFTs');
//
//     final data = json.decode(resp.body);
//     final nfts = <NFT>[];
//
//     for (var item in data['ownedNfts']) {
//       final metadata = item['metadata'] ?? {};
//       final image = metadata['image'] ?? '';
//       final tokenId = BigInt.parse(item['id']['tokenId'].toString());
//       nfts.add(
//         NFT(
//           contract: item['contract']['address'],
//           tokenId: tokenId,
//           name: metadata['name'] ?? 'Token #$tokenId',
//           description: metadata['description'] ?? '',
//           image: image.startsWith('ipfs://')
//               ? 'https://ipfs.io/ipfs/${image.substring(7)}'
//               : image,
//           rawTokenURI: item['tokenUri']?['gateway'] ?? '',
//         ),
//       );
//     }
//     print("$nfts");
//     return nfts;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<NFTProvider>(context);
//     return Scaffold(
//       appBar: AppBar(title: AppText('NFT Wallet Example')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _contractController,
//               decoration: const InputDecoration(
//                 labelText: 'ERC721 Contract Address',
//                 labelStyle: TextStyle(color: Colors.white),
//               ),
//               onChanged: (v) => provider.contractAddress.replaceAll('', ''),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(
//                 labelText: 'Owner Address (0x...)',
//                 labelStyle: TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () async {
//                     final addr = _addressController.text.trim();
//                     if (addr.isEmpty) return;
//                     // update provider's contract address if user changed
//                     provider.contractAddress == _contractController.text.trim();
//                     await provider.loadNFTsForAddress(addr);
//                     fetchAllNFTs("0x3239Df95eFCF9882DA672773b4b261B47DfEa961");
//                   },
//                   child: AppText('Load NFTs', color: Colors.black),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final addr = _addressController.text.trim();
//                     if (addr.isEmpty) return;
//                     final url = 'https://etherscan.io/address/$addr';
//                     if (await canLaunchUrl(Uri.parse(url))) {
//                       await launchUrl(Uri.parse(url));
//                     }
//                   },
//                   child: AppText('View on Etherscan', color: Colors.black),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             provider.loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Expanded(
//                     child: provider.nfts.isEmpty
//                         ? Center(
//                             child: AppText(
//                               'No NFTs found (or contract not enumerable).',
//                             ),
//                           )
//                         : GridView.builder(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   childAspectRatio: 0.78,
//                                 ),
//                             itemCount: provider.nfts.length,
//                             itemBuilder: (context, idx) {
//                               final nft = provider.nfts[idx];
//                               return GestureDetector(
//                                 onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => NFTDetailPage(
//                                       nft: nft,
//                                       provider: provider,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Card(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                       Expanded(
//                                         child: nft.image.startsWith('data:')
//                                             ? _buildDataImage(nft.image)
//                                             : CachedNetworkImage(
//                                                 imageUrl: nft.image.isNotEmpty
//                                                     ? nft.image
//                                                     : 'https://via.placeholder.com/300',
//                                                 fit: BoxFit.cover,
//                                                 placeholder: (context, url) =>
//                                                     const Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                                 errorWidget:
//                                                     (context, url, error) =>
//                                                         const Center(
//                                                           child: Icon(
//                                                             Icons.broken_image,
//                                                           ),
//                                                         ),
//                                               ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               nft.name,
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             AppText(
//                                               'ID: ${nft.tokenId.toString()}',
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDataImage(String dataUri) {
//     // handles simple data:image/svg+xml;base64, or data:image/png;base64,
//     if (dataUri.contains('image/svg+xml')) {
//       final prefix = 'data:image/svg+xml;base64,';
//       final start = dataUri.indexOf('base64,');
//       if (start != -1) {
//         final b64 = dataUri.substring(start + 'base64,'.length);
//         final svgStr = utf8.decode(base64.decode(b64));
//         return SvgPicture.string(svgStr, fit: BoxFit.contain);
//       }
//     }
//     if (dataUri.contains('image/png') ||
//         dataUri.contains('image/jpeg') ||
//         dataUri.contains('image/jpg')) {
//       final start = dataUri.indexOf('base64,');
//       if (start != -1) {
//         final b64 = dataUri.substring(start + 'base64,'.length);
//         final bytes = base64.decode(b64);
//         return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover);
//       }
//     }
//     return const Center(child: Icon(Icons.broken_image));
//   }
// }
//
// class NFTDetailPage extends StatefulWidget {
//   final NFT nft;
//   final NFTProvider provider;
//
//   const NFTDetailPage({required this.nft, required this.provider, super.key});
//
//   @override
//   State<NFTDetailPage> createState() => _NFTDetailPageState();
// }
//
// class _NFTDetailPageState extends State<NFTDetailPage> {
//   final _toController = TextEditingController();
//   final _pkController = TextEditingController();
//   bool _sending = false;
//   String? _txHash;
//
//   @override
//   void dispose() {
//     _toController.dispose();
//     _pkController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final nft = widget.nft;
//     return Scaffold(
//       appBar: AppBar(title: Text(nft.name)),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: nft.image.startsWith('data:')
//                         ? _buildDataImage(nft.image)
//                         : CachedNetworkImage(
//                             imageUrl: nft.image.isNotEmpty
//                                 ? nft.image
//                                 : 'https://via.placeholder.com/600',
//                             fit: BoxFit.contain,
//                             placeholder: (context, url) => const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                             errorWidget: (context, url, error) =>
//                                 const Center(child: Icon(Icons.broken_image)),
//                           ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     nft.description.isNotEmpty
//                         ? nft.description
//                         : '(no description)',
//                     maxLines: 4,
//                   ),
//                   const SizedBox(height: 8),
//                   Text('Contract: ${nft.contract}'),
//                   Text('Token ID: ${nft.tokenId}'),
//                 ],
//               ),
//             ),
//             const Divider(),
//             TextField(
//               controller: _toController,
//               decoration: const InputDecoration(
//                 labelText: 'Recipient address (0x...)',
//               ),
//             ),
//             TextField(
//               controller: _pkController,
//               decoration: const InputDecoration(
//                 labelText: 'Sender private key (hex, 0x...)',
//               ),
//             ),
//             const SizedBox(height: 8),
//             if (_sending)
//               const CircularProgressIndicator()
//             else
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         final pk = _pkController.text.trim();
//                         final to = _toController.text.trim();
//                         if (pk.isEmpty || to.isEmpty) return;
//                         setState(() {
//                           _sending = true;
//                           _txHash = null;
//                         });
//                         try {
//                           final tx = await widget.provider.sendNFT(
//                             pk,
//                             _pkController.text.trim().startsWith('0x')
//                                 ? _pkController.text.trim()
//                                 : '0x' + _pkController.text.trim(),
//                             to,
//                             widget.nft.tokenId,
//                           );
//                           setState(() {
//                             _txHash = tx;
//                           });
//                         } catch (e) {
//                           ScaffoldMessenger.of(
//                             context,
//                           ).showSnackBar(SnackBar(content: Text('Error: \$e')));
//                         } finally {
//                           setState(() {
//                             _sending = false;
//                           });
//                         }
//                       },
//                       child: const Text('Send NFT'),
//                     ),
//                   ),
//                 ],
//               ),
//             if (_txHash != null) SelectableText('Tx hash: \$_txHash'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDataImage(String dataUri) {
//     // reuse small handler
//     if (dataUri.contains('image/svg+xml')) {
//       final prefix = 'data:image/svg+xml;base64,';
//       final start = dataUri.indexOf('base64,');
//       if (start != -1) {
//         final b64 = dataUri.substring(start + 'base64,'.length);
//         final svgStr = utf8.decode(base64.decode(b64));
//         return SvgPicture.string(svgStr, fit: BoxFit.contain);
//       }
//     }
//     if (dataUri.contains('image/png') ||
//         dataUri.contains('image/jpeg') ||
//         dataUri.contains('image/jpg')) {
//       final start = dataUri.indexOf('base64,');
//       if (start != -1) {
//         final b64 = dataUri.substring(start + 'base64,'.length);
//         final bytes = base64.decode(b64);
//         return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain);
//       }
//     }
//     return const Center(child: Icon(Icons.broken_image));
//   }
// }
//
// // ----------------------- NOTES -----------------------
// // - This example assumes the target ERC-721 implements Enumerable (tokenOfOwnerByIndex).
// //   Many contracts do not implement this; in that case you need an indexer or third-party API
// //   (OpenSea API, Alchemy, Moralis, Covalent, The Graph) to list tokens. The on-chain enumeration
// //   approach is simple but may not work for all collections.
// // - For production, don't ask users for raw private keys in plain text. Integrate secure
// //   key management, hardware wallets, or WalletConnect.
// // - Add caching, pagination, and a backend indexer to support large collections and better UX.
// // - Handle ERC-1155 differences (batch balances, uri with {id} placeholders).
// // - Improve SVG sanitization and avoid executing untrusted content.
// // - This is a starting point you can expand and modularize.

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

// ---------------- NFT MODEL ----------------
class NFT {
  final String contract;
  final String tokenId;
  final String name;
  final String description;
  final String image;
  final String rawTokenURI;

  NFT({
    required this.contract,
    required this.tokenId,
    required this.name,
    required this.description,
    required this.image,
    required this.rawTokenURI,
  });
}

// ---------------- HOME PAGE ----------------
class Nfts extends StatefulWidget {
  const Nfts({super.key});

  @override
  State<Nfts> createState() => _NftsState();
}

class _NftsState extends State<Nfts> {
  final String ownerAddress =
      '0x3239Df95eFCF9882DA672773b4b261B47DfEa961'; // wallet
  final String alchemyApiKey =
      'gSBUx520RvEVfp8EK9XqfP2mvdlqYRaz'; // Alchemy API
  final String rpcUrl =
      'https://mainnet.infura.io/v3/${apiKeyService.infuraKey}'; // for sending tx
  List<NFT> nfts = [];
  bool loading = true;

  late Web3Client web3client;

  @override
  void initState() {
    super.initState();
    web3client = Web3Client(rpcUrl, Client());
    fetchNFTs();
  }

  Future<void> fetchNFTs() async {
    setState(() => loading = true);
    try {
      final url =
          'https://eth-mainnet.alchemyapi.io/v2/$alchemyApiKey/getNFTs?owner=$ownerAddress';
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) throw Exception('Failed to fetch NFTs');

      final data = json.decode(resp.body);
      final List<NFT> fetchedNFTs = [];

      for (var item in data['ownedNfts']) {
        final metadata = item['metadata'] ?? {};
        final image = metadata['image'] ?? '';
        final tokenId = item['id']['tokenId'] ?? '';
        fetchedNFTs.add(
          NFT(
            contract: item['contract']['address'] ?? '',
            tokenId: tokenId,
            name: metadata['name'] ?? 'Token #$tokenId',
            description: metadata['description'] ?? '',
            image: image.startsWith('ipfs://')
                ? 'https://ipfs.io/ipfs/${image.substring(7)}'
                : image,
            rawTokenURI: item['tokenUri']?['gateway'] ?? '',
          ),
        );
      }

      setState(() => nfts = fetchedNFTs);
    } catch (e) {
      print('Error fetching NFTs: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildDataImage(String dataUri) {
    if (dataUri.contains('image/svg+xml')) {
      final start = dataUri.indexOf('base64,');
      if (start != -1) {
        final b64 = dataUri.substring(start + 'base64,'.length);
        final svgStr = utf8.decode(base64.decode(b64));
        return SvgPicture.string(svgStr, fit: BoxFit.contain);
      }
    }
    if (dataUri.contains('image/png') ||
        dataUri.contains('image/jpeg') ||
        dataUri.contains('image/jpg')) {
      final start = dataUri.indexOf('base64,');
      if (start != -1) {
        final b64 = dataUri.substring(start + 'base64,'.length);
        final bytes = base64.decode(b64);
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    }
    return const Center(child: Icon(Icons.broken_image));
  }

  Future<String> sendNFT({
    required String privateKey,
    required String contractAddress,
    required String toAddress,
    required BigInt tokenId,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final contract = DeployedContract(
      ContractAbi.fromJson('''
        [
          {"constant": false, "inputs": [{"name": "from", "type": "address"}, {"name": "to", "type": "address"}, {"name": "tokenId", "type": "uint256"}], "name": "safeTransferFrom", "outputs": [], "type": "function"}
        ]
        ''', 'ERC721'),
      EthereumAddress.fromHex(contractAddress),
    );
    final function = contract.function('safeTransferFrom');

    final tx = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        EthereumAddress.fromHex(ownerAddress),
        EthereumAddress.fromHex(toAddress),
        tokenId,
      ],
    );

    final hash = await web3client.sendTransaction(
      credentials,
      tx,
      chainId: 1,
      fetchChainIdFromNetworkId: false,
    );
    return hash;
  }

  void _showSendDialog(NFT nft) {
    final toController = TextEditingController();
    final pkController = TextEditingController();
    bool sending = false;
    String? txHash;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Send ${nft.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: toController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient address',
                  ),
                ),
                TextField(
                  controller: pkController,
                  decoration: const InputDecoration(
                    labelText: 'Your private key',
                  ),
                ),
                if (sending) const CircularProgressIndicator(),
                if (txHash != null)
                  SelectableText(
                    'Tx hash: $txHash',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: sending ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: sending
                    ? null
                    : () async {
                        final to = toController.text.trim();
                        final pk = pkController.text.trim();
                        if (to.isEmpty || pk.isEmpty) return;

                        setStateDialog(() {
                          sending = true;
                          txHash = null;
                        });

                        try {
                          final hash = await sendNFT(
                            privateKey: pk.startsWith('0x') ? pk : '0x$pk',
                            contractAddress: nft.contract,
                            toAddress: to,
                            tokenId: BigInt.parse(nft.tokenId),
                          );
                          setStateDialog(() {
                            txHash = hash;
                          });
                        } catch (e) {
                          setStateDialog(() {
                            txHash = 'Error: $e';
                          });
                        } finally {
                          setStateDialog(() => sending = false);
                        }
                      },
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: AppText('Loading...'),
              ),
            )
          : nfts.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(80.0),
              child: AppText('No NFTs found for this wallet.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: nfts.length,
              itemBuilder: (context, index) {
                final nft = nfts[index];

                return GestureDetector(
                  onTap: () => _showSendDialog(nft),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      // stronger blur
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: nft.image.startsWith('data:')
                                  ? _buildDataImage(nft.image)
                                  : CachedNetworkImage(
                                      imageUrl: nft.image.isNotEmpty
                                          ? nft.image
                                          : 'https://via.placeholder.com/300',
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nft.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${BigInt.parse(nft.tokenId).toString()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
