import 'package:assignment/datamodel/mappable.dart';

abstract class Users implements Mappable {
  late int id;
  late String firebaseId;
  late String name;
  late String birthDate;
  late String ic;
  late int lastUpdated;

  Users(
      {required this.id,
      required this.name,
      required this.birthDate,
      required this.ic,
      required this.firebaseId,
      required this.lastUpdated});

  int get getId => id;

  String get getName => name;

  String get getBirthDate => birthDate;

  String get getIc => ic;

  String get getFirebaseId => firebaseId;

  int get getLastUpdated => lastUpdated;

  set setId(int id) {
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

  set setFirebaseId(String firebaseId) {
    this.firebaseId = firebaseId;
  }

  set setLastUpdated(int lastUpdated) {
    this.lastUpdated = lastUpdated;
  }
}
