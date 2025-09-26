class AssetModel {
  String? rpcURL;
  String? explorerURL;
  String? coinSymbol;
  String? coinName;
  String? imageUrl;
  String? balanceFetchAPI;
  String? sendAmountAPI;
  String? address;
  String? coinType;
  String? tokenAddress;
  String? tokenDecimal;
  String? network;
  String? gasPriceSymbol;
  bool disabled;

  AssetModel({
    this.rpcURL,
    this.explorerURL,
    this.coinSymbol,
    this.coinName,
    this.imageUrl,
    this.balanceFetchAPI,
    this.sendAmountAPI,
    this.address,
    this.coinType,
    this.tokenAddress,
    this.tokenDecimal,
    this.network,
    this.gasPriceSymbol,
    this.disabled = false, // default value for disabled
  });

  AssetModel.fromJson(Map<String, dynamic> json)
      : rpcURL = json['rpcURL'],
        explorerURL = json['explorerURL'],
        coinSymbol = json['coinSymbol'],
        coinName = json['coinName'],
        imageUrl = json['imageUrl'],
        balanceFetchAPI = json['balanceFetchAPI'],
        sendAmountAPI = json['sendAmountAPI'],
        address = json['address'],
        coinType = json['coinType'],
        tokenAddress = json['tokenAddress'],
        tokenDecimal = json['tokenDecimal'],
        network = json['network'],
        gasPriceSymbol = json['gasPriceSymbol'],
        disabled = json['disabled'] ?? false; // handle missing field

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rpcURL'] = this.rpcURL;
    data['explorerURL'] = this.explorerURL;
    data['coinSymbol'] = this.coinSymbol;
    data['coinName'] = this.coinName;
    data['imageUrl'] = this.imageUrl;
    data['balanceFetchAPI'] = this.balanceFetchAPI;
    data['sendAmountAPI'] = this.sendAmountAPI;
    data['address'] = this.address;
    data['coinType'] = this.coinType;
    data['tokenAddress'] = this.tokenAddress;
    data['tokenDecimal'] = this.tokenDecimal;
    data['network'] = this.network;
    data['gasPriceSymbol'] = this.gasPriceSymbol;
    data['disabled'] = this.disabled; // include disabled field
    return data;
  }
}
