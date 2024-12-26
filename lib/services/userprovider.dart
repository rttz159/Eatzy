import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/users.dart';
import 'package:assignment/services/auth.dart';
import 'package:assignment/services/notificationservice.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  Users? _currentUser;
  bool? _isSeller;

  Users? get getCurrentUser => _currentUser;

  bool? get isSeller => _isSeller;

  set setIsSeller(bool seller) => _isSeller = seller;

  set setCurrentUser(Users user) {
    if (_currentUser != user) {
      _currentUser = user;
      if (user is Sellers) {
        _isSeller = true;
      } else {
        _isSeller = false;
      }
      saveUserToLocalStorage();
      notifyListeners();
    }
  }

  UserProvider() {
    loadUserFromLocalStorage();
  }

  void signOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    _isSeller = null;
    prefs.remove("currentUser");
    prefs.remove("isSeller");
    _auth.signOut();
    await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
    notifyListeners();
  }

  Future<void> loadUserFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    if (userData != null) {
      final isSellerDict = prefs.getBool('isSeller');
      if (isSellerDict != null) {
        if (isSellerDict) {
          _currentUser = Sellers.fromJson(jsonDecode(userData));
        } else {
          _currentUser = NormalUser.fromJson(jsonDecode(userData));
        }
        _isSeller = isSellerDict;
      }
      notifyListeners();
    }
  }

  Future<void> refreshNotificationforSeller() async {
    await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
    Sellers tempSeller = _currentUser as Sellers;
    int count = 0;
    for (var sub in tempSeller.getSubscriptions) {
      for (var prod in sub.getProducts) {
        final bestBefore = DateTime.parse(prod.getBestBefore);
        if (bestBefore.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            Object.hash(prod.getId, prod.getSubId),
            "Reminder",
            "Your ${prod.getDesc} in ${sub.getColumn.getId} will expire in 1 day.",
            bestBefore.subtract(const Duration(days: 1)),
          );
          count++;
        }
      }
    }
    print("Notification scheduled! $count notifications.");
  }

  Future<void> saveUserToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      if (isSeller != null) {
        if (isSeller == true) {
          Map<String, dynamic> userMap = (_currentUser as Sellers).toJson();
          userMap['id'] = _currentUser!.getId;
          prefs.setString('currentUser', jsonEncode(userMap));
          prefs.setBool("isSeller", true);
        } else {
          Map<String, dynamic> userMap = (_currentUser as NormalUser).toJson();
          userMap['id'] = _currentUser!.getId;
          prefs.setString('currentUser', jsonEncode(userMap));
          prefs.setBool("isSeller", false);
        }
      }
    }
  }
}
