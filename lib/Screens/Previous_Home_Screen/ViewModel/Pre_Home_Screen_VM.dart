import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:securywallet/Screens/Previous_Home_Screen/Model/Asset_Model/Asset_Model.dart';

class PreHomeScreenVm extends ChangeNotifier {
  AssetModel assetModel = AssetModel();

  final box = GetStorage();

  void addDataToStorage(List<Map<String, String>> assetList) {
    box.write('coinList', assetList);
    // notifyListeners();
  }

  List<Map<String, String>> retrieveDataFromStorage() {
    return box.read('coinList') ?? [];
  }
}
