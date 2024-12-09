import 'package:assignment/datamodel/mappable.dart';

class Voucher implements Mappable {
  late String id;
  late int subId;
  late String desc;
  late String startDate;
  late String endDate;
  late double percentage;

  Voucher({
    required this.id,
    required this.subId,
    required this.desc,
    required this.endDate,
    required this.startDate,
    required this.percentage,
  });

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'] as String,
      subId: map['subId'] as int,
      desc: map['description'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      percentage: map['percentage'] as double,
    );
  }

  String get getId => id;

  int get getSubId => subId;

  String get getDesc => desc;

  String get getStartDate => startDate;

  String get getEndDate => endDate;

  double get getPercentage => percentage;

  set setId(String id) {
    this.id = id;
  }

  set setSubId(int subId) {
    this.subId = subId;
  }

  set setDesc(String desc) {
    this.desc = desc;
  }

  set setStartDate(String startDate) {
    this.startDate = startDate;
  }

  set setEndDate(String endDate) {
    this.endDate = endDate;
  }

  set setPercentage(double percentage) {
    this.percentage = percentage;
  }

  Map<String, dynamic> toMap() {
    return {
      "subId": subId,
      "description": desc,
      "startDate": startDate,
      "endDate": endDate,
      "percentage": percentage,
    };
  }
}
