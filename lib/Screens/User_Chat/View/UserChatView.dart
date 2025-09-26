import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'package:provider/provider.dart';
import 'package:get/get_core/get_core.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Crypto_Utils/ColorHandlers/AppColors.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/User_Chat/Chat_Link_Text/LinkText.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:securywallet/encrypt&decrypt_service.dart';

class ChatScreenView extends StatefulWidget {
  final String walletAddress;
  var item;
  final String docId;
  final bool isChatExist;
  ChatScreenView(
      {Key? key,
      required this.walletAddress,
      required this.item,
      required this.docId,
      required this.isChatExist})
      : super(key: key);
  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final TextEditingController chatController = TextEditingController();
  bool showEmojiPicker = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  LocalStorageService localStorageService = LocalStorageService();
  late bool isChatExist;
  String messageText = "";
  final ScrollController _scrollController = ScrollController();
  String? previousDateString;
  var myProfile;
  var chatData;

  @override
  void initState() {
    // TODO: implement initState
    isChatExist = widget.isChatExist;
    Future.delayed(Duration(milliseconds: 500), () async {
      unreadCountClear();
      var chatDoc = await firestore.collection('Chat').doc(widget.docId).get();
      setState(() {
        chatData = chatDoc.data();
      });
    });
    super.initState();
  }

  unreadCountClear() async {
    final profile = await firestore
        .collection('Users')
        .doc(localStorageService.activeWalletData!.walletAddress)
        .get();
    myProfile = profile.data();
    var unreadCount = myProfile!['unreadCount'];
    if (unreadCount != null) {
      if (unreadCount[widget.item["walletAddress"]] != null) {
        unreadCount[widget.item["walletAddress"]] = null;
        await firestore
            .collection('Users')
            .doc(localStorageService.activeWalletData!.walletAddress)
            .update({"unreadCount": unreadCount});
        print("count reset");
      }
    }
  }

  void sendMessageToFirestore() {
    if (isChatExist == false) {
      firestore.collection('Chat').doc(widget.docId).set({
        "walletAddress1": localStorageService.activeWalletData!.walletAddress,
        "walletAddress2": widget.item["walletAddress"],
        "timestamp": FieldValue.serverTimestamp()
      });
    }

    firestore
        .collection('Chat')
        .doc(widget.docId)
        .update({"timestamp": FieldValue.serverTimestamp()});

    firestore.collection('Chat').doc(widget.docId).collection('messages').add({
      'text': encryptAESCryptoJS(messageText),
      'sender': localStorageService.activeWalletData!.walletAddress,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) async {
      chatController.clear();
      await msgCountUpdate();
      setState(() {
        messageText = "";
        isChatExist = true;
      });
    }).catchError((error) {
      print('Error sending message: $error'); // Handle any errors
    });
  }

  Future msgCountUpdate() async {
    final userProfile = await firestore
        .collection('Users')
        .doc(widget.item["walletAddress"])
        .get();

    // Check if 'unreadCount' field exists in the document
    if (userProfile.exists && userProfile.data() != null) {
      var unreadCount = userProfile.data()!['unreadCount'];

      // Check if 'unreadCount' is not null and a map
      if (unreadCount != null && unreadCount is Map) {
        // Check if the current wallet address exists in the 'unreadCount' map
        if (unreadCount[localStorageService.activeWalletData!.walletAddress] !=
            null) {
          unreadCount[localStorageService.activeWalletData!.walletAddress] =
              unreadCount[localStorageService.activeWalletData!.walletAddress] +
                  1;
          await firestore
              .collection('Users')
              .doc(widget.item["walletAddress"])
              .update({"unreadCount": unreadCount});
        } else if (unreadCount[
                localStorageService.activeWalletData!.walletAddress] ==
            null) {
          // If wallet address doesn't exist in 'unreadCount' map, initialize it with 1
          unreadCount[localStorageService.activeWalletData!.walletAddress] = 1;
          await firestore
              .collection('Users')
              .doc(widget.item["walletAddress"])
              .update({"unreadCount": unreadCount});
        } else {
          // If wallet address doesn't exist in 'unreadCount' map, initialize it with 1
          unreadCount
              .addAll({localStorageService.activeWalletData!.walletAddress: 1});
          await firestore
              .collection('Users')
              .doc(widget.item["walletAddress"])
              .update({"unreadCount": unreadCount});
        }
      } else {
        // If 'unreadCount' doesn't exist or is null, initialize it as a new map
        await firestore
            .collection('Users')
            .doc(widget.item["walletAddress"])
            .update({
          "unreadCount": {
            localStorageService.activeWalletData!.walletAddress: 1
          }
        });
      }
    } else {
      // Handle case when document does not exist or no data
      await firestore
          .collection('Users')
          .doc(widget.item["walletAddress"])
          .update({
        "unreadCount": {localStorageService.activeWalletData!.walletAddress: 1}
      });
    }
  }

  int oldCount = 0;
  int newCount = 1;

  WalletConnectionRequest walletSessionRequest = WalletConnectionRequest();
  bool hasMessages = true;

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletSessionRequest = context.watch<WalletConnectionRequest>();
    walletSessionRequest.initializeContext(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (v) {
        unreadCountClear();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors().bottomColorDark.withOpacity(0.8),
          leading: InkWell(
            onTap: () {
              unreadCountClear();
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
          ),
          centerTitle: true,
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF202832),
                    child: Text(
                      widget.item["userName"].toString().characters.first,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green, // Green color for the border
                            width: 2, // Width of the border
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    widget.item['userName'],
                    fontFamily: 'LexendDeca',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  SizedBox(
                    width: 150,
                    child: AppText(
                      CommonCalculationFunctions.maskWalletAddress(
                          widget.item['walletAddress']),
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: hasMessages
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: PopupMenuButton<String>(
                      position: PopupMenuPosition.under,
                      color: Theme.of(context).primaryColorLight,
                      onSelected: (value) async {
                        if (value == 'Block') {
                          await firestore
                              .collection('Chat')
                              .doc(widget.docId)
                              .update({
                            'blocked': true,
                            'blockedBy_${localStorageService.activeWalletData?.walletAddress}':
                                true
                          });
                          var chatDoc = await firestore
                              .collection('Chat')
                              .doc(widget.docId)
                              .get();
                          setState(() {
                            chatData = chatDoc.data();
                          });
                        } else if (value == 'UnBlock') {
                          if (chatData[
                                      'blockedBy_${widget.item["walletAddress"]}'] ==
                                  null ||
                              chatData[
                                      'blockedBy_${widget.item["walletAddress"]}'] ==
                                  false) {
                            await firestore
                                .collection('Chat')
                                .doc(widget.docId)
                                .update({
                              'blocked': false,
                              'blockedBy_${localStorageService.activeWalletData?.walletAddress}':
                                  false
                            });
                          } else {
                            await firestore
                                .collection('Chat')
                                .doc(widget.docId)
                                .update({
                              'blocked': true,
                              'blockedBy_${localStorageService.activeWalletData?.walletAddress}':
                                  false
                            });
                          }
                          var chatDoc = await firestore
                              .collection('Chat')
                              .doc(widget.docId)
                              .get();
                          setState(() {
                            chatData = chatDoc.data();
                          });
                        } else if (value == 'Copy') {
                          Clipboard.setData(ClipboardData(
                              text: widget.item['walletAddress']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Wallet address copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        bool isBlocked = chatData[
                                'blockedBy_${localStorageService.activeWalletData?.walletAddress}'] ??
                            false;
                        String blockOption = isBlocked ? 'UnBlock' : 'Block';

                        return [
                          PopupMenuItem<String>(
                            value: blockOption,
                            child: Row(
                              children: [
                                Icon(
                                  blockOption == 'Block'
                                      ? Icons.block
                                      : Icons.lock_open_rounded,
                                  color: blockOption == 'Block'
                                      ? appColors.red
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceBright,
                                  size: 18,
                                ),
                                AppText(' $blockOption',
                                    color: blockOption == 'Block'
                                        ? appColors.red
                                        : null),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Copy',
                            child: Row(
                              children: [
                                Icon(Icons.copy,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                    size: 18),
                                AppText(' Copy'),
                              ],
                            ),
                          ),
                        ];
                      },
                      icon: Icon(Icons.more_vert_outlined),
                    ),
                  ),
                ]
              : null,
        ),
        body: GestureDetector(
          onTap: () {
            // Hide keyboard and emoji picker when tapped outside of text field or emoji picker
            FocusScope.of(context).unfocus();
            setState(() {
              showEmojiPicker = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('Chat')
                        .doc(widget.docId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.purpleAccent[100],
                        ));
                      } else {
                        final docs = snapshot.data!.docs;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (hasMessages != docs.isNotEmpty) {
                            setState(() {
                              hasMessages = docs.isNotEmpty;
                            });
                          }
                          unreadCountClear();
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                          );
                        });
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var message = snapshot.data!.docs[index];
                            bool isSender = message['sender'] ==
                                localStorageService
                                    .activeWalletData!.walletAddress;
                            // DateTime messageTime = message['timestamp'].toDate();
                            DateTime messageTime = message['timestamp'] != null
                                ? message['timestamp'].toDate()
                                : DateTime.now();

                            DateTime now = DateTime.now();
                            String dateString = '';

                            if (now.year == messageTime.year &&
                                now.month == messageTime.month &&
                                now.day == messageTime.day) {
                              // Message was sent today
                              dateString = 'Today';
                            } else if (now.year == messageTime.year &&
                                now.month == messageTime.month &&
                                now.day - messageTime.day == 1) {
                              // Message was sent yesterday
                              dateString = 'Yesterday';
                            } else {
                              // Message was sent on a different day, show the actual date
                              dateString =
                                  '${messageTime.day}/${messageTime.month}/${messageTime.year}';
                            }
                            bool showDateHeader =
                                index == 0 || dateString != previousDateString;

                            // Store the current date to compare with the next message's date
                            previousDateString = dateString;
                            return Column(
                              children: [
                                if (showDateHeader)
                                  index == 0
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 10, right: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                      .bottomAppBarTheme
                                                      .color ??
                                                  Color(0xFFD4D4D4),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock,
                                                    color: Color(0xFFFCB500),
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig.width(
                                                        context, 3),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        AppText(
                                                          "Messages is end-to-end encrypted. No one outside of this chat, not even NVXO WALLET,"
                                                          " can read or listen to them.",
                                                          fontFamily:
                                                              'LexendDeca',
                                                          overflow:
                                                              TextOverflow.clip,
                                                          textAlign:
                                                              TextAlign.justify,
                                                          color:
                                                              Color(0xFFFCB500),
                                                          fontSize: 11,
                                                        ),
                                                        // AppText(
                                                        //   "No one outside of this chat , not even KERDOS,",
                                                        //   fontFamily: 'LexendDeca',
                                                        //   color: Color(0xFFFCB500),
                                                        //   fontSize: 11,
                                                        // ),
                                                        // AppText(
                                                        //   "can read or listen to them.",
                                                        //   fontFamily: 'LexendDeca',
                                                        //   color: Color(0xFFFCB500),
                                                        //   fontSize: 11,
                                                        // ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                if (showDateHeader)
                                  Text(
                                    dateString,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                Align(
                                  alignment: isSender
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: isSender
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          isSender
                                              ? SizedBox()
                                              : CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      Color(0xFF202832),
                                                  child: Text(
                                                    widget.item["userName"]
                                                        .toString()
                                                        .characters
                                                        .first,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: SizeConfig.width(
                                                      context,
                                                      70), // Adjust the maximum width based on the length of the text
                                                ),
                                                margin: EdgeInsets.all(8.0),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  // color: isSender ? Colors.blue : Colors.grey,

                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: isSender
                                                        ? Radius.circular(30.0)
                                                        : Radius.circular(30.0),
                                                    topRight: isSender
                                                        ? Radius.circular(30.0)
                                                        : Radius.circular(30.0),
                                                    bottomLeft: isSender
                                                        ? Radius.circular(30.0)
                                                        : Radius.circular(0.0),
                                                    bottomRight: isSender
                                                        ? Radius.circular(0.0)
                                                        : Radius.circular(30.0),
                                                  ),
                                                  color: isSender
                                                      ? Color(0xFFE59DFD)
                                                      : Color(0xFF800080),
                                                ),
                                                child: ChatLinkText(
                                                  text: decryptAESCryptoJS(
                                                      message['text']),
                                                ),
                                              ),
                                              Align(
                                                alignment: isSender
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                child: Text(
                                                  message['timestamp'] != null
                                                      ? CommonCalculationFunctions
                                                          .formatTime(message[
                                                                  'timestamp']
                                                              .toDate()) // Format the timestamp
                                                      : '',
                                                  style: TextStyle(
                                                    fontFamily: 'LexendDeca',
                                                    fontWeight: FontWeight.w300,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceBright,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          isSender
                                              ? CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      Color(0xFF202832),
                                                  child: Text(
                                                    localStorageService
                                                        .activeWalletData!
                                                        .walletName
                                                        .characters
                                                        .first,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                chatData != null &&
                        chatData['blocked'] != null &&
                        chatData['blocked']
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                            8, 8, 8, Platform.isIOS ? 25 : 8),
                        child: AppText(
                          chatData['blockedBy_${localStorageService.activeWalletData?.walletAddress}'] !=
                                      null &&
                                  chatData[
                                          'blockedBy_${localStorageService.activeWalletData?.walletAddress}'] ==
                                      true
                              ? "You have blocked this user. To continue the chat, you need to unblock them."
                              : "This user has blocked you.",
                          color: appColors.bottomColorDark,
                          overflow: TextOverflow.clip,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Theme.of(context).dividerColor,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          showEmojiPicker = !showEmojiPicker;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.emoji_emotions_outlined,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        // readOnly: chatData == null,
                                        controller: chatController,
                                        onTap: () {
                                          setState(() {
                                            showEmojiPicker = false;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            messageText = value;
                                          });
                                        },
                                        style: TextStyle(
                                          fontFamily: 'LexendDeca',
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          fontSize: 13,
                                        ),
                                        maxLines:
                                            null, // Expands vertically based on content
                                        minLines:
                                            1, // Minimum number of lines the TextField will have initially
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        decoration: InputDecoration(
                                          hintText: 'Type a message here ...',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            decorationThickness: 0.0,
                                            fontFamily: 'LexendDeca',
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /*  Expanded(
                                      child: TextField(
                                        readOnly: chatData == null,
                                        controller: chatController,
                                        onTap: () {
                                          setState(() {
                                            showEmojiPicker = false;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            messageText = value;
                                          });
                                        },
                                        style: TextStyle(
                                          fontFamily: 'LexendDeca',
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                            hintText: 'Type a message here ...',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontFamily: 'LexendDeca',
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              fontSize: 13,
                                            )),
                                      ),
                                    ),*/
                                    GestureDetector(
                                      onTap: () {
                                        if (chatController.text.isNotEmpty) {
                                          sendMessageToFirestore();
                                        } else {
                                          Get.snackbar(
                                              "Text must be entered", "",
                                              snackPosition: SnackPosition.TOP,
                                              duration:
                                                  const Duration(seconds: 2),
                                              backgroundColor:
                                                  Color(0xFFcc0000),
                                              margin: const EdgeInsets.all(10),
                                              colorText: Colors.white);

                                          // customSnackBar.showSnakbar(context,
                                          //     "Please enter text", SnackbarType.negative);
                                        }
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (messageText.isNotEmpty ||
                                                    messageText != "")
                                                ? Color(0xFF800080)
                                                : Colors.grey,
                                          ),
                                          child: Icon(
                                            Icons.send,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                Visibility(
                  visible: showEmojiPicker,
                  child: Container(
                    color: Colors.white,
                    height: 256,
                    child: EmojiPicker(
                      textEditingController: chatController,
                      onEmojiSelected: (emoji, category) {
                        setState(() {
                          messageText = chatController.text;
                        });
                        FocusScope.of(context).unfocus();
                      },
                      config: Config(
                          height: 28 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.2
                                  : 1.0),
                          checkPlatformCompatibility: true,
                          emojiTextStyle: TextStyle(color: Color(0xFF800080))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
