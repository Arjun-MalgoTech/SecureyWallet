import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/AssetTransactionApi.dart';
import 'package:securywallet/Crypto_Utils/Wallet_Theme/App_Theme.dart';
import 'package:securywallet/Screens/NftFlow/nftScreen.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/ViewModel/Pre_Home_Screen_VM.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Api_Service/Transaction_Api/Transaction_Api.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

fetchAllProvider() {
  return [
    ChangeNotifierProvider(create: (_) => ThemeController()),
    ChangeNotifierProvider(create: (_) => PreHomeScreenVm()),
    ChangeNotifierProvider(create: (_) => LocalStorageService()),
    ChangeNotifierProvider(create: (_) => TransactionService()),
    ChangeNotifierProvider(create: (_) => WalletConnectionRequest()),
    ChangeNotifierProvider(create: (_) => AssetTransactionAPI()),
    // ChangeNotifierProvider(
    //   create: (_) => NFTProvider(
    //     rpcUrl: RPC_URL,
    //     contractAddress: ERC721_CONTRACT_ADDRESS,
    //   ),
    // ),
  ];
}
