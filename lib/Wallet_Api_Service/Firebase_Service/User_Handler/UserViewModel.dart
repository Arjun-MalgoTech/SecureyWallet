import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:securywallet/Wallet_Api_Service/Firebase_Service/User_Handler/UserModel.dart';

class UserStateManager {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> storeUserInfo(Map data) async {
    try {
      UserModel user = UserModel(
          userName: data["userName"], walletAddress: data["walletAddress"]);

      bool documentExists = await doesUserExist(user.walletAddress);

      // If a document with the same wallet address exists, update it
      if (documentExists) {
        await firestore
            .collection('Users')
            .doc(user.walletAddress)
            .update(user.toJson());
        print("User updated successfully!");
      } else {
        // If no document with the same wallet address exists, save the user
        await firestore
            .collection('Users')
            .doc(user.walletAddress)
            .set(user.toJson());
        print("User saved successfully!");
      }
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  Future<bool> doesUserExist(String documentId) async {
    try {
      var docSnapshot =
          await firestore.collection('Users').doc(documentId).get();
      return docSnapshot.exists;
    } catch (e) {
      print("Error checking document existence: $e");
      return false;
    }
  }
}

UserStateManager userStateManager = UserStateManager();
