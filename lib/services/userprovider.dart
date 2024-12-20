import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/users.dart';
import 'package:assignment/services/auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  AuthService _auth = AuthService();
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

  void signOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    _isSeller = null;
    prefs.remove("currentUser");
    prefs.remove("isSeller");
    _auth.signOut();
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

  Future<void> saveUserToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      if (isSeller != null) {
        if (isSeller == true) {
          prefs.setString(
              'currentUser', jsonEncode((_currentUser as Sellers).toJson()));
          prefs.setBool("isSeller", true);
        } else {
          prefs.setString(
              'currentUser', jsonEncode((_currentUser as NormalUser).toJson()));
          prefs.setBool("isSeller", false);
        }
      }
    }
  }
}
