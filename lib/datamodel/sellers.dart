import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/voucher.dart';

import 'users.dart';
import 'dart:convert';

class Sellers extends Users {
  List<Subscription>? subscriptions;
  late List<Voucher> vouchers;

  Sellers({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    required this.vouchers,
    this.subscriptions,
    super.imageUrl,
  });

  factory Sellers.fromJson(Map<String, dynamic> map) {
    var voucherList = jsonDecode(map['vouchers']) as List<dynamic>;
    List<Voucher> vouchersList = voucherList
        .map((product) => Voucher.fromJson(product as Map<String, dynamic>))
        .toList();
    return Sellers(
      id: map['id'] as String?,
      uid: map['uid'] as String?,
      name: map['name'] as String,
      birthDate: map['birthDate'] as String,
      ic: map['ic'] as String,
      email: map['email'] as String,
      subscriptions: map['subscriptions'] != null
          ? (jsonDecode(map['subscriptions']) as List)
              .map((subMap) =>
                  Subscription.fromJson(subMap as Map<String, dynamic>))
              .toList()
          : null,
      imageUrl: map['imageUrl'] as String?,
      vouchers: vouchersList,
    );
  }

  List<Subscription> get getSubscriptions => subscriptions ??= <Subscription>[];

  List<Voucher> get getVouchers => vouchers;

  set setSubscriptions(List<Subscription> subs) {
    subscriptions = subs;
  }

  set setVouchers(List<Voucher> vouchers) {
    this.vouchers = vouchers;
  }

  void addSubscription(Subscription subscription) {
    subscriptions ??= <Subscription>[];
    subscriptions?.add(subscription);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'ic': ic,
      'email': email,
      'subscriptions': subscriptions != null
          ? jsonEncode(subscriptions!.map((sub) => sub.toJson()).toList())
          : null,
      'imageUrl': imageUrl,
      'vouchers':
          jsonEncode(vouchers.map((voucher) => voucher.toJson()).toList()),
    };
  }
}
