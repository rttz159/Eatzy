class Products {
  late String? id;
  late String desc;
  late double sellingPrice;
  late double costPrice;
  late int qty;
  late int subId;
  late String? imageUrl;

  Products({
    required this.id,
    required this.desc,
    required this.sellingPrice,
    required this.costPrice,
    required this.qty,
    required this.subId,
    this.imageUrl,
  });

  factory Products.fromJson(Map<String, dynamic> map) {
    return Products(
      id: map['id'] as String?,
      desc: map['description'] as String,
      sellingPrice: map['sellingPrice'] as double,
      costPrice: map['costPrice'] as double,
      qty: map['qty'] as int,
      subId: map['subId'] as int,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String? get getId => id;
  String get getDesc => desc;
  double get getSellingPrice => sellingPrice;
  double get getCostPrice => costPrice;
  int get getQty => qty;
  int get getSubId => subId;
  String? get getImageUrl => imageUrl;

  set setId(String value) => id = value;
  set setDesc(String value) => desc = value;
  set setSellingPrice(double value) => sellingPrice = value;
  set setCostPrice(double value) => costPrice = value;
  set setQty(int value) => qty = value;
  set setSubId(int value) => subId = value;
  set setImageUrl(String? value) => imageUrl = value;

  Map<String, dynamic> toJson() {
    return {
      'description': desc,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'qty': qty,
      'subId': subId,
      'imageUrl': imageUrl,
    };
  }
}
