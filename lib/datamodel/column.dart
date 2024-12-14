import 'package:assignment/datamodel/mappable.dart';

class Column implements Mappable {
  late String? id;
  late String vmId;
  late bool isAvailable;

  Column({
    required this.id,
    required this.vmId,
    required this.isAvailable,
  });

  factory Column.fromMap(Map<String, dynamic> map) {
    return Column(
      id: map['id'] as String,
      vmId: map['vmId'] as String,
      isAvailable: map['isAvailable'] == 1,
    );
  }

  String? get getId => id;

  String get getVmId => vmId;

  bool get getIsAvailable => isAvailable;

  set setId(String id) {
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
      'vmId': vmId,
      'isAvailable': isAvailable ? 1 : 0,
    };
  }
}
