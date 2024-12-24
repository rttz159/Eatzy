import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';

///Singleton class to implement the network checker.
class MyConnectivityChecker {
  MyConnectivityChecker._();

  static final _instance = MyConnectivityChecker._();
  factory MyConnectivityChecker() => _instance;

  static MyConnectivityChecker get instance => _instance;
  final _connectivity = Connectivity();
  bool _hasInternetConn = false;
  late StreamSubscription _connSub;
  late StreamSubscription _internetSub;

  ///Checking for the connection type for once, whether it is mobile, wifi or none
  Future<String> checkConnectivityTypeOnce() async {
    final result = await _connectivity.checkConnectivity();
    switch (result[-1]) {
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.wifi:
        return 'wifi';
      default:
        return 'none';
    }
  }

  ///Checking for the internet connection for once, return a boolean value
  Future<bool> checkConnectivityOnce() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      _hasInternetConn = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _hasInternetConn = false;
    }
    return _hasInternetConn;
  }

  ///Passing a function that accept a List of ConnectivityResult as a parameter to enable the subscription to the connectivity type listener. Calling this function twice will overwrite the previous function.
  void subscribeToConnectivityTypeChanged(
      void Function(List<ConnectivityResult>) x) {
    _connSub = _connectivity.onConnectivityChanged.listen(x);
  }

  ///use this in dispose function
  void cancelConnectivityTypeSub() {
    _connSub.cancel();
  }

  ///use this in dispose function
  void cancelInternetConnectivitySub() {
    _internetSub.cancel();
  }
}
