import 'package:assignment/datamodel/mappable.dart';

class VendingMachine implements Mappable {
  late int id;
  late String firebaseId;
  late String desc;
  late String long;
  late String lat;
  late int lastUpdated;

  VendingMachine(
      {required this.id,
      required this.desc,
      required this.long,
      required this.lat,
      required this.firebaseId,
      required this.lastUpdated});

  factory VendingMachine.fromMap(Map<String, dynamic> map) {
    return VendingMachine(
        id: map['id'] as int,
        desc: map['description'] as String,
        long: map['longitude'] as String,
        lat: map['latitude'] as String,
        firebaseId: map['firebaseId'] as String,
        lastUpdated: map['lastUpdated'] as int);
  }

  int get getId => id;

  String get getDesc => desc;

  String get getLong => long;

  String get getLat => lat;

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

  set setDesc(String desc) {
    this.desc = desc;
  }

  set setLong(String long) {
    this.long = long;
  }

  set setLat(String lat) {
    this.lat = lat;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': desc,
      'longitude': long,
      'latitude': lat,
      'firebaseId': firebaseId,
      'lastUpdated': lastUpdated
    };
  }
}
