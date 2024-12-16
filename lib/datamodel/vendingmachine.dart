class VendingMachine {
  late String? id;
  late String desc;
  late String long;
  late String lat;
  late String? imageUrl;

  VendingMachine({
    required this.id,
    required this.desc,
    required this.long,
    required this.lat,
    this.imageUrl,
  });

  factory VendingMachine.fromJson(Map<String, dynamic> map) {
    return VendingMachine(
      id: map['id'] as String?,
      desc: map['description'] as String,
      long: map['longitude'] as String,
      lat: map['latitude'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String? get getId => id;

  String get getDesc => desc;

  String get getLong => long;

  String get getLat => lat;

  String? get getImageUrl => imageUrl;

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

  Map<String, dynamic> toJson() {
    return {
      'description': desc,
      'longitude': long,
      'latitude': lat,
      'imageUrl': imageUrl,
    };
  }
}
