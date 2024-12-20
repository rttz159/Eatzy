abstract class Users {
  late String? id;
  late String? uid;
  late String name;
  late String birthDate;
  late String ic;
  late String email;
  late String? imageUrl;

  Users({
    required this.id,
    required this.uid,
    required this.name,
    required this.birthDate,
    required this.ic,
    required this.email,
    this.imageUrl,
  });

  String? get getId => id;

  String get getName => name;

  String get getBirthDate => birthDate;

  String get getIc => ic;

  String? get getUid => uid;

  String get getEmail => email;

  String? get getImageUrl => imageUrl;

  set setUid(String uid) {
    this.uid = uid;
  }

  set setId(String id) {
    this.id = id;
  }

  set setName(String name) {
    this.name = name;
  }

  set setBirthDate(String birthDate) {
    this.birthDate = birthDate;
  }

  set setBirthDateFromDateTime(DateTime birthDate) {
    this.birthDate = birthDate.toIso8601String();
  }

  set setIc(String ic) {
    this.ic = ic;
  }

  set setEmail(String email) {
    this.email = email;
  }

  set setImageUrl(String? url) {
    imageUrl = url;
  }
}
