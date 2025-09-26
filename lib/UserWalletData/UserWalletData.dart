class UserWalletDataModel {
  String walletName;
  String walletAddress;
  String mnemonic;
  String privateKey;

  UserWalletDataModel({
    required this.walletName,
    required this.walletAddress,
    required this.mnemonic,
    required this.privateKey,
  });

  factory UserWalletDataModel.fromJson(Map<String, dynamic> json) => UserWalletDataModel(
        walletName: json["walletName"],
        walletAddress: json["walletAddress"],
        mnemonic: json["mnemonic"],
        privateKey: json["privateKey"],
      );

  Map<String, dynamic> toJson() => {
        "walletName": walletName,
        "walletAddress": walletAddress,
        "mnemonic": mnemonic,
        "privateKey": privateKey,
      };
}
