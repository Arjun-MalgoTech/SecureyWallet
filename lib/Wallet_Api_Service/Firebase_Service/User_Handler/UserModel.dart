class UserModel {
  final String userName;
  final String walletAddress;

  UserModel({required this.userName, required this.walletAddress});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'],
      walletAddress: json['walletAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'walletAddress': walletAddress,
    };
  }
}
