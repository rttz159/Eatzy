import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'clouddatabase.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudDatabase _db = CloudDatabase();
  static Users? _currentUser;

  Users? get getCurrentUser => _currentUser;

  set setCurrentUser(Users tempUser) => _currentUser = tempUser;

  Future<void> _refreshTokenWithRetry() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.getIdToken(true);
          print("Token refreshed successfully.");
          break;
        }
      } catch (e) {
        retryCount++;
        print("Retry $retryCount failed: $e");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (retryCount == maxRetries) {
      print("Failed to refresh token after $maxRetries attempts.");
    }
  }

  Future<String?> _signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = _auth.currentUser;
      return user?.uid.toString();
    } on FirebaseAuthException catch (e) {
      String message = e.message!;
      Fluttertoast.showToast(msg: message);
      return null;
    }
  }

  Future<bool> signUpWithDetails({
    required String email,
    required String password,
    required Users tempUser,
    required BuildContext context,
  }) async {
    bool isSeller = tempUser is Sellers;

    String? uid = await _signUp(email: email, password: password);

    if (uid == null || uid.isEmpty) {
      Fluttertoast.showToast(msg: 'Sign-up failed. Please try again.');
      return false;
    }

    if (isSeller) {
      Sellers tempSeller = tempUser;
      tempSeller.setUid = uid;
      _currentUser = tempSeller;
      await _db.save(CloudDatabase.seller, tempSeller.toJson());
    } else {
      NormalUser tempNormalUser = tempUser as NormalUser;
      tempNormalUser.setUid = uid;
      _currentUser = tempNormalUser;
      await _db.save(CloudDatabase.normalUsers, tempNormalUser.toJson());
    }

    Fluttertoast.showToast(msg: 'Sign-up successful!');
    return true;
  }

  Future<Users?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        (Map<String, dynamic>?, bool?) tempUserData = await _db.getUser(uid);
        if (tempUserData.$1 == null) {
          Fluttertoast.showToast(msg: "No user found for that email.");
          return null;
        }
        bool? tempBool = tempUserData.$2;
        final tempUser = tempUserData.$1;
        if (tempBool != null && tempUser != null) {
          await _refreshTokenWithRetry();
          if (tempBool) {
            NormalUser tempNormalUser = NormalUser.fromJson(tempUser);
            return tempNormalUser;
          } else {
            Sellers tempSeller = Sellers.fromJson(tempUser);
            return tempSeller;
          }
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      String message = e.message!;
      if (e.code == 'network-request-failed') {
        message = "No Internet Connection";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid Credentials";
      }
      Fluttertoast.showToast(msg: message);
      return null;
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
      Fluttertoast.showToast(msg: "Successfully logout.");
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetPassword(String email) async {
    try {
      _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Email Sent!");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
