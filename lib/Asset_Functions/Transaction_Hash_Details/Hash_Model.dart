class HashModel {
  String? hash;
  String? toAddress;
  String? amount;
  int? time;

  HashModel({this.hash, this.toAddress, this.amount, this.time});

  HashModel.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    toAddress = json['toAddress'];
    amount = json['amount'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hash'] = this.hash;
    data['toAddress'] = this.toAddress;
    data['amount'] = this.amount;
    data['time'] = this.time;
    return data;
  }
}
