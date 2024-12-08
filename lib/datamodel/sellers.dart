import 'package:assignment/datamodel/mappable.dart';

import 'users.dart';
import 'dart:convert';

class Sellers extends Users implements Mappable {
  List<String>? subList;

  Sellers(
      {required super.id,
      required super.name,
      required super.birthDate,
      required super.ic,
      required super.firebaseId,
      required super.lastUpdated});

  Sellers.withSubList(
      {required super.id,
      required super.name,
      required super.birthDate,
      required super.ic,
      required super.firebaseId,
      required super.lastUpdated,
      required this.subList});

  factory Sellers.fromMap(Map<String, dynamic> map) {
    return Sellers.withSubList(
        id: map['id'] as int,
        name: map['name'] as String,
        birthDate: map['birthDate'] as String,
        ic: map['ic'] as String,
        subList: map['subList'] != null
            ? List<String>.from(jsonDecode(map['subList'] as String))
            : null,
        firebaseId: map['firebaseId'] as String,
        lastUpdated: map['lastUpdated'] as int);
  }

  List<String> get getSubList => subList ??= <String>[];

  set setSubList(List<String> subList) {
    this.subList = subList;
  }

  void addSubToList(String subId) {
    subList ??= <String>[];
    subList?.add(subId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'ic': ic,
      'subList': subList != null ? jsonEncode(subList) : null,
      'lastUpdated': lastUpdated,
      'firebaseId': firebaseId
    };
  }
}
