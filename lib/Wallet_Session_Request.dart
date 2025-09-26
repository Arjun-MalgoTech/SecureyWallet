import 'dart:developer';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/WalletConnectFunctions/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:securywallet/WalletConnectFunctions/models/ethereum/wc_ethereum_transaction.dart';
import 'package:securywallet/WalletConnectFunctions/utils/eip155_data.dart';
import 'package:securywallet/WalletConnectFunctions/utils/hd_key_utils.dart';
import 'package:securywallet/WalletConnectFunctions/widgets/SignMessageView.dart';
import 'package:securywallet/WalletConnectFunctions/widgets/TransactionDialogue.dart';
import 'package:securywallet/WalletConnectFunctions/widgets/session_request_view.dart';
import 'package:wallet_connect_dart_v2/core/core.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/keyvaluestorage/key_value_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'WalletConnectFunctions/models/accounts.dart';

class WalletConnectionRequest extends ChangeNotifier {
  List<Account> accounts = [];

  Web3Client _web3client = Web3Client('', http.Client());

  SignClient? signClient;

  late BuildContext context;

  UserWalletDataModel? selectedWalletData;
  String? wcURL;

  Account createAccount() {
    List<AccountDetails> generateAccountDetailsList() {
      return Eip155Data.chains.keys.map((chainId) {
        return AccountDetails(
          address: selectedWalletData!.walletAddress,
          chain: chainId,
        );
      }).toList();
    }

    return Account(
        id: 0,
        name: selectedWalletData!.walletName,
        mnemonic: selectedWalletData!.mnemonic,
        privateKey: selectedWalletData!.privateKey,
        details: generateAccountDetailsList());
  }

  addingAccount() {
    accounts = [];
    accounts.add(createAccount());
  }

  walletInitailize({UserWalletDataModel? walletData, String? wcUrll}) {
    selectedWalletData = walletData ?? selectedWalletData;
    wcURL = wcUrll;
    notifyListeners();
  }

  initializeContext(BuildContext ctxt, {bool? autoWC}) {
    context = ctxt;
    if (autoWC != null) {
      _autoWCUrl = autoWC;
    }
  }

  initialize() async {
    addingAccount();
    signClient = await SignClient.init(
        name: "KERDOS",
        projectId: "c540946772edaa2b1dfbf2c1ddd35730",
        relayUrl: "wss://relay.walletconnect.com",
        database: 'wallet.db',
        core: Core(
            projectId: "c540946772edaa2b1dfbf2c1ddd35730",
            relayUrl: "wss://relay.walletconnect.com",
            database: 'wallet.db',
            storage: KeyValueStorage(database: 'wallet.db')));
    signClient!.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      print("BBBBB$data");
      final eventData = data as SignClientEventParams<RequestSessionPropose>;
      log('SESSION_PROPOSAL: $data');

      var accountList = accounts
          .map((model) =>
              model.details.map((e) => "${e.chain}:${e.address}").toList())
          .toList();
      SessionNamespace data1 = SessionNamespace(
        accounts: accountList[0],
        methods: [
          "eth_accounts",
          "eth_requestAccounts",
          "eth_sendRawTransaction",
          "eth_sign",
          "eth_signTransaction",
          "eth_signTypedData",
          "eth_signTypedData_v3",
          "eth_signTypedData_v4",
          "eth_sendTransaction",
          "personal_sign",
          "wallet_switchEthereumChain",
          "wallet_addEthereumChain",
          "wallet_getPermissions",
          "wallet_requestPermissions",
          "wallet_registerOnboarding",
          "wallet_watchAsset",
          "wallet_scanQRCode",
          "eth_estimateGas", // Estimate gas for a transaction
          "eth_getTransactionReceipt", // Retrieve transaction receipt
          "eth_getBalance", // Get account balance
          "eth_getBlockByNumber", // Get block details by number
          "eth_getBlockByHash", // Get block details by hash
          "eth_getTransactionByHash", // Get transaction details by hash
          "eth_getTransactionCount", // Get number of transactions sent from an address
          "eth_gasPrice", // Get current gas price
          "eth_call", // Call a smart contract function
          "eth_getCode", // Get smart contract code at a specific address
          "eth_getStorageAt", // Get the value of a storage position at a given address
          "eth_getLogs", // Get logs from smart contract events
          "eth_getProof", // Get proof of account or storage
          "eth_chainId", // Get the chain ID of the connected network
        ],
        events: [
          "chainChanged",
          "accountsChanged",
          "message",
          "disconnect",
          "connect",
          "transactionConfirmed", // Custom event: Transaction confirmed
          "transactionFailed", // Custom event: Transaction failed
        ],
      );

      _onSessionRequest(
        eventData.id!,
        eventData.params!,
        data1,
      );
    });

    signClient!.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionRequest>;
      log('SESSION_REQUEST: $eventData');
      final session = signClient!.session.get(eventData.topic!);
      _web3client = Web3Client(
          Eip155Data.chains[eventData.params!.chainId]!.rpc[0], http.Client());
      switch (eventData.params!.request.method.toEip155Method()) {
        case Eip155Methods.PERSONAL_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[0];
          final address = requestParams[1];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.PERSONAL_MESSAGE,
          );
          return _onSign(
            eventData.id!,
            eventData.topic!,
            session,
            message,
          );
        case Eip155Methods.ETH_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.MESSAGE,
          );
          return _onSign(
            eventData.id!,
            eventData.topic!,
            session,
            message,
          );
        case Eip155Methods.ETH_SIGN_TYPED_DATA:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(
            eventData.id!,
            eventData.topic!,
            session,
            message,
          );
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V3:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V3,
          );
          return _onSign(
            eventData.id!,
            eventData.topic!,
            session,
            message,
          );
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V4:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(
            eventData.id!,
            eventData.topic!,
            session,
            message,
          );
        case Eip155Methods.ETH_SIGN_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSignTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSendTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_RAW_TRANSACTION:
          break;
        default:
          debugPrint('Unsupported request.');
      }
    });

    signClient!.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      log('SESSION_EVENT: $eventData');
    });
    signClient!.on(SignClientEvent.SESSION_PING.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_PING: $eventData');
    });

    signClient!.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_DELETE: $eventData');
      _onSessionClosed(
        9999,
        'Ended.',
      );
    });
  }

  bool _autoWCUrl = false;

  bool get autoWCUrl => _autoWCUrl;

  void handleNavigation() {
    if (_autoWCUrl) {
      int count = 0;
      Navigator.of(context).popUntil((route) {
        return count++ == 2;
      });
    } else {
      Navigator.pop(context);
    }
  }

  _onSessionRequest(
    int id,
    RequestSessionPropose proposal,
    SessionNamespace SessionNamespace,
  ) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => SessionRequestView(
              accounts: accounts,
              proposal: proposal,
              onApprove: (namespaces) async {
                final params = SessionApproveParams(
                  id: id,
                  namespaces: {"eip155": SessionNamespace},
                );
                //  final approved = await
                handleNavigation();
                Utils.snackBar("Connecting...");
                try {
                  signClient!.approve(params).then((value) async {
                    var v = await value.acknowledged;
                    if (v.acknowledged && context.mounted) {
                      initialize();
                      // handleNavigation();
                      Utils.snackBar("Connected to your wallet");
                    }
                  }).catchError((onError) {
                    if (context.mounted) {
                      Utils.snackBarErrorMessage(
                          "If wallet is not connected, please try again.");
                    }
                    // handleNavigation();
                  }).timeout(const Duration(seconds: 10), onTimeout: () {
                    if (context.mounted) {
                      Utils.snackBarErrorMessage(
                          "⚠️Session Timeout: Try ag️ain");
                      // handleNavigation();
                    }
                  });
                } on Exception catch (e) {
                  if (context.mounted) {
                    Utils.snackBarErrorMessage(
                        "If wallet is not connected, please try again.");
                  }
                  // handleNavigation();
                  throw e;
                }
                // await approved.acknowledged;
              },
              onReject: () {
                signClient!.reject(SessionRejectParams(
                  id: id,
                  reason: getSdkError(SdkErrorKey.USER_DISCONNECTED),
                ));
                Navigator.pop(context);
              },
            )));
  }

  bool sessionClosePopup = true;

  setSessionClosePopup(bool value) {
    sessionClosePopup = value;
    notifyListeners();
  }

  _onSessionClosed(
    int? code,
    String? reason,
  ) {
    if (sessionClosePopup) {
      setSessionClosePopup(false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return PopScope(
            canPop: false,
            child: SimpleDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: AppText("Session Ended",
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB982FF),
                  textAlign: TextAlign.center,
                  fontSize: 20.0),
              // contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AppText('Your session is ended',
                          fontSize: 18.0,
                          color: Theme.of(context).colorScheme.surfaceBright),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFB982FF)),
                      onPressed: () {
                        setSessionClosePopup(true);
                        Navigator.pop(context);
                      },
                      child: AppText('   Close   '),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );
    }
  }

  _onSignTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    _onTransaction(
      id: id,
      chainId: chainId,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: 'Sign Transaction',
      onConfirm: () async {
        final account = _getAccountFromAddr(ethereumTransaction.from);
        final privateKey = HDKeyUtils.getPrivateKey(account.mnemonic);
        final creds = EthPrivateKey.fromHex(privateKey);
        final signedTx = await _web3client.signTransaction(
          creds,
          _wcEthTxToWeb3Tx(ethereumTransaction),
          chainId: chainId,
        );
        final signedTxHex = bytesToHex(signedTx, include0x: true);
        signClient!
            .respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcResult<String>(
              id: id,
              result: signedTxHex,
            ),
          ),
        )
            .then((value) {
          setTransactionPopup(true);
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      },
      onReject: () {
        signClient!
            .respond(SessionRespondParams(
          topic: session.topic,
          response: JsonRpcError(id: id),
        ))
            .then((value) {
          setTransactionPopup(true);
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      },
    );
  }

  _onSendTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    _onTransaction(
      id: id,
      chainId: chainId,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: 'Send Transaction',
      onConfirm: () async {
        // setLoading(true);
        final account = _getAccountFromAddr(ethereumTransaction.from);
        final privateKey = HDKeyUtils.getPrivateKey(account.mnemonic);
        final creds = EthPrivateKey.fromHex(privateKey);
        Navigator.pop(context);
        Utils.snackBar("Transaction processing...");
        final txHash = await _web3client
            .sendTransaction(
          creds,
          _wcEthTxToWeb3Tx(ethereumTransaction),
          chainId: chainId,
        )
            .catchError((e) {
          if (context.mounted) {
            Utils.snackBarErrorMessage("❗️Transaction failed. Try ag️ain");
          }
          return e;
        });
        // debugPrint('txHash $txHash');
        signClient!
            .respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcResult<String>(
              id: id,
              result: txHash,
            ),
          ),
        )
            .then((value) {
          if (context.mounted) {
            // CustomSnackBar().showSnakbar(
            //     context, "Transaction success...", SnackbarType.positive);
          }
          // setLoading(false);
        }).catchError((e) {
          if (context.mounted) {
            Utils.snackBarErrorMessage("❗️Transaction failed. Try ag️ain");
          }
        });
        if (context.mounted) {
          setTransactionPopup(true);
          // Navigator.pop(context);
        }
      },
      onReject: () {
        signClient!
            .respond(SessionRespondParams(
          topic: session.topic,
          response: JsonRpcError(id: id),
        ))
            .then((value) {
          // setLoading(false);
          if (context.mounted) {
            setTransactionPopup(true);
            Navigator.pop(context);
          }
        }).catchError((e) {
          if (context.mounted) {
            setTransactionPopup(true);
            Navigator.pop(context);
          }
        });
      },
    );
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  setLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  bool transactionPopup = true;

  setTransactionPopup(bool value) {
    transactionPopup = value;
    notifyListeners();
  }

  _onTransaction({
    required int id,
    required int chainId,
    required SessionStruct session,
    required WCEthereumTransaction ethereumTransaction,
    required String title,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) async {
    BigInt gas = BigInt.parse(ethereumTransaction.gasLimit ?? "0");
    BigInt value = BigInt.parse(ethereumTransaction.value ?? '0');
    print(" trans11... ${ethereumTransaction.gasPrice}");
    print(" trans11... ${ethereumTransaction.gasLimit}");
    print(" trans11... ${ethereumTransaction.gas}");
    print(" trans11... ${ethereumTransaction.maxFeePerGas}");
    EtherAmount gasPrice = await _web3client.getGasPrice();
    var transactionFees = gas * gasPrice.getInWei;
    print(" trans... $transactionFees");
    if (context.mounted &&
        ethereumTransaction.from == selectedWalletData!.walletAddress &&
        transactionPopup) {
      setTransactionPopup(false);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => TransactionDialog(
                session: session,
                chainId: chainId,
                ethereumTransaction: ethereumTransaction,
                title: title,
                transactionFees: transactionFees,
                value: value,
                onConfirm: onConfirm,
                onReject: onReject,
              )));
    }
  }

  _onSign(int id, String topic, SessionStruct session,
      WCEthereumSignMessage message) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => SignMessageView(
              session: session,
              title: "Sign Message",
              message: message,
              onConfirm: () async {
                final account = _getAccountFromAddr(message.address);
                final privateKey = HDKeyUtils.getPrivateKey(account.mnemonic);
                final creds = EthPrivateKey.fromHex(privateKey);
                String signedDataHex;
                if (message.type == WCSignType.TYPED_MESSAGE_V1) {
                  signedDataHex = EthSigUtil.signTypedData(
                    privateKey: privateKey,
                    jsonData: message.data,
                    version: TypedDataVersion.V1,
                  );
                } else if (message.type == WCSignType.TYPED_MESSAGE_V3) {
                  signedDataHex = EthSigUtil.signTypedData(
                    privateKey: privateKey,
                    jsonData: message.data,
                    version: TypedDataVersion.V3,
                  );
                } else if (message.type == WCSignType.TYPED_MESSAGE_V4) {
                  signedDataHex = EthSigUtil.signTypedData(
                    privateKey: privateKey,
                    jsonData: message.data,
                    version: TypedDataVersion.V4,
                  );
                } else {
                  final encodedMessage = hexToBytes(message.data);
                  final signedData =
                      await creds.signPersonalMessage(encodedMessage);
                  signedDataHex = bytesToHex(signedData, include0x: true);
                }
                signClient!
                    .respond(
                  SessionRespondParams(
                    topic: topic,
                    response: JsonRpcResult<String>(
                      id: id,
                      result: signedDataHex,
                    ),
                  ),
                )
                    .then((value) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              onReject: () {
                signClient!
                    .respond(SessionRespondParams(
                  topic: session.topic,
                  response: JsonRpcError(id: id),
                ))
                    .then((value) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
            )));
  }

  Account _getAccountFromAddr(String address) {
    return accounts
        .where((element) => element.details.any((element) =>
            element.address.toLowerCase() == address.toLowerCase()))
        .first;
  }

  Transaction _wcEthTxToWeb3Tx(WCEthereumTransaction ethereumTransaction) {
    return Transaction(
      from: EthereumAddress.fromHex(ethereumTransaction.from),
      to: EthereumAddress.fromHex(ethereumTransaction.to!),
      maxGas: ethereumTransaction.gasLimit != null
          ? int.tryParse(ethereumTransaction.gasLimit!)
          : null,
      gasPrice: ethereumTransaction.gasPrice != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.gasPrice!))
          : null,
      value: EtherAmount.inWei(BigInt.parse(ethereumTransaction.value ?? '0')),
      data: hexToBytes(ethereumTransaction.data!),
      nonce: ethereumTransaction.nonce != null
          ? int.tryParse(ethereumTransaction.nonce!)
          : null,
      maxFeePerGas: ethereumTransaction.maxFeePerGas != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.maxFeePerGas!))
          : null,
      maxPriorityFeePerGas: ethereumTransaction.maxPriorityFeePerGas != null
          ? EtherAmount.inWei(
              BigInt.parse(ethereumTransaction.maxPriorityFeePerGas!))
          : null,
    );
  }
}
