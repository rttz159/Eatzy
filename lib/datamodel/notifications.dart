import 'package:assignment/datamodel/mappable.dart';

class Notification implements Mappable {
  late int id;
  late String firebaseId;
  String desc = "";
  String? userId;
  String? sellerId;
  late int lastUpdated;

  Notification(
      {required this.id,
      required this.desc,
      this.userId,
      this.sellerId,
      required this.lastUpdated,
      required this.firebaseId});

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
        id: map['id'] as int,
        desc: map['description'] as String,
        userId: map['userId'] as String,
        sellerId: map['sellerId'] as String,
        lastUpdated: map['lastUpdated'] as int,
        firebaseId: map['firebaseId'] as String);
  }

  int get getId => id;

  String get getDesc => desc;

  String get getUserId => userId ??= "";

  String get getSellerId => sellerId ??= "";

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

  set setUserId(String userId) {
    this.userId = userId;
  }

  set setSellerId(String sellerId) {
    this.sellerId = sellerId;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "description": desc,
      "userId": userId ??= "",
      "sellerId": sellerId ??= "",
      "firebaseId": firebaseId,
      "lastUpdated": lastUpdated
    };
  }
}
