import 'package:assignment/datamodel/mappable.dart';

class Products implements Mappable {
  late int id;
  late String firebaseId;
  late String desc;
  late double sellingPrice;
  late double costPrice;
  late int qty;
  late int subId;
  late int lastUpdated;

  Products(
      {required this.id,
      required this.desc,
      required this.sellingPrice,
      required this.costPrice,
      required this.qty,
      required this.subId,
      required this.firebaseId,
      required this.lastUpdated});

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
        id: map['id'] as int,
        desc: map['description'] as String,
        sellingPrice: map['sellingPrice'] as double,
        costPrice: map['costPrice'] as double,
        qty: map['qty'] as int,
        subId: map['subId'] as int,
        firebaseId: map['firebaseId'] as String,
        lastUpdated: map['lastUpdated'] as int);
  }

  int get getId => id;

  String get getDesc => desc;

  double get getSellingPrice => sellingPrice;

  double get getCostPrice => costPrice;

  int get getQty => qty;

  int get getSubId => subId;

  String get getFirebaseId => firebaseId;

  int get getLastUpdated => lastUpdated;

  set setFirebaseId(String firebaseId) {
    this.firebaseId = firebaseId;
  }

  set setLastUpdated(int lastUpdated) {
    this.lastUpdated = lastUpdated;
  }

  set setId(int value) => id = value;

  set setDesc(String value) => desc = value;

  set setSellingPrice(double value) => sellingPrice = value;

  set setCostPrice(double value) => costPrice = value;

  set setQty(int value) => qty = value;

  set setSubId(int value) => subId = value;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': desc,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'qty': qty,
      'subId': subId,
      "firebaseId": firebaseId,
      "lastUpdated": lastUpdated
    };
  }
}
