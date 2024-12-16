class Subscription {
  late String? id;
  late String startDate;
  late String endDate;
  late int colId;

  Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.colId,
  });

  factory Subscription.fromJson(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      colId: map['colId'] as int,
    );
  }

  String? get getId => id;

  int get getColId => colId;

  String get getStartDate => startDate;

  String get getEndDate => endDate;

  set setId(String id) {
    this.id = id;
  }

  set setStartDate(String startDate) {
    this.startDate = startDate;
  }

  set setEndDate(String endDate) {
    this.endDate = endDate;
  }

  set setColId(int colId) {
    this.colId = colId;
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'colId': colId,
    };
  }
}
