class PurchaseHistory {
  late String? id;
  late String userId;
  String? voucherId;
  late String prodId;
  late int qty;
  late String purchaseDate;

  PurchaseHistory(
      {required this.id,
      required this.userId,
      required this.prodId,
      required this.qty,
      required this.purchaseDate,
      this.voucherId});

  factory PurchaseHistory.fromJson(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as String,
      userId: map['userId'] as String,
      prodId: map['prodId'] as String,
      qty: map['qty'] as int,
      voucherId: map['voucherId'] as String,
      purchaseDate: map['purchaseDate'] as String,
    );
  }

  String? get getId => id;

  String get getUserId => userId;

  String? get getVoucherId => voucherId;

  String get getProdID => prodId;

  int get getQty => qty;

  String get getPurchaseDate => purchaseDate;

  set setId(String id) {
    this.id = id;
  }

  set setUserId(String userId) {
    this.userId = userId;
  }

  set setVoucherId(String? voucherId) {
    this.voucherId = voucherId;
  }

  set setProdID(String prodId) {
    this.prodId = prodId;
  }

  set setPurchaseDate(String purchaseDate) {
    this.purchaseDate = purchaseDate;
  }

  set setQty(int qty) {
    if (qty < 0) {
      throw ArgumentError("Quantity cannot be negative.");
    }
    this.qty = qty;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'voucherId': voucherId,
      'prodId': prodId,
      'qty': qty,
      'purchaseDate': purchaseDate,
    };
  }
}
