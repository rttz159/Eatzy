import 'package:assignment/datamodel/mappable.dart';

abstract class Users implements Mappable {
  late String id;
  late String name;
  late String birthDate;
  late String ic;

  Users({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.ic,
  });

  String get getId => id;

  String get getName => name;

  String get getBirthDate => birthDate;

  String get getIc => ic;

  set setId(String id) {
    this.id = id;
  }

  set setName(String name) {
    this.name = name;
  }

  set setBirthDate(String birthDate) {
    this.birthDate = birthDate;
  }

  set setBirthDateFromDateTime(DateTime birthDate) {
    this.birthDate = birthDate.toIso8601String();
  }

  set setIc(String ic) {
    this.ic = ic;
  }
}
