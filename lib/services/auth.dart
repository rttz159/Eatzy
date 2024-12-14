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
      await _db.save(CloudDatabase.seller, tempSeller.toMap());
    } else {
      NormalUser tempNormalUser = tempUser as NormalUser;
      tempNormalUser.setUid = uid;
      await _db.save(CloudDatabase.normalUsers, tempNormalUser.toMap());
    }

    Fluttertoast.showToast(msg: 'Sign-up successful!');
    return true;
  }

  Future<Users?> signIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;
      String uid = user?.uid.toString() ?? "";
      if (uid != "") {
        (Map<String, dynamic>?, bool?) tempUserData = await _db.getUser(uid);
        if (tempUserData.$1 == null) {
          Fluttertoast.showToast(msg: "No user found for that email.");
          return null;
        }
        bool? tempBool = tempUserData.$2;
        final tempUser = tempUserData.$1;
        if (tempBool != null && tempUser != null) {
          if (tempBool) {
            NormalUser tempNormalUser = NormalUser.fromMap(tempUser);
            return tempNormalUser;
          } else {
            Sellers tempSeller = Sellers.fromMap(tempUser);
            return tempSeller;
          }
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message = e.message!;
      Fluttertoast.showToast(msg: message);
      return null;
    }
  }

  Future signOut(BuildContext context) async {
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
