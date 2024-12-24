import 'dart:io';
import 'dart:convert';
import 'package:assignment/datamodel/purchasehistory.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class PurchaseHistoryProvider extends ChangeNotifier {
  final CloudDatabase _db = CloudDatabase();
  final String collectionPath = CloudDatabase.purchaseHistory;
  List<PurchaseHistory> _purchaseHistoryList = [];

  PurchaseHistoryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadDocumentsFromLocal();
    notifyListeners();
    _startListening();
  }

  List<PurchaseHistory> get purchaseHistoryList => _purchaseHistoryList;

  void _startListening() {
    _db.firestore
        .collection(collectionPath)
        .snapshots()
        .listen((snapshot) async {
      _purchaseHistoryList = snapshot.docs.map((doc) {
        var temp = PurchaseHistory.fromJson(doc.data());
        temp.id = doc.id;
        return temp;
      }).toList();
      notifyListeners();
      await _saveDocumentsLocally();
    });
  }

  Future<void> _saveDocumentsLocally() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$collectionPath.json');
      final newData =
          jsonEncode(_purchaseHistoryList.map((doc) => doc.toJson()).toList());

      if (await file.exists()) {
        final currentData = await file.readAsString();
        if (currentData == newData) {
          return;
        }
      }

      await file.writeAsString(newData);
    } catch (e) {
      debugPrint('Failed to save documents locally: $e');
    }
  }

  Future<void> loadDocumentsFromLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$collectionPath.json');

    _purchaseHistoryList = [];

    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List<dynamic>;
      _purchaseHistoryList = jsonList
          .map((json) => PurchaseHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }
}
