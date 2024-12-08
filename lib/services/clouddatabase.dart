import 'package:cloud_firestore/cloud_firestore.dart';

class CloudDatabase {
  static final CloudDatabase _instance = CloudDatabase._();

  CloudDatabase._();

  final _firestore = FirebaseFirestore.instance;

  factory CloudDatabase() {
    return _instance;
  }

  static const String products = "products";
  static const String notifications = "notifications";
  static const String purchaseHistory = "purchasehistory";
  static const String normalUsers = "normalusers";
  static const String seller = "sellers";
  static const String subscription = "subscription";
  static const String vendingMachine = "vendingmachine";
  static const String voucher = "voucher";

  get firestore => _firestore;

  //Create or Update
  Future<String> save(String collection, Map<String, dynamic> data,
      {String? docId}) async {
    try {
      if (docId != null) {
        await _firestore
            .collection(collection)
            .doc(docId)
            .set(data, SetOptions(merge: true));
        return docId;
      } else {
        var docRef = await _firestore.collection(collection).add(data);
        return docRef.id;
      }
    } catch (e) {
      throw Exception("Failed to save data: $e");
    }
  }

  // Read
  Future<List<Map<String, dynamic>>> read(String collection,
      {String? docId}) async {
    try {
      if (docId != null) {
        final docSnapshot =
            await _firestore.collection(collection).doc(docId).get();
        if (docSnapshot.exists) {
          return [docSnapshot.data()!..['firebaseId'] = docSnapshot.id];
        } else {
          return [];
        }
      } else {
        final querySnapshot = await _firestore.collection(collection).get();
        return querySnapshot.docs.map((doc) {
          return doc.data()..['id'] = doc.id;
        }).toList();
      }
    } catch (e) {
      throw Exception("Failed to read data: $e");
    }
  }

  // Update specific fields in a document
  Future<void> update(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  // Delete a specific document
  Future<void> delete(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception("Failed to delete data: $e");
    }
  }
}
