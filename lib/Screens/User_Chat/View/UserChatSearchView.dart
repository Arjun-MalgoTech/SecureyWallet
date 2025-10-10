import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/Crypto_Utils/ColorHandlers/AppColors.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';
import 'package:securywallet/Screens/App_Drawer/App_Drawer_View.dart';
import 'package:securywallet/Screens/User_Chat/GroupChat/GroupChatScreen.dart';
import 'package:securywallet/Screens/User_Chat/View/UserChatView.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/Wallet_Session_Request.dart';

class UserChat extends StatefulWidget {
  const UserChat({Key? key}) : super(key: key);

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  LocalStorageService localStorageService = LocalStorageService();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<Map<String, dynamic>> searchResults = [];

  var recentChats = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List storerecentChats = [];
  String? docId;
  bool? isExist = true;

  VaultStorageService vaultStorageService = VaultStorageService();

  Future<bool> doesDocumentExist(String documentId) async {
    try {
      var docSnapshot =
          await _firestore.collection('Users').doc(documentId).get();
      return docSnapshot.exists;
    } catch (e) {
      // print("Error checking document existence: $e");
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchLocalData();
      Provider.of<LocalStorageService>(context, listen: false).getData();
      await chatListFetch();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Stream getRecentChatsStream() {
    return _firestore.collection('Chat').snapshots();
  }

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('Users').snapshots();
  }

  Stream<QuerySnapshot> getGroupChatsStream() {
    return _firestore.collection('groupChat').snapshots();
  }

  chatAdd(QuerySnapshot chatSnapshot, QuerySnapshot groupChatsSnapshot,
      QuerySnapshot userSnapshot) async {
    List users = userSnapshot.docs.map((doc) => doc.data()).toList();

    var usr = users.firstWhere(
      (element) =>
          element["walletAddress"] ==
          localStorageService.activeWalletData?.walletAddress,
      orElse: () => null,
    );
    if (usr == null) {
      return;
    }
    myProfile = usr;

    if (localStorageService.activeWalletData == null) {
      return;
    }

    List<QueryDocumentSnapshot> userChats = chatSnapshot.docs.where((doc) {
      return doc.id
          .contains(localStorageService.activeWalletData!.walletAddress);
    }).toList();

    Set<String> documentIdsSet = userChats.map((chat) => chat.id).toSet();

    for (var user in users) {
      if (user["walletAddress"] ==
          localStorageService.activeWalletData!.walletAddress) continue;

      for (var docId in documentIdsSet) {
        if (docId.contains(user["walletAddress"])) {
          var v = user;
          v["timestamp"] =
              userChats.firstWhere((chat) => chat.id == docId)['timestamp'];

          int existingIndex = recentChats.indexWhere(
              (chat) => chat["walletAddress"] == user["walletAddress"]);

          if (existingIndex != -1) {
            recentChats[existingIndex] = v;
          } else {
            recentChats.add(v);
          }
        }
      }
    }

    // Add group chats
    // QuerySnapshot groupChatsSnapshot = await getGroupChatsStream();
    for (var doc in groupChatsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final List memberList = data['memberList'] ?? [];
      bool check = memberList.any((v) =>
          v["walletAddress"] ==
          localStorageService.activeWalletData!.walletAddress);
      if (check) {
        Map<String, dynamic> groupChat = {
          'groupID': data['groupID'],
          'groupName': data['groupName'],
          'timestamp': data['timestamp'],
          'memberList': data['memberList'],
          'adminList': data['adminList'],
          'isGroup': true,
        };

        bool alreadyExists = recentChats.any((chat) =>
            chat['isGroup'] == true && chat['groupID'] == groupChat['groupID']);

        if (alreadyExists) {
          int index = recentChats.indexWhere((chat) =>
              chat['isGroup'] == true &&
              chat['groupID'] == groupChat['groupID']);
          recentChats[index] = groupChat;
        }
        if (!alreadyExists) {
          recentChats.add(groupChat);
        }
      }
    }

    recentChats = removeDuplicates(recentChats);

    await vaultStorageService.chatRemove(
        "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
    await vaultStorageService.chatWrite(
        "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
        recentChats);

    storerecentChats = vaultStorageService.chatRead(
        "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
  }

  List<Map> removeDuplicates(List listOfMaps) {
    Set<String> seen = {};
    List<Map> uniqueList = [];

    for (var map in listOfMaps) {
      String key = map['isGroup'] == true
          ? map['groupID'] ?? ''
          : map['walletAddress'] ?? '';
      if (seen.add(key)) {
        uniqueList.add(map);
      }
    }

    return uniqueList;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _firestore
        .collection('Users')
        .doc(localStorageService.activeWalletData!.walletAddress)
        .update({"onlineStatus": false});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _firestore
          .collection('Users')
          .doc(localStorageService.activeWalletData!.walletAddress)
          .update({"onlineStatus": false});
    } else if (state == AppLifecycleState.resumed) {
      _firestore
          .collection('Users')
          .doc(localStorageService.activeWalletData!.walletAddress)
          .update({"onlineStatus": true});
    }
  }

  fetchLocalData() async {
    storerecentChats = await vaultStorageService.chatRead(
        "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
    // await appData().box.remove(AppConstant.recentChatsKey);
    // print("SSS:$storerecentChats");
    setState(() {
      recentChats = List.from(storerecentChats);
    });
    _firestore
        .collection('Users')
        .doc(localStorageService.activeWalletData!.walletAddress)
        .update({"onlineStatus": true});
  }

  Map<String, dynamic>? myProfile;

  chatListFetch() async {
    final snapshot = await _firestore.collection('Users').get();
    final profile = await _firestore
        .collection('Users')
        .doc(localStorageService.activeWalletData!.walletAddress)
        .get();
    myProfile = profile.data();
    List users = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();
    List<String> documentIdsToCheck = [];

    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('Chat');

    QuerySnapshot querySnapshot = await chatCollection.get();

    List<QueryDocumentSnapshot> userChats = querySnapshot.docs.where((doc) {
      String docId = doc.id;
      return docId
          .contains(localStorageService.activeWalletData!.walletAddress);
    }).toList();

    var dd = userChats;

    for (var i = 0; i < dd.length; i++) {
      documentIdsToCheck.add(dd[i].id);
    }

    List newRecentChats = [];

    for (int i = 0; i < users.length; i++) {
      for (int j = 0; j < documentIdsToCheck.length; j++) {
        if (documentIdsToCheck[j].contains(users[i]["walletAddress"]) &&
            users[i]["walletAddress"] !=
                localStorageService.activeWalletData!.walletAddress) {
          recentChats.add(users[i]);
          newRecentChats.add(users[i]);
          recentChats = List.from(storerecentChats);
          recentChats.addAll(newRecentChats);

          recentChats = removeDuplicates(recentChats);

          await vaultStorageService.chatRemove(
              "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
          await vaultStorageService.chatWrite(
              "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}",
              recentChats);
          storerecentChats = vaultStorageService.chatRead(
              "${ApiKeyService.recentChatsKey}_${localStorageService.activeWalletData!.walletAddress}");
        }
      }
    }

    setState(() {
      recentChats = recentChats;
    });
  }

  chatExist(String address) async {
    String walletAddress = address;
    String combinedAddress =
        '${walletAddress}_${localStorageService.activeWalletData!.walletAddress}';
    String reverseCombinedAddress =
        '${localStorageService.activeWalletData!.walletAddress}_$walletAddress';
    if (await doesChatExist(combinedAddress)) {
      docId = combinedAddress;
      isExist = true;
    } else if (await doesChatExist(reverseCombinedAddress)) {
      docId = reverseCombinedAddress;
      isExist = true;
    } else {
      isExist = false;
      docId = reverseCombinedAddress;
    }

    setState(() {
      docId = docId;
      isExist = isExist;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> doesChatExist(String documentId) async {
    try {
      var docSnapshot = await _firestore
          .collection('Chat')
          .doc(documentId)
          .get(const GetOptions(source: Source.serverAndCache));
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  WalletConnectionRequest walletSessionRequest = WalletConnectionRequest();

  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    walletSessionRequest = context.watch<WalletConnectionRequest>();
    walletSessionRequest.initializeContext(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: AppText(
          "Chat",
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
          ),
          // PopupMenuButton<String>(
          //   icon: Icon(Icons.more_vert,
          //       color: Theme.of(context).colorScheme.surfaceBright),
          //   onSelected: (v) {
          //     if (v.contains("settings")) {
          //       _scaffoldKey.currentState?.openDrawer();
          //     } else if (v.contains("create_group")) {
          //       Navigator.of(context).push(
          //           MaterialPageRoute(builder: (builder) => CreateGroupPage()));
          //     }
          //   },
          //   color: Colors.deepPurple.shade700,
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       value: 'settings',
          //       child: Row(
          //         children: [
          //           Icon(Icons.settings,
          //               color: Theme.of(context).colorScheme.surfaceBright),
          //           CustomText('  Settings'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem<String>(
          //       value: 'create_group',
          //       child: Row(
          //         children: [
          //           Icon(Icons.groups,
          //               color: Theme.of(context).colorScheme.surfaceBright),
          //           CustomText('  Create Group'),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          // GestureDetector(
          //   onTap: () {
          //     _scaffoldKey.currentState?.openDrawer();
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 10),
          //     child: Icon(
          //       Icons.settings,
          //       color: Theme.of(context).colorScheme.surfaceBright,
          //     ),
          //   ),
          // ),
          // PopupMenuButton<String>(
          //   icon: Icon(Icons.more_vert,
          //       color: Theme.of(context).colorScheme.surfaceBright),
          //   onSelected: (v) {
          //     if (v.contains("settings")) {
          //       _scaffoldKey.currentState?.openDrawer();
          //     } else if (v.contains("create_group")) {
          //       Navigator.of(context).push(
          //           MaterialPageRoute(builder: (builder) => CreateGroupPage()));
          //     }
          //   },
          //   color: Colors.deepPurple.shade700,
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       value: 'settings',
          //       child: Row(
          //         children: [
          //           Icon(Icons.settings,
          //               color: Theme.of(context).colorScheme.surfaceBright),
          //           CustomText('  Settings'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem<String>(
          //       value: 'create_group',
          //       child: Row(
          //         children: [
          //           Icon(Icons.groups,
          //               color: Theme.of(context).colorScheme.surfaceBright),
          //           CustomText('  Create Group'),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          SizedBox(width: SizeConfig.width(context, 2)),
        ],
      ),
      key: _scaffoldKey,
      drawer: AppDrawer(walletConnectionRequest: walletSessionRequest),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.height(context, 2),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    /*    onChanged: (v) async {
                      setState(() {
                        searchResults = [];
                      });

                      if (_searchController.text.isNotEmpty) {
                        bool documentExists = await doesDocumentExist(v);

                        if (documentExists) {
                          final snapshot = await _firestore
                              .collection('Users')
                              .where('walletAddress',
                                  isEqualTo: _searchController.text)
                              .get(GetOptions(source: Source.serverAndCache));
                          setState(() {
                            searchResults = snapshot.docs;
                          });
                        }
                      }
                    },*/

                    onChanged: (v) async {
                      String searchText = _searchController.text.trim();

                      setState(() {
                        searchResults = [];
                      });

                      if (searchText.isEmpty) return;

                      // Wallet address is usually a long alphanumeric string. Adjust pattern as needed.
                      final isAddress = searchText.startsWith('0x') &&
                          searchText.length >= 10;

                      if (isAddress) {
                        // 🔍 Firestore search by walletAddress
                        final walletSnapshot = await _firestore
                            .collection('Users')
                            .where('walletAddress', isEqualTo: searchText)
                            .get(GetOptions(source: Source.serverAndCache));

                        final combinedDocs = walletSnapshot.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        setState(() {
                          searchResults = combinedDocs;
                        });
                      } else {
                        // 🔍 Local search from recentChats by userName
                        final filtered = recentChats.where((chat) {
                          final name =
                              (chat['userName'] ?? '').toString().toLowerCase();
                          return name.contains(searchText.toLowerCase());
                        }).toList();

                        setState(() {
                          searchResults =
                              List<Map<String, dynamic>>.from(filtered);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).bottomAppBarTheme.color ??
                              Color(0xFFD4D4D4),
                        ), // No border
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).bottomAppBarTheme.color ??
                              Color(0xFFD4D4D4),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.surfaceBright,
                        size: 25,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              onPressed: () {
                                setState(() {
                                  _searchController
                                      .clear(); // Clears the text field
                                  searchResults =
                                      []; // Clears the search results
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.content_paste_go),
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              onPressed: () async {
                                ClipboardData? data = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                setState(() {
                                  _searchController.text =
                                      data!.text!; // Clears the text field
                                  searchResults =
                                      []; // Clears the search results
                                });

                                if (_searchController.text.isNotEmpty) {
                                  bool documentExists = await doesDocumentExist(
                                      _searchController.text);

                                  if (documentExists) {
                                    final snapshot = await _firestore
                                        .collection('Users')
                                        .where('walletAddress',
                                            isEqualTo: _searchController.text)
                                        .get(GetOptions(
                                            source: Source.serverAndCache));
                                    setState(() {
                                      searchResults = snapshot.docs
                                          .map((doc) => doc.data()
                                              as Map<String, dynamic>)
                                          .toList();
                                    });
                                  }
                                }
                              },
                            ), // Shows clear icon only when there is text
                      hintText: 'Enter Secury user name or address  ...',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.w400,fontFamily: "BricolageGrotesque"),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // No border
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor:
                          Color(0xFF0a0b11),
                      filled: true, // Fill the TextField background with color
                    ),
                    style: TextStyle(
                      decorationThickness: 0.0,
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              _searchController.text.isNotEmpty
                  ? SizedBox()
                  : SizedBox(
                      // color: Colors.orange,
                      height: MediaQuery.sizeOf(context).height,
                      child: StreamBuilder(
                          stream: getRecentChatsStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.hasError) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 200.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.purpleAccent[100],
                                    ),
                                  ),
                                ],
                              );
                            }
                            // print("QQQQ${snapshot.data}");
                            // chatAdd(snapshot.data!);
                            return StreamBuilder(
                                stream: getGroupChatsStream(),
                                builder: (context, grpSnapshot) {
                                  if (!grpSnapshot.hasData ||
                                      grpSnapshot.hasError) {
                                    return SizedBox();
                                  }
                                  return StreamBuilder<QuerySnapshot>(
                                      stream: getUsersStream(),
                                      builder: (context, snap) {
                                        if (!snap.hasData || snap.hasError) {
                                          return SizedBox();
                                        }
                                        // print("wwww${snap.data}");
                                        chatAdd(snapshot.data!,
                                            grpSnapshot.data!, snap.data!);

                                        return recentChats.isEmpty
                                            ? Column(
                                              children: [
                                                SizedBox(height:MediaQuery.of(context).size.height*0.06),
                                                Image.asset("assets/Images/emptychat.png"),
                                                AppText("Start Your First Crypto Chat!",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,color: Colors.white,),
                                                SizedBox(height: 10,),
                                                AppText("Easily connect by searching a Secury",color: Color(0XFFB4B1B2),
                                                fontSize: 13,fontWeight: FontWeight.w400,),
                                                AppText("username or starting a chat with any wallet",color: Color(0XFFB4B1B2),
                                                  fontSize: 13,fontWeight: FontWeight.w400,),
                                                AppText("address, all in one place.",color: Color(0XFFB4B1B2),
                                                  fontSize: 13,fontWeight: FontWeight.w400,),
                                                SizedBox(height: 20,),
                                                AppText("Scan QR Code",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17,color: Colors.white,),

                                              ],

                                            )
                                            : ListView.builder(
                                                itemCount: recentChats.length,
                                                padding: EdgeInsets.only(
                                                    bottom: SizeConfig.height(
                                                        context, 40)),
                                                itemBuilder: (context, index) {
                                                  if (recentChats.length > 1) {
                                                    recentChats.sort((a, b) => b[
                                                                'timestamp'] ==
                                                            null
                                                        ? 0000000000
                                                        : b['timestamp']
                                                            .toDate()
                                                            .millisecondsSinceEpoch
                                                            .compareTo(a[
                                                                        'timestamp'] ==
                                                                    null
                                                                ? 0000000000
                                                                : a['timestamp']
                                                                    .toDate()
                                                                    .millisecondsSinceEpoch));
                                                  }
                                                  final item =
                                                      recentChats[index];

                                                  return item["isGroup"] == true
                                                      ? groupChatTile(item)
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                color: Colors
                                                                    .white30
                                                                    .withOpacity(
                                                                        0.1)),
                                                            child: ListTile(
                                                              onTap: () async {
                                                                if (_isTapped)
                                                                  return; // If already tapped, exit early

                                                                setState(() {
                                                                  _isTapped =
                                                                      true;
                                                                });
                                                                await chatExist(
                                                                    item[
                                                                        'walletAddress']!);
                                                                if (docId !=
                                                                        null &&
                                                                    mounted) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ChatScreenView(
                                                                              isChatExist: isExist!,
                                                                              item: item,
                                                                              walletAddress: item['walletAddress'].toString(),
                                                                              docId: docId!,
                                                                            )),
                                                                  );
                                                                }

                                                                await Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1));

                                                                _isTapped =
                                                                    false;
                                                              },
                                                              leading: Stack(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .green,
                                                                        width:
                                                                            0.3,
                                                                      ),
                                                                      gradient:
                                                                          LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xFF912ECA),
                                                                          Color(
                                                                              0xFF793CDE),
                                                                        ], // Change colors as needed
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight,
                                                                      ),
                                                                    ),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            3), // Adjust padding as needed
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          25,
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xFF202832),
                                                                      child:
                                                                      AppText(
                                                                        item['userName']
                                                                            .toString()
                                                                            .characters
                                                                            .first,
                                                                        fontFamily:
                                                                            'LexendDeca',
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          15,
                                                                      width: 15,
                                                                      decoration: BoxDecoration(
                                                                          color: item['onlineStatus'] == null || item['onlineStatus'] == false
                                                                              ? Colors.grey
                                                                              : Colors.green,
                                                                          shape: BoxShape.circle),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              title: AppText(
                                                                item[
                                                                    'userName'],
                                                                fontFamily:
                                                                    'LexendDeca',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 15,
                                                              ),
                                                              subtitle:
                                                              AppText(
                                                                item[
                                                                    'walletAddress']!,
                                                                fontFamily:
                                                                    'LexendDeca',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 15,
                                                              ), // Using "name" for subtitle
                                                              trailing: myProfile == null ||
                                                                      myProfile![
                                                                              'unreadCount'] ==
                                                                          null ||
                                                                      myProfile!['unreadCount']
                                                                              [
                                                                              item['walletAddress']!] ==
                                                                          null
                                                                  ? SizedBox()
                                                                  : Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: AppColors()
                                                                            .bottomColorDark,
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            6.0),
                                                                        child:
                                                                        AppText(
                                                                          myProfile == null || myProfile!['unreadCount'] == null
                                                                              ? ""
                                                                              : (myProfile!['unreadCount'][item['walletAddress']!] ?? item['userName'].toString().characters.first).toString(),
                                                                          fontFamily:
                                                                              'LexendDeca',
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ), // Using "name" for trailing
                                                            ),
                                                          ),
                                                        );
                                                },
                                              );
                                      });
                                });
                          }),
                    ),
              searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? const GradientAppText(
                      text: "No Search Result Found",
                      fontSize: 20,
                    )
                  : searchResults.isEmpty
                      ? SizedBox()
                      : SizedBox(
                          //color: Colors.pink,
                          height: MediaQuery.sizeOf(context).height,
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              return ListTile(
                                onTap: () async {
                                  if (_isTapped)
                                    return; // If already tapped, exit early

                                  setState(() {
                                    _isTapped = true;
                                  });
                                  await chatExist(item['walletAddress']!);
                                  if (docId != null && mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatScreenView(
                                                isChatExist: isExist!,
                                                item: item,
                                                walletAddress:
                                                    item['walletAddress']
                                                        .toString(),
                                                docId: docId!,
                                              )),
                                    );
                                    await Future.delayed(Duration(seconds: 1));

                                    _isTapped = false;
                                  }
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF202832),
                                  child: AppText(
                                    item['userName']
                                        .toString()
                                        .characters
                                        .first,
                                    fontFamily: 'LexendDeca',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                title: AppText(
                                  item['userName'],
                                  fontFamily: 'LexendDeca',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ),
                                subtitle: AppText(
                                  item['walletAddress']!,
                                  fontFamily: 'LexendDeca',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ), // Using "name" for subtitle
                                trailing: AppText(
                                  item['userName'].toString().characters.first,
                                  fontFamily: 'LexendDeca',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ), // Using "name" for trailing
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget groupChatTile(item) {
    List memberList = item['memberList'];
    int index = memberList.indexWhere((v) =>
        v['walletAddress'] ==
        localStorageService.activeWalletData!.walletAddress);
    bool unread = memberList[index]['unread'] ?? false;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white30.withOpacity(0.1)),
        child: ListTile(
          onTap: () async {
            if (_isTapped) return; // If already tapped, exit early

            setState(() {
              _isTapped = true;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupChatScreen(
                        item: item,
                        walletAddress: item['walletAddress'].toString(),
                        docId: item['groupID'],
                        recentChats: recentChats))).then((v) {
              if (v == true) {
                fetchLocalData();
              }
            });
            await Future.delayed(Duration(seconds: 1));

            _isTapped = false;
          },
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 0.3,
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF912ECA),
                  Color(0xFF793CDE),
                ], // Change colors as needed
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(3), // Adjust padding as needed
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF202832),
              child: Icon(Icons.groups, color: Colors.white),
            ),
          ),
          title: AppText(
            item['groupName'],
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
          subtitle: AppText(
            "Group Chat",
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
          trailing: unread
              ? Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors().bottomColorDark,
                  ),
                )
              : SizedBox(),
        ),
      ),
    );
  }
}
