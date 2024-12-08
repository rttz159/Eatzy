import 'package:assignment/datamodel/mappable.dart';

class Column implements Mappable {
  late int id;
  late String firebaseId;
  late String vmId;
  late bool isAvailable;
  late int lastUpdated;

  Column(
      {required this.id,
      required this.vmId,
      required this.isAvailable,
      required this.lastUpdated});

  factory Column.fromMap(Map<String, dynamic> map) {
    return Column(
        id: map['id'] as int,
        vmId: map['vmId'] as String,
        isAvailable: map['isAvailable'] == 1,
        lastUpdated: map['lastUpdated'] as int);
  }

  int get getId => id;

  String get getVmId => vmId;

  bool get getIsAvailable => isAvailable;

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

  set setVmId(String vmId) {
    this.vmId = vmId;
  }

  set setIsAvailable(bool isAvailable) {
    this.isAvailable = isAvailable;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'vmId': vmId,
      'isAvailable': isAvailable ? 1 : 0,
      'lastUpdated': lastUpdated
    };
  }
}
