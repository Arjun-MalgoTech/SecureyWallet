import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/AppToastMsg/AppToast.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';

class AddMemberToGroup extends StatefulWidget {
  final String docId;

  const AddMemberToGroup({super.key, required this.docId});

  @override
  State<AddMemberToGroup> createState() => _AddMemberToGroupState();
}

class _AddMemberToGroupState extends State<AddMemberToGroup> {
  LocalStorageService localStorageService = LocalStorageService();
  TextEditingController groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  List<Map<String, dynamic>> selectedMembers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VaultStorageService vaultStorageService = VaultStorageService();

  Future<bool> doesDocumentExist(String documentId) async {
    try {
      var docSnapshot =
          await _firestore.collection('Users').doc(documentId).get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(), () async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var snapshot = await firestore
          .collection('groupChat')
          .doc(widget.docId)
          .get(const GetOptions(source: Source.serverAndCache));
      setState(() {
        membersList = List.from(snapshot.get("memberList"));
        // selectedMembers = List.from(snapshot.get("memberList"));
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
          "Add Member",
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
                  child: Icon(Icons.group_add,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      size: 50),
                ),
                SizedBox(height: SizeConfig.height(context, 5)),
                Align(
                    alignment: Alignment.centerLeft,
                    child: AppText("Add Members", fontSize: 15)),
                TextFormField(
                  controller: _searchController,
                  onChanged: (v) async {
                    setState(() => searchResults = []);
                    if (v.isNotEmpty) {
                      bool alreadyThere =
                          membersList.any((val) => val['walletAddress'] == v);
                      if (alreadyThere) {
                        Utils.snackBarErrorMessage("Member already added");
                      } else {
                        bool documentExists = await doesDocumentExist(v);
                        if (documentExists) {
                          final snapshot = await _firestore
                              .collection('Users')
                              .where('walletAddress', isEqualTo: v)
                              .get(GetOptions(source: Source.serverAndCache));
                          bool alreadyAdded = selectedMembers.any((v) =>
                              v['walletAddress'] ==
                              snapshot.docs[0]['walletAddress']);
                          if (v ==
                              localStorageService
                                  .activeWalletData!.walletAddress) {
                            Utils.snackBarErrorMessage(
                                "You're already in the group");
                          } else if (alreadyAdded) {
                            Utils.snackBarErrorMessage("Member already added");
                          } else {
                            setState(() => searchResults = snapshot.docs);
                          }
                        } else {
                          Utils.snackBarErrorMessage("User not found");
                        }
                      }
                    }
                  },
                  decoration: _inputDecoration("Enter Evm Address"),
                  style: _textFieldStyle(context),
                ),
                SizedBox(height: 10),

                // Show matched users
                ...searchResults.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Container(
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
                        padding: EdgeInsets.all(3), // Adjust padding as needed
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
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (!selectedMembers.contains(data)) {
                            setState(() {
                              selectedMembers.add(data);
                              _searchController.clear();
                              searchResults = [];
                            });
                          }
                        },
                      ),
                    ),
                  );
                }),

                // Show selected members
                if (selectedMembers.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppText("Selected Members:", fontSize: 15),
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
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() => selectedMembers.remove(data));
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                SizedBox(height: 20),
                GestureDetector(
                  onTap: loading
                      ? null
                      : () async {
                          if (selectedMembers.isNotEmpty) {
                            final filteredData = [];
                            for (var member in selectedMembers) {
                              member.remove("onlineStatus");
                              member.remove("unreadCount");
                              filteredData.add(member);
                            }
                            Map<String, dynamic> data = {
                              "memberList": filteredData,
                            };
                            setState(() {
                              loading = true;
                            });
                            addGroupChatData(filteredData);
                          } else if (selectedMembers.isEmpty) {
                            Utils.snackBarErrorMessage(
                                "Please select at least one member.");
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
                              "Add Members",
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
      var snapshot = await firestore
          .collection('groupChat')
          .doc(widget.docId)
          .get(const GetOptions(source: Source.serverAndCache));
      List memberList = snapshot.get("memberList");
      List overallList = [...memberList, ...chatData];
      await firestore
          .collection('groupChat')
          .doc(widget.docId)
          .update({"memberList": overallList});
      Utils.snackBar("Members is added in this group");
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white24,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  TextStyle _textFieldStyle(BuildContext context) {
    return TextStyle(
      fontFamily: 'LexendDeca',
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.surfaceBright,
      fontSize: 14,
    );
  }
}
