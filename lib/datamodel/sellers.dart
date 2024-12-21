import 'package:assignment/datamodel/subscription.dart';

import 'users.dart';
import 'dart:convert';

class Sellers extends Users {
  List<Subscription>? subscriptions;

  Sellers({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    this.subscriptions,
    super.imageUrl,
  });

  factory Sellers.fromJson(Map<String, dynamic> map) {
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
    );
  }

  List<Subscription> get getSubscriptions => subscriptions ??= <Subscription>[];

  set setSubscriptions(List<Subscription> subs) {
    subscriptions = subs;
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
    };
  }
}
