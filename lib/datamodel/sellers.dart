import 'users.dart';
import 'dart:convert';

class Sellers extends Users {
  List<String>? subList;

  Sellers({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    super.imageUrl,
  });

  Sellers.withSubList({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    required this.subList,
    super.imageUrl,
  });

  factory Sellers.fromJson(Map<String, dynamic> map) {
    return Sellers.withSubList(
      id: map['id'] as String?,
      uid: map['uid'] as String?,
      name: map['name'] as String,
      birthDate: map['birthDate'] as String,
      ic: map['ic'] as String,
      email: map['email'] as String,
      subList: map['subList'] != null
          ? List<String>.from(jsonDecode(map['subList'] as String))
          : null,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  List<String> get getSubList => subList ??= <String>[];

  set setSubList(List<String> subList) {
    this.subList = subList;
  }

  void addSubToList(String subId) {
    subList ??= <String>[];
    subList?.add(subId);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'ic': ic,
      'email': email,
      'subList': subList != null ? jsonEncode(subList) : null,
      'imageUrl': imageUrl,
    };
  }
}
