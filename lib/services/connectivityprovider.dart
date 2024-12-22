import 'package:assignment/services/connnectivity.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  final MyConnectivityChecker _checker = MyConnectivityChecker();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    _isConnected = await _checker.checkConnectivityOnce();
    notifyListeners();
  }

  Future<void> refresh() async {
    _isConnected = await _checker.checkConnectivityOnce();
    notifyListeners();
  }
}
