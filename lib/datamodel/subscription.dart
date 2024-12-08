import 'package:assignment/datamodel/mappable.dart';

class Subscription implements Mappable {
  late int id;
  late String firebaseId;
  late String startDate;
  late String endDate;
  late int colId;
  late int lastUpdated;

  Subscription(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.colId,
      required this.lastUpdated,
      required this.firebaseId});

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
        id: map['id'] as int,
        startDate: map['startDate'] as String,
        endDate: map['endDate'] as String,
        colId: map['colId'] as int,
        firebaseId: map['firebaseId'] as String,
        lastUpdated: map['lastUpdated'] as int);
  }

  int get getId => id;

  int get getColId => colId;

  String get getStartDate => startDate;

  String get getEndDate => endDate;

  String get getFirebaseId => firebaseId;

  int get getLastUpdated => lastUpdated;

  set setFirebaseId(String firebaseId) {
    this.firebaseId = firebaseId;
  }

  set setLastUpdated(int lastUpdated) {
    this.lastUpdated = lastUpdated;
  }

  set setId(int id) {
    this.id = id;
  }

  set setStartDate(String startDate) {
    this.startDate = startDate;
  }

  set setEndDate(String endDate) {
    this.endDate = endDate;
  }

  set setColId(int colId) {
    this.colId = colId;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'colId': colId,
      'lastUpdated': lastUpdated,
      'firebaseId': firebaseId
    };
  }
}
