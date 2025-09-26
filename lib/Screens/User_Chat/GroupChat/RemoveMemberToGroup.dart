import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';

class RemoveMemberToGroup extends StatefulWidget {
  final String docId;

  const RemoveMemberToGroup({super.key, required this.docId});

  @override
  State<RemoveMemberToGroup> createState() => _RemoveMemberToGroupState();
}

class _RemoveMemberToGroupState extends State<RemoveMemberToGroup> {
  LocalStorageService localStorageService = LocalStorageService();
  TextEditingController groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  List<Map<String, dynamic>> selectedMembers = [];
  List<Map<String, dynamic>> membersList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VaultStorageService vaultStorageService = VaultStorageService();

  @override
  void initState() {
    Future.delayed(Duration(), () async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var snapshot = await firestore
          .collection('groupChat')
          .doc(widget.docId)
          .get(const GetOptions(source: Source.serverAndCache));
      setState(() {
        membersList = List.from(snapshot.get("memberList"));
        selectedMembers = List.from(snapshot.get("memberList"));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          "Remove Member",
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child:
              Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.group_remove,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      size: 50),
                ),
                SizedBox(height: SizeConfig.height(context, 5)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppText("Group Members:", fontSize: 15),
                ),
                ...selectedMembers.map((data) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white30.withOpacity(0.1)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(4),
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
                          padding:
                              EdgeInsets.all(3), // Adjust padding as needed
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF202832),
                            child: AppText(
                              data['userName'].toString().characters.first,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        title: AppText(
                          data['userName'],
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        ),
                        subtitle: AppText(
                          data['walletAddress']!,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        ), // Using "name" for subtitle
                        trailing: data['walletAddress'] ==
                                localStorageService
                                    .activeWalletData!.walletAddress
                            ? AppText(
                                "Admin",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              )
                            : IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() => selectedMembers.remove(data));
                                },
                              ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (selectedMembers.length != membersList.length) {
                      setState(() {
                        loading = false;
                      });
                      addGroupChatData(selectedMembers);
                    } else {
                      Utils.snackBarErrorMessage(
                          "Please remove at least one member.");
                    }
                  },
                  child: loading
                      ? CircularProgressIndicator()
                      : Container(
                          height: 45,
                          width: MediaQuery.sizeOf(context).width,
                          color: loading
                              ? Colors.deepPurple.withOpacity(0.3)
                              : Colors.deepPurple,
                          child: Center(
                            child: Text(
                              "Remove Members",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool loading = false;

  void addGroupChatData(List chatData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection('groupChat')
          .doc(widget.docId)
          .update({"memberList": chatData});
      Utils.snackBar("Members is removed in this group");
      setState(() {
        loading = false;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error adding group chat data: $e");
    }
  }
}
