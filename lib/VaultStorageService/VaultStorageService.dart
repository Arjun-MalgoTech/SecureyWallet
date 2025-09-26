import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:securywallet/Api_Service/Apikey_Service.dart';
import 'package:securywallet/UserWalletData/UserWalletData.dart';
import 'package:securywallet/Wallet_Api_Service/Firebase_Service/User_Handler/UserViewModel.dart';


class VaultStorageService {
  static final VaultStorageService _instance = VaultStorageService._internal();
  late Box _box;
  late GetStorage chatStore;

  factory VaultStorageService() {
    return _instance;
  }

  VaultStorageService._internal() {
    chatStore = GetStorage();
  }

  Future<void> init() async {
    // Initialize Hive and open a box
    await Hive.initFlutter();
    _box = await Hive.openBox('NV_Wallet_Box');
    await GetStorage.init();
  }

  Future<void> selectedWallet(dynamic data) async {
    await _box.put('selectedWallet', data);
  }

  UserWalletDataModel? fetchSelectedList() {
    var data;
    try {
      data = _box.get('selectedWallet');
    } on Exception {
      data = null;
    }
    // Explicitly cast the data to Map<String, dynamic>
    return data != null
        ? UserWalletDataModel.fromJson(Map<String, dynamic>.from(data))
        : null;
  }

  Future<void> storeWalletList(String key, List data) async {
    await _box.put(key, data);
  }

  // Add a map to the list
  Future<void> addWalletToList(String key, dynamic map) async {
    List list = getWalletList();
    if (!isAddressAlreadyExists(list, map["privateKey"])) {
      if (map["walletName"] != "Wallet 1 (Main)") {
        list.add(map);
      } else {
        map["walletName"] = "Wallet ${list.length + 1} (Main)";
        list.add(map);
      }
      selectedWallet(map);
      userStateManager.storeUserInfo({
        'userName': map["walletName"],
        'walletAddress': map['walletAddress'],
      });
      await storeWalletList(key, list);
    }
  }

  bool isAddressAlreadyExists(List dataList, String privateKey) {
    for (var map in dataList) {
      if (map.containsKey("privateKey") && map["privateKey"] == privateKey) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateWalletToList(dynamic map) async {
    List list = getWalletList();
    var selected = fetchSelectedList();
    if (isAddressAlreadyExists(list, map["privateKey"])) {
      for (int i = 0; i < list.length; i++) {
        if (list[i]["privateKey"] == map["privateKey"]) {
          list[i] = map;
          break;
        }
      }
      userStateManager.storeUserInfo({
        'userName': map["walletName"],
        'walletAddress': map['walletAddress'],
      });
    }
    if (map["privateKey"] == selected!.privateKey) {
      selectedWallet(map);
    }
    await storeWalletList(ApiKeyService.nvWalletList, list);
  }

  // Retrieve list of map data
  List getWalletList() {
    List? list;
    try {
      list = _box.get(ApiKeyService.nvWalletList, defaultValue: []);
    } on Exception {
      list = [];
    }
    return list ?? [];
  }

  // Remove data
  Future<void> removeData(dynamic map) async {
    List list = getWalletList();
    var selected = fetchSelectedList();
    list.removeWhere((item) => item["privateKey"] == map["privateKey"]);
    if (map["privateKey"] == selected!.privateKey) {
      if (list.isNotEmpty) {
        selectedWallet(list[0]);
      } else {
        _box.delete('selectedWallet');
      }
    }
    await storeWalletList(ApiKeyService.nvWalletList, list);
  }

  chatRead(String key) {
    return chatStore.read(key);
  }

  Future<void> chatWrite(String key, dynamic value) async {
    await chatStore.write(key, value);
  }

  Future<void> chatRemove(String key) async {
    await chatStore.remove(key);
  }
}
