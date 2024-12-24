import 'package:assignment/services/connnectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectivityProvider extends ChangeNotifier {
  final MyConnectivityChecker _checker = MyConnectivityChecker();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initializeConnectivity();
    _startListeningToConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    _isConnected = await _checker.checkConnectivityOnce();
    if (_isConnected) {
      Fluttertoast.showToast(msg: "Internet Connected");
    } else {
      Fluttertoast.showToast(
          msg:
              "No Internet Connection, restart the application for using online mode.");
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _isConnected = await _checker.checkConnectivityOnce();
    notifyListeners();
  }

  void _startListeningToConnectivity() {
    _checker.subscribeToConnectivityTypeChanged((results) async {
      final newConnectionStatus = await _checker.checkConnectivityOnce();
      if (newConnectionStatus != _isConnected) {
        _isConnected = newConnectionStatus;
        if (_isConnected) {
          Fluttertoast.showToast(msg: "Internet Reconnected");
        } else {
          Fluttertoast.showToast(msg: "Internet Disconnected");
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _checker.cancelConnectivityTypeSub();
    super.dispose();
  }
}
