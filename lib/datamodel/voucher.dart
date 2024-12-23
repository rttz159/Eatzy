class Voucher {
  late String? id;
  late String desc;
  late String startDate;
  late String endDate;
  late double percentage;

  Voucher({
    required this.id,
    required this.desc,
    required this.endDate,
    required this.startDate,
    required this.percentage,
  });

  factory Voucher.fromJson(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'] as String,
      desc: map['description'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      percentage: map['percentage'] as double,
    );
  }

  String? get getId => id;

  String get getDesc => desc;

  String get getStartDate => startDate;

  String get getEndDate => endDate;

  double get getPercentage => percentage;

  set setId(String id) {
    this.id = id;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "description": desc,
      "startDate": startDate,
      "endDate": endDate,
      "percentage": percentage,
    };
  }
}
