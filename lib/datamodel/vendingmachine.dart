import 'package:assignment/datamodel/column.dart';

class VendingMachine {
  late String? id;
  late String desc;
  late String long;
  late String lat;
  late String? imageUrl;
  late List<VendingMachineColumn> columns;

  VendingMachine({
    required this.id,
    required this.desc,
    required this.long,
    required this.lat,
    this.imageUrl,
    required this.columns,
  });

  factory VendingMachine.fromJson(Map<String, dynamic> map) {
    var columnList = <VendingMachineColumn>[];
    if (map['columns'] != null) {
      columnList = List<VendingMachineColumn>.from(
          map['columns'].map((item) => VendingMachineColumn.fromJson(item)));
    }

    return VendingMachine(
      id: map['id'] as String?,
      desc: map['description'] as String,
      long: map['longitude'] as String,
      lat: map['latitude'] as String,
      imageUrl: map['imageUrl'] as String?,
      columns: columnList,
    );
  }

  String? get getId => id;

  String get getDesc => desc;

  String get getLong => long;

  String get getLat => lat;

  String? get getImageUrl => imageUrl;

  List<VendingMachineColumn> get getColumns => columns;

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

  set setImageUrl(String? url) {
    imageUrl = url;
  }

  set setColumns(List<VendingMachineColumn> columns) {
    this.columns = columns;
  }

  Map<String, dynamic> toJson() {
    return {
      'description': desc,
      'longitude': long,
      'latitude': lat,
      'imageUrl': imageUrl,
      'columns': columns.map((column) => column.toJson()).toList(),
    };
  }
}
