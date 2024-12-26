import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:flutter/material.dart';
import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/datamodel/subscription.dart';

class UserCartDataProvider extends ChangeNotifier {
  late VendingMachine _selectedVendingMachine;
  late List<Sellers> _sellerList;
  late List<Subscription> _subscriptionList;
  late List<Products> _prodList;
  late Map<Products, int> _cart;
  bool isFetchingData = false;

  UserCartDataProvider() {
    _cart = {};
    _sellerList = [];
  }

  Future<void> getData() async {
    isFetchingData = true;
    notifyListeners();
    CloudDatabase db = CloudDatabase();
    _sellerList = (await db.read(CloudDatabase.seller)).map((seller) {
      return Sellers.fromJson(seller);
    }).toList();

    _subscriptionList = [];
    for (Sellers seller in _sellerList) {
      _subscriptionList.addAll(seller.getSubscriptions);
    }
    _subscriptionList = _subscriptionList.where((subscription) {
      return DateTime.parse(subscription.endDate).isAfter(DateTime.now());
    }).toList();
    _subscriptionList = _subscriptionList.where((subscription) {
      return subscription.getColumn.getVmId == selectedVendingMachine.getId;
    }).toList();

    _prodList = [];
    for (var x in _subscriptionList) {
      _prodList.addAll(x.getProducts.where((product) {
        return DateTime.parse(product.getBestBefore).isAfter(DateTime.now());
      }));
    }
    _sortProducts();
    isFetchingData = false;
    notifyListeners();
  }

  void _sortProducts() {
    _prodList.sort((a, b) {
      if (a.qty > 0 && b.qty == 0) {
        return -1;
      } else if (a.qty == 0 && b.qty > 0) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  set selectedVendingMachine(VendingMachine vendingMachine) {
    _selectedVendingMachine = vendingMachine;
    notifyListeners();
  }

  set sellerList(List<Sellers> sellers) {
    _sellerList = sellers;
    notifyListeners();
  }

  set subscriptionList(List<Subscription> subscriptions) {
    _subscriptionList = subscriptions;
    notifyListeners();
  }

  set prodList(List<Products> products) {
    _prodList = products;
    _sortProducts();
    notifyListeners();
  }

  set cart(Map<Products, int> cart) {
    _cart = cart;
    notifyListeners();
  }

  VendingMachine get selectedVendingMachine => _selectedVendingMachine;
  List<Sellers> get sellerList => _sellerList;
  List<Subscription> get subscriptionList => _subscriptionList;
  List<Products> get prodList => _prodList;
  Map<Products, int> get cart => _cart;

  void addToCart(Products product, int quantity) {
    product.qty -= quantity;
    if (_cart.containsKey(product)) {
      _cart[product] = _cart[product]! + quantity;
    } else {
      _cart[product] = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(Products product) {
    product.qty += _cart[product]!;
    _cart.remove(product);
    notifyListeners();
  }

  void updateProductQuantity(Products product, int quantity) {
    if (_cart.containsKey(product)) {
      _cart[product] = quantity;
      notifyListeners();
    }
  }
}
