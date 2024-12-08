import 'package:assignment/datamodel/mappable.dart';

class PurchaseHistory implements Mappable {
  late int id;
  late String firebaseId;
  late String userId;
  int? voucherId;
  late int prodId;
  late int qty;
  late String purchaseDate;
  late int lastUpdated;

  PurchaseHistory(
      {required this.id,
      required this.userId,
      required this.prodId,
      required this.qty,
      required this.purchaseDate,
      required this.firebaseId,
      required this.lastUpdated,
      this.voucherId});

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
        id: map['id'] as int,
        userId: map['userId'] as String,
        prodId: map['prodId'] as int,
        qty: map['qty'] as int,
        voucherId: map['voucherId'] as int,
        purchaseDate: map['purchaseDate'] as String,
        lastUpdated: map['lastUpdated'] as int,
        firebaseId: map['firebaseId'] as String);
  }

  int get getId => id;

  String get getUserId => userId;

  int get getVoucherId => voucherId ??= -1;

  int get getProdID => prodId;

  int get getQty => qty;

  String get getPurchaseDate => purchaseDate;

  String get getFirebaseId => firebaseId;

  int get getLastUpdated => lastUpdated;

  set setFirebaseId(String firebaseId) {
    this.firebaseId = firebaseId;
  }

  set setLastUpdated(int lastUpdated) {
    this.lastUpdated = lastUpdated;
  }

  set setId(int id) {
    this.id = id;
  }

  set setUserId(String userId) {
    this.userId = userId;
  }

  set setVoucherId(int? voucherId) {
    this.voucherId = voucherId;
  }

  set setProdID(int prodId) {
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'voucherId': voucherId,
      'prodId': prodId,
      'qty': qty,
      'purchaseDate': purchaseDate,
      'lastUpdated': lastUpdated,
      'firebaseId': firebaseId
    };
  }
}
