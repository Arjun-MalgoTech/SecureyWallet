import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:get/get_core/get_core.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Common_Calculation_Function.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/ColorHandlers/AppColors.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/User_Chat/Chat_Link_Text/LinkText.dart';
import 'package:securywallet/Screens/User_Chat/GroupChat/AddMemberToGroup.dart';
import 'package:securywallet/Screens/User_Chat/GroupChat/GroupInfo.dart';
import 'package:securywallet/Screens/User_Chat/GroupChat/RemoveMemberToGroup.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/Wallet_Session_Request.dart';
import 'package:securywallet/encrypt&decrypt_service.dart';

class GroupChatScreen extends StatefulWidget {
  final String walletAddress;
  var item;
  final String docId;
  List recentChats;
  GroupChatScreen(
      {Key? key,
      required this.walletAddress,
      required this.item,
      required this.docId,
      required this.recentChats})
      : super(key: key);
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController chatController = TextEditingController();
  bool showEmojiPicker = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  LocalStorageService localStorageService = LocalStorageService();
  String messageText = "";
  final ScrollController _scrollController = ScrollController();
  String? previousDateString;
  var myProfile;
  var chatData;

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(milliseconds: 500), () async {
      var chatDoc =
          await firestore.collection('groupChat').doc(widget.docId).get();
      setState(() {
        chatData = chatDoc.data();
      });
      resetUnread();
    });
    super.initState();
  }

  void resetUnread() async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('groupChat').doc(widget.docId).get();
    List<dynamic> memberList = documentSnapshot.get('memberList');
    List<Map<String, dynamic>> updatedList = memberList.map((member) {
      Map<String, dynamic> updatedMember = Map<String, dynamic>.from(member);
      if (updatedMember["walletAddress"] ==
          localStorageService.activeWalletData!.walletAddress) {
        updatedMember['unread'] = false;
      }
      return updatedMember;
    }).toList();
    await firestore
        .collection('groupChat')
        .doc(widget.docId)
        .update({'memberList': updatedList});
  }

  void sendMessageToFirestore() async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('groupChat').doc(widget.docId).get();
    List<dynamic> memberList = documentSnapshot.get('memberList');
    await firestore
        .collection('groupChat')
        .doc(widget.docId)
        .update({"timestamp": FieldValue.serverTimestamp()});
    List<Map<String, dynamic>> updatedList = memberList.map((member) {
      Map<String, dynamic> updatedMember = Map<String, dynamic>.from(member);
      if (updatedMember["walletAddress"] ==
          localStorageService.activeWalletData!.walletAddress) {
        updatedMember['unread'] = false;
      } else {
        updatedMember['unread'] = true;
      }
      return updatedMember;
    }).toList();

    await firestore
        .collection('groupChat')
        .doc(widget.docId)
        .collection('messages')
        .add({
      'text': encryptAESCryptoJS(messageText),
      'sender': localStorageService.activeWalletData!.walletAddress,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': localStorageService.activeWalletData!.walletName
    }).then((value) async {
      chatController.clear();
      // await msgCountUpdate();
      setState(() {
        messageText = "";
      });
    }).catchError((error) {
      print('Error sending message: $error'); // Handle any errors
    });
    await firestore
        .collection('groupChat')
        .doc(widget.docId)
        .update({'memberList': updatedList});
  }

  int oldCount = 0;
  int newCount = 1;

  List<PopupMenuEntry<String>> adminMenu(context) {
    return [
      PopupMenuItem<String>(
        value: 'groupInfo',
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.surfaceBright),
            AppText('  Group Info'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'addMember',
        child: Row(
          children: [
            Icon(Icons.group_add,
                color: Theme.of(context).colorScheme.surfaceBright),
            AppText('  Add Member'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'removeMember',
        child: Row(
          children: [
            Icon(Icons.group_remove,
                color: Theme.of(context).colorScheme.surfaceBright),
            AppText('  Remove Member'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'exitGroup',
        child: Row(
          children: [
            Icon(Icons.login_outlined, color: Colors.red),
            AppText('  Exit Group', color: Colors.red),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'deleteGroup',
        child: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            AppText('  Delete Group', color: Colors.red),
          ],
        ),
      ),
    ];
  }

  List<PopupMenuEntry<String>> memberMenu(context) {
    return [
      PopupMenuItem<String>(
        value: 'groupInfo',
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.surfaceBright),
            AppText('  Group Info'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'exitGroup',
        child: Row(
          children: [
            Icon(Icons.login_outlined, color: Colors.red),
            AppText('  Exit Group', color: Colors.red),
          ],
        ),
      ),
    ];
  }

  WalletConnectionRequest walletSessionRequest = WalletConnectionRequest();

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletSessionRequest = context.watch<WalletConnectionRequest>();
    walletSessionRequest.initializeContext(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (v) {
        // unreadCountClear();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors().bottomColorDark.withOpacity(0.8),
          leading: InkWell(
            onTap: () {
              // unreadCountClear();
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
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF202832),
                child: Icon(Icons.groups, color: Colors.white),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    widget.item['groupName'],

                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  SizedBox(
                    width: 150,
                    child: AppText(
                      "Group Chat",

                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).colorScheme.surfaceBright),
                onSelected: (v) {
                  if (v.contains("groupInfo")) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => GroupInfo(docId: widget.docId)));
                  } else if (v.contains("addMember")) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) =>
                            AddMemberToGroup(docId: widget.docId)));
                  } else if (v.contains("removeMember")) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) =>
                            RemoveMemberToGroup(docId: widget.docId)));
                  } else if (v.contains("deleteGroup")) {
                    groupDeleteDialog(context);
                  } else if (v.contains("exitGroup")) {
                    if (widget.item["adminList"][0] ==
                        localStorageService.activeWalletData!.walletAddress) {
                      groupExitAdminDialog(context);
                    } else {
                      groupExitDialog(context);
                    }
                  }
                },
                color: Colors.deepPurple.shade700,
                itemBuilder: (BuildContext context) => widget.item["adminList"]
                            [0] ==
                        localStorageService.activeWalletData!.walletAddress
                    ? adminMenu(context)
                    : memberMenu(context),
              ),
            ),
          ],
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
                        .collection('groupChat')
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
                        // Delay the scroll to the end after the ListView is built
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // unreadCountClear();
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
                                                          "Messages is end-to-end encrypted. No one outside of this chat, not even NV WALLET,"
                                                          " can read or listen to them.",

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
                                                    message['userName']
                                                        .toString()
                                                        .characters
                                                        .first,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                          Column(
                                            crossAxisAlignment: isSender
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: SizeConfig.width(
                                                      context,
                                                      70), // Adjust the maximum width based on the length of the text
                                                ),
                                                margin: EdgeInsets.all(8.0),
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  // color: isSender ? Colors.blue : Colors.grey,

                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: isSender
                                                        ? Radius.circular(15.0)
                                                        : Radius.circular(15.0),
                                                    topRight: isSender
                                                        ? Radius.circular(15.0)
                                                        : Radius.circular(15.0),
                                                    bottomLeft: isSender
                                                        ? Radius.circular(15.0)
                                                        : Radius.circular(0.0),
                                                    bottomRight: isSender
                                                        ? Radius.circular(0.0)
                                                        : Radius.circular(15.0),
                                                  ),
                                                  color: isSender
                                                      ? Color(0xFFE59DFD)
                                                      : Color(0xFF800080),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    isSender
                                                        ? SizedBox()
                                                        : Text(
                                                            "${message['userName']} - ${CommonCalculationFunctions.maskWalletAddress(message['sender'])}",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LexendDeca',
                                                                fontWeight: FontWeight
                                                                    .w400,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .surfaceBright,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationThickness:
                                                                    2,
                                                                decorationColor:
                                                                    Colors
                                                                        .white),
                                                          ),
                                                    ChatLinkText(
                                                      text: decryptAESCryptoJS(
                                                          message['text']),
                                                    ),
                                                  ],
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

  groupDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.deepPurpleAccent,
              titlePadding: EdgeInsets.only(top: 8),
              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              title: Center(
                child: AppText(
                  "Delete Group",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: SizeConfig.height(context, 1)),
                  AppText(
                    "Are you sure do you want to delete this group?",
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: SizeConfig.height(context, 1)),
                  AppText(
                    "Note: All group chats will be deleted permanently.",
                    overflow: TextOverflow.visible,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.only(bottom: 8, right: 8),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);

                          try {
                            FirebaseFirestore firestore =
                                FirebaseFirestore.instance;
                            await firestore
                                .collection('groupChat')
                                .doc(widget.docId)
                                .delete();
                            var snapshot = await firestore
                                .collection('groupChat')
                                .doc(widget.docId)
                                .collection("messages")
                                .get();
                            for (final doc in snapshot.docs) {
                              await doc.reference.delete();
                            }
                            int chatIndex = widget.recentChats.indexWhere(
                                (v) => v['groupID'] == widget.docId);
                            if (chatIndex >= 0) {
                              widget.recentChats.removeAt(chatIndex);
                              await VaultStorageService().chatRemove(
                                  "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
                              await VaultStorageService().chatWrite(
                                  "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
                                  widget.recentChats);
                            }
                            Utils.snackBar("Group is deleted successfully");

                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            print("Error deleting group chat: $e");
                            setState(() => isDeleting = false); // Allow retry
                          }
                        },
                  child: AppText(
                    "Delete",
                    fontWeight: FontWeight.bold,
                    color: isDeleting
                        ? Colors.redAccent.shade100
                        : Colors.redAccent,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: AppText("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  groupExitDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.deepPurpleAccent,
              titlePadding: EdgeInsets.only(top: 8),
              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              title: Center(
                child: AppText(
                  "Exit Group",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: SizeConfig.height(context, 1)),
                  AppText(
                    "Are you sure do you want to exit this group?",
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.only(bottom: 8, right: 8),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);

                          try {
                            FirebaseFirestore firestore =
                                FirebaseFirestore.instance;

                            var snapshot = await firestore
                                .collection('groupChat')
                                .doc(widget.docId)
                                .get();
                            List memberList = snapshot.data()!["memberList"];
                            int index = memberList.indexWhere((v) =>
                                v["walletAddress"] ==
                                localStorageService
                                    .activeWalletData!.walletAddress);
                            memberList.removeAt(index);
                            print("memberList:$memberList");
                            await firestore
                                .collection('groupChat')
                                .doc(widget.docId)
                                .update({"memberList": memberList});
                            int chatIndex = widget.recentChats.indexWhere(
                                (v) => v['groupID'] == widget.docId);
                            if (chatIndex >= 0) {
                              widget.recentChats.removeAt(chatIndex);
                              await VaultStorageService().chatRemove(
                                  "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
                              await VaultStorageService().chatWrite(
                                  "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
                                  widget.recentChats);
                            }
                            Utils.snackBar("You're left in this group");

                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            print("Error deleting group chat: $e");
                            setState(() => isDeleting = false); // Allow retry
                          }
                        },
                  child: AppText(
                    "Exit",
                    fontWeight: FontWeight.bold,
                    color: isDeleting
                        ? Colors.redAccent.shade100
                        : Colors.redAccent,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: AppText("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  groupExitAdminDialog(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var selectedAdmin;

    var snapshot =
        await firestore.collection('groupChat').doc(widget.docId).get();
    List memberList = snapshot.data()!["memberList"];
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.deepPurpleAccent,
              titlePadding: EdgeInsets.only(top: 8),
              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              title: Center(
                child: AppText(
                  "Exit Group",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    SizedBox(height: SizeConfig.height(context, 1)),
                    AppText(
                      "Are you sure do you want to exit this group?",
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: SizeConfig.height(context, 1)),
                    memberList.length == 1
                        ? SizedBox()
                        : Column(
                            children: [
                              AppText(
                                "You are currently the admin, so you can choose a new admin from your group members.",
                                overflow: TextOverflow.visible,
                              ),
                              ...memberList.map((data) {
                                return data['walletAddress'] ==
                                        localStorageService
                                            .activeWalletData!.walletAddress
                                    ? SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: Colors.white30
                                                  .withOpacity(0.1)),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(4),
                                            leading: Radio(
                                                value: data,
                                                activeColor: Colors.white,
                                                fillColor:
                                                    WidgetStateProperty.all(
                                                        Colors.white),
                                                groupValue: selectedAdmin,
                                                onChanged: (v) {
                                                  setState(() {
                                                    selectedAdmin = data;
                                                  });
                                                }),
                                            title: AppText(
                                              data['userName'],
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15,
                                            ),
                                            subtitle: AppText(
                                              data['walletAddress']!,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      );
                              }),
                            ],
                          ),
                  ],
                ),
              ),
              actionsPadding: EdgeInsets.only(bottom: 8, right: 8),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          if (memberList.length == 1) {
                            try {
                              await firestore
                                  .collection('groupChat')
                                  .doc(widget.docId)
                                  .delete();
                              var messages = await firestore
                                  .collection('groupChat')
                                  .doc(widget.docId)
                                  .collection("messages")
                                  .get();
                              for (final doc in messages.docs) {
                                await doc.reference.delete();
                              }
                              int chatIndex = widget.recentChats.indexWhere(
                                  (v) => v['groupID'] == widget.docId);
                              if (chatIndex >= 0) {
                                widget.recentChats.removeAt(chatIndex);
                                await VaultStorageService().chatRemove(
                                    "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
                                await VaultStorageService().chatWrite(
                                    "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
                                    widget.recentChats);
                              }
                              Utils.snackBar("You're left in this group");

                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) Navigator.pop(context, true);
                            } catch (e) {
                              print("Error deleting group chat: $e");
                              setState(() => isDeleting = false); // Allow retry
                            }
                          } else if (selectedAdmin == null) {
                            Utils.snackBarErrorMessage(
                                "Please select any one member as admin role");
                          } else {
                            setState(() => isDeleting = true);

                            try {
                              int index = memberList.indexWhere((v) =>
                                  v["walletAddress"] ==
                                  localStorageService
                                      .activeWalletData!.walletAddress);
                              memberList.removeAt(index);
                              print("memberList:$memberList");
                              await firestore
                                  .collection('groupChat')
                                  .doc(widget.docId)
                                  .update({
                                "adminList": [selectedAdmin["walletAddress"]]
                              });
                              await firestore
                                  .collection('groupChat')
                                  .doc(widget.docId)
                                  .update({"memberList": memberList});
                              int chatIndex = widget.recentChats.indexWhere(
                                  (v) => v['groupID'] == widget.docId);
                              if (chatIndex >= 0) {
                                widget.recentChats.removeAt(chatIndex);
                                await VaultStorageService().chatRemove(
                                    "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
                                await VaultStorageService().chatWrite(
                                    "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
                                    widget.recentChats);
                              }
                              Utils.snackBar("You're left in this group");

                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) Navigator.pop(context, true);
                            } catch (e) {
                              print("Error deleting group chat: $e");
                              setState(() => isDeleting = false); // Allow retry
                            }
                          }
                        },
                  child: AppText(
                    "Exit",
                    fontWeight: FontWeight.bold,
                    color: isDeleting
                        ? Colors.redAccent.shade100
                        : Colors.redAccent,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: AppText("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
