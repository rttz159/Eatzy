import 'package:assignment/datamodel/column.dart';
import 'package:assignment/datamodel/products.dart';

class Subscription {
  late String? id;
  late String startDate;
  late String endDate;
  late VendingMachineColumn column;
  late List<Products> products;

  Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.column,
    required this.products,
  });

  factory Subscription.fromJson(Map<String, dynamic> map) {
    var productList = map['products'] as List<dynamic>;
    List<Products> productsList = productList
        .map((product) => Products.fromJson(product as Map<String, dynamic>))
        .toList();

    return Subscription(
      id: map['id'] as String?,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      column:
          VendingMachineColumn.fromJson(map['column'] as Map<String, dynamic>),
      products: productsList,
    );
  }

  String? get getId => id;
  String get getStartDate => startDate;
  String get getEndDate => endDate;
  VendingMachineColumn get getColumn => column;
  List<Products> get getProducts => products;

  set setId(String id) {
    this.id = id;
  }

  set setStartDate(String startDate) {
    this.startDate = startDate;
  }

  set setEndDate(String endDate) {
    this.endDate = endDate;
  }

  set setColumn(VendingMachineColumn column) {
    this.column = column;
  }

  set setProducts(List<Products> products) {
    this.products = products;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'column': column.toJson(),
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}
