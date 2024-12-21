class Notification {
  late String? id;
  String desc = "";
  String? userId;
  String? sellerId;

  Notification({
    required this.id,
    required this.desc,
    this.userId,
    this.sellerId,
  });

  factory Notification.fromJson(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      desc: map['description'] as String,
      userId: map['userId'] as String,
      sellerId: map['sellerId'] as String,
    );
  }

  String? get getId => id;

  String get getDesc => desc;

  String get getUserId => userId ??= "";

  String get getSellerId => sellerId ??= "";

  set setId(String id) {
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

  Map<String, dynamic> toJson() {
    return {
      "description": desc,
      "userId": userId ??= "",
      "sellerId": sellerId ??= "",
    };
  }
}
