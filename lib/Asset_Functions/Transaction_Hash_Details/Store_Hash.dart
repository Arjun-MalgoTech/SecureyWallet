import 'package:get_storage/get_storage.dart';
import 'package:securywallet/Asset_Functions/Transaction_Hash_Details/Hash_Model.dart';

class GetHashStorage {
  static final GetHashStorage _instance = GetHashStorage._internal();
  late GetStorage _box;

  factory GetHashStorage() {
    return _instance;
  }

  GetHashStorage._internal() {
    _box = GetStorage();
  }

  Future<void> storeHashList(String key, List data) async {
    await _box.write(key, data);
  }

  Future<void> storeHashList1(String key, List data) async {
    await _box.write(key, data);
  }

  bool isAddressAlreadyExists(List dataList, String hash) {
    for (var map in dataList) {
      if (map == hash) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateHashToList(String key, Map hash) async {
    List? hashList = _box.read<List>(key);
    List list = hashList ?? [];
    list.add(hash);
    await storeHashList(key, list);
  }

  List<HashModel> getHashList(String key) {
    List? list = _box.read<List>(key);
    List<HashModel>? models = list
        ?.map((item) => HashModel(
            hash: item["hash"],
            toAddress: item["toAddress"],
            amount: item["amount"],
            time: item["time"]))
        .toList();
    print("HASHHHHH$list");
    return models ?? [];
  }

  // Remove data
  Future<void> removeData(String key) async {
    await _box.remove(key);
  }
}
