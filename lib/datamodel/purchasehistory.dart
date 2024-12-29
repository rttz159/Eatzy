import 'dart:convert';
import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/voucher.dart';

class PurchaseHistory {
  String? id;
  late String userId;
  Voucher? voucher;
  late Map<Products, int> prodList;
  late String purchaseDate;
  late bool redeem;

  PurchaseHistory({
    this.id,
    required this.userId,
    required this.prodList,
    required this.purchaseDate,
    required this.redeem,
    this.voucher,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as String?,
      userId: map['userId'] as String,
      prodList: _decodeProdList(map['prodList']),
      voucher: map['voucher'] != null ? Voucher.fromJson(map['voucher']) : null,
      purchaseDate: map['purchaseDate'] as String,
      redeem: map['redeem'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'voucher': voucher?.toJson(),
      'prodList': _encodeProdList(prodList),
      'purchaseDate': purchaseDate,
      'redeem': redeem,
    };
  }

  double getTotalAmount() {
    double totalAmount = 0;
    if (prodList.isEmpty) {
      return totalAmount;
    }
    for (var x in prodList.entries) {
      totalAmount += (x.key.getSellingPrice * x.value);
    }
    return totalAmount;
  }

  static Map<Products, int> _decodeProdList(dynamic prodListJson) {
    if (prodListJson == null) return {};

    Map<String, dynamic> prodListMap = jsonDecode(prodListJson);
    Map<Products, int> prodList = {};
    prodListMap.forEach((productJson, quantity) {
      Products product = Products.fromJson(jsonDecode(productJson));
      prodList[product] = quantity as int;
    });

    return prodList;
  }

  static String _encodeProdList(Map<Products, int> prodList) {
    Map<String, dynamic> encodedMap = {};
    prodList.forEach((product, qty) {
      encodedMap[jsonEncode(product.toJson())] = qty;
    });

    return jsonEncode(encodedMap);
  }
}
