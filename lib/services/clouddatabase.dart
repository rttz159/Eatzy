import 'package:cloud_firestore/cloud_firestore.dart';

class CloudDatabase {
  static final CloudDatabase _instance = CloudDatabase._();

  CloudDatabase._() {
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  factory CloudDatabase() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String products = "products";
  static const String notifications = "notifications";
  static const String purchaseHistory = "purchasehistory";
  static const String normalUsers = "normalusers";
  static const String seller = "sellers";
  static const String subscription = "subscription";
  static const String vendingMachine = "vendingmachine";
  static const String voucher = "voucher";

  FirebaseFirestore get firestore => _firestore;

  // Create or Update
  Future<bool> save(String collection, Map<String, dynamic> data,
      {String? docId}) async {
    try {
      if (data.isEmpty) {
        throw Exception("Cannot save empty data.");
      }
      if (docId != null) {
        await _firestore
            .collection(collection)
            .doc(docId)
            .set(data, SetOptions(merge: true));
        return true;
      } else {
        await _firestore.collection(collection).add(data);
        return true;
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
          return [docSnapshot.data()!..['id'] = docSnapshot.id];
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

  // Get the user
  Future<(Map<String, dynamic>?, bool?)> getUser(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(CloudDatabase.normalUsers)
          .where('uid', isEqualTo: uid)
          .get();
      if (docSnapshot.docs.isNotEmpty) {
        return (docSnapshot.docs[0].data(), true);
      }
      final docSnapshot2 = await _firestore
          .collection(CloudDatabase.seller)
          .where('uid', isEqualTo: uid)
          .get();
      if (docSnapshot2.docs.isNotEmpty) {
        return (docSnapshot.docs[0].data(), false);
      }
      return (null, null);
    } catch (e) {
      return (null, null);
    }
  }

  // Update specific fields in a document
  Future<void> update(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      if (data.isEmpty) {
        throw Exception("Cannot update with empty data.");
      }
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
