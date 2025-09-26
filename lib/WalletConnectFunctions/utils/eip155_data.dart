
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/WalletConnectFunctions/models/chain_metadata.dart';

class Eip155Data {
  static final ChainData mainChains = {
    // Ethereum Mainnet
    'eip155:393': ChainMetadata(
      chainId: '393',
      name: 'NVXO Chain',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/nvwallet-5ec7e.appspot.com/o/images%2FAsset%2064x.png?alt=media&token=1e803128-1a39-4bc0-8f32-abf2bca83263',
      rpc: ['https://www.nvxoscan.com/'],
      symbol: 'NVXO',
    ),

    'eip155:1': ChainMetadata(
      chainId: '1',
      name: 'Ethereum',
      symbol: 'ETH',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/kerdos-dee05.appspot.com/o/images%2Feth.png?alt=media&token=0e30b1f2-2d57-4853-8a5c-f8c9aa1b35c7',
      rpc: ['https://mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Arbitrum Mainnet
    'eip155:42161': ChainMetadata(
      chainId: '42161',
      name: 'Arbitrum',
      symbol: 'ARB',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/kerdos-dee05.appspot.com/o/images%2Farbit.png?alt=media&token=2a7ae4df-1d1f-4c40-908f-6af6010976ad',
      rpc: ['https://arbitrum-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Avalanche Mainnet
    'eip155:43114': ChainMetadata(
      chainId: '43114',
      name: 'Avalanche C-Chain',
      symbol: 'AVAX',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/kerdos-dee05.appspot.com/o/images%2Favax.png?alt=media&token=31fc9431-7faf-4451-ac36-21b2926abe38',
      rpc: [
        'https://avalanche-mainnet.infura.io/v3/${apiKeyService.infuraKey}'
      ],
    ),

    // Linea Mainnet
    'eip155:59140': ChainMetadata(
      chainId: '59140',
      name: 'Linea',
      symbol: 'TBA',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/27657.png',
      rpc: ['https://linea-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Polygon Mainnet
    'eip155:137': ChainMetadata(
      chainId: '137',
      name: 'Polygon',
      symbol: 'POL',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/3890.png',
      rpc: ['https://polygon-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Optimism Mainnet
    'eip155:10': ChainMetadata(
      chainId: '10',
      name: 'Optimism',
      symbol: 'OP',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/11840.png',
      rpc: ['https://optimism-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    //Palm mainnet
    'eip155:11297108109': ChainMetadata(
      chainId: '11297108109',
      name: 'PaLM AI',
      symbol: 'PALM',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/28567.png',
      rpc: ['https://palm-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    //Starknet mainnet
    'eip155:534353': ChainMetadata(
      chainId: '534353',
      name: 'StarkNet',
      symbol: 'STRK',
      logo:
          'https://s2.coinmarketcap.com/static/img/coins/64x64/22691.png', // Adjust this path based on your logo storage structure
      rpc: ['https://starknet-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Celo Mainnet
    'eip155:42220': ChainMetadata(
      chainId: '42220',
      name: 'Celo',
      symbol: 'CELO',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/5567.png',
      rpc: ['https://celo-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Binance Smart Chain Mainnet
    'eip155:56': const ChainMetadata(
      chainId: '56',
      name: 'Binance Smart Chain',
      symbol: 'BNB',
      logo:
          'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970',
      rpc: [
        'https://bsc-dataseed1.binance.org',
        'https://bsc-dataseed2.binance.org'
      ], // Example RPC endpoint
    ),

    //ZkSync
    'eip155:324': ChainMetadata(
      chainId: '324',
      name: 'zkSync',
      symbol: '',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/128x128/24091.png',
      rpc: ['https://zksync-mainnet.infura.io/v3/${apiKeyService.infuraKey}'],
    ),
  };

  static final ChainData testChains = {
    //Sepolia
    'eip155:11155111': ChainMetadata(
      chainId: '11155111',
      name: 'Ethereum Sepolia',
      symbol: 'tETH',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/kerdos-dee05.appspot.com/o/images%2Feth.png?alt=media&token=0e30b1f2-2d57-4853-8a5c-f8c9aa1b35c7',
      rpc: ['https://sepolia.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    //

    // Optimism Testnet
    'eip155:11155420': ChainMetadata(
      chainId: '11155420',
      name: 'Optimism Sepolia',
      symbol: 'tOP',
      logo: 'https://s2.coinmarketcap.com/static/img/coins/64x64/11840.png',
      rpc: ['https://optimism-sepolia.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    //Arbitrum Sepolia
    'eip155:421611': ChainMetadata(
      chainId: '421611',
      name: 'Arbitrum Sepolia',
      symbol: 'tARB',
      logo:
          'https://firebasestorage.googleapis.com/v0/b/kerdos-dee05.appspot.com/o/images%2Farbit.png?alt=media&token=2a7ae4df-1d1f-4c40-908f-6af6010976ad', // Adjust this path based on your logo storage structure
      rpc: ['https://arbitrum-sepolia.infura.io/v3/${apiKeyService.infuraKey}'],
    ),

    // Binance Smart Chain Testnet
    'eip155:97': const ChainMetadata(
      chainId: '97',
      name: 'BSC Testnet',
      symbol: 'tBNB',
      logo:
          'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970',
      rpc: ['https://bsc-testnet.drpc.org'],
    ),
  };

  static final ChainData chains = {...mainChains, ...testChains};

  static final Map<Eip155Methods, String> methods = {
    Eip155Methods.PERSONAL_SIGN: 'personal_sign',
    Eip155Methods.ETH_SIGN: 'eth_sign',
    Eip155Methods.ETH_SIGN_TRANSACTION: 'eth_signTransaction',
    Eip155Methods.ETH_SIGN_TYPED_DATA: 'eth_signTypedData',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V3: 'eth_signTypedData_v3',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V4: 'eth_signTypedData_v4',
    Eip155Methods.ETH_SEND_RAW_TRANSACTION: 'eth_sendRawTransaction',
    Eip155Methods.ETH_SEND_TRANSACTION: 'eth_sendTransaction'
  };
}

enum Eip155Methods {
  PERSONAL_SIGN,
  ETH_SIGN,
  ETH_SIGN_TRANSACTION,
  ETH_SIGN_TYPED_DATA,
  ETH_SIGN_TYPED_DATA_V3,
  ETH_SIGN_TYPED_DATA_V4,
  ETH_SEND_RAW_TRANSACTION,
  ETH_SEND_TRANSACTION,
}

extension Eip155MethodsX on Eip155Methods {
  String? get value => Eip155Data.methods[this];
}

extension Eip155MethodsStringX on String {
  Eip155Methods? toEip155Method() {
    final entries =
        Eip155Data.methods.entries.where((element) => element.value == this);
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}
