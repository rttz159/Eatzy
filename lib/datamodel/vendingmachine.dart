import 'package:assignment/datamodel/mappable.dart';

class VendingMachine implements Mappable {
  late String? id;
  late String desc;
  late String long;
  late String lat;

  VendingMachine({
    required this.id,
    required this.desc,
    required this.long,
    required this.lat,
  });

  factory VendingMachine.fromMap(Map<String, dynamic> map) {
    return VendingMachine(
      id: map['id'] as String,
      desc: map['description'] as String,
      long: map['longitude'] as String,
      lat: map['latitude'] as String,
    );
  }

  String? get getId => id;

  String get getDesc => desc;

  String get getLong => long;

  String get getLat => lat;

  set setId(String id) {
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
      'description': desc,
      'longitude': long,
      'latitude': lat,
    };
  }
}
