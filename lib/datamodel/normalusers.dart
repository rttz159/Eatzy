import 'package:assignment/datamodel/mappable.dart';

import 'users.dart';
import 'dart:convert';

class NormalUser extends Users implements Mappable {
  late bool isSpecial;
  List<String>? ownedVoucherId;

  NormalUser({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    required this.isSpecial,
  });

  NormalUser.withVoucherList({
    required super.id,
    required super.uid,
    required super.name,
    required super.birthDate,
    required super.ic,
    required super.email,
    required this.isSpecial,
    required this.ownedVoucherId,
  });

  factory NormalUser.fromMap(Map<String, dynamic> map) {
    return NormalUser.withVoucherList(
      id: map['id'] as String?,
      uid: map['uid'] as String?,
      name: map['name'] as String,
      birthDate: map['birthDate'] as String,
      ic: map['ic'] as String,
      email: map['email'] as String,
      isSpecial: map['isSpecial'] == 1,
      ownedVoucherId: map['ownedVoucherId'] != null
          ? List<String>.from(jsonDecode(map['ownedVoucherId'] as String))
          : null,
    );
  }

  bool get getIsSpecial => isSpecial;

  List<String> get getOwnedVoucherId => ownedVoucherId ??= <String>[];

  set setOwnedVoucherId(List<String> ownedVoucherId) {
    this.ownedVoucherId = ownedVoucherId;
  }

  void addOwnedVoucher(String voucherId) {
    ownedVoucherId ??= <String>[];
    ownedVoucherId?.add(voucherId);
  }

  set setIsSpecial(bool isSpecial) {
    this.isSpecial = isSpecial;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'ic': ic,
      'email': email,
      'isSpecial': isSpecial ? 1 : 0,
      'ownedVoucherId':
          ownedVoucherId != null ? jsonEncode(ownedVoucherId) : null,
    };
  }
}
