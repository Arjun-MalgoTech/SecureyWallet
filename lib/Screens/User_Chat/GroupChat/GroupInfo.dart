import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';

class GroupInfo extends StatefulWidget {
  final String docId;

  const GroupInfo({super.key, required this.docId});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  LocalStorageService localStorageService = LocalStorageService();
  List<Map<String, dynamic>> selectedMembers = [];
  var groupDetails = null;

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
        groupDetails = snapshot.data();
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
          "Group Info",

          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child:
              Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
        ),
      ),
      body: groupDetails == null
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.purpleAccent[100],
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.groups,
                          color: Theme.of(context).colorScheme.surfaceBright,
                          size: 50),
                    ),
                    SizedBox(height: SizeConfig.height(context, 1)),
                    AppText(groupDetails["groupName"], fontSize: 15),
                    SizedBox(height: SizeConfig.height(context, 5)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                          "Group Members (${selectedMembers.length})",
                          fontSize: 15),
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
                                    groupDetails["adminList"][0]
                                ? AppText(
                                    "Admin",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                          height: 45,
                          width: MediaQuery.sizeOf(context).width,
                          color: Colors.deepPurple,
                          child: Center(
                            child: Text(
                              "Back",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
