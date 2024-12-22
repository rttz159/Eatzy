import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/connnectivity.dart';
import 'package:flutter/material.dart';

class VendingMachineProvider extends ChangeNotifier {
  final MyConnectivityChecker _connectivityChecker = MyConnectivityChecker();
  final CloudDatabase db = CloudDatabase();
  List<VendingMachine> _vendingMachine = [];

  List<VendingMachine> get vendingMachines => _vendingMachine;

  VendingMachineProvider() {
    getVendingMachines();
  }

  Future<void> getVendingMachines() async {
    bool internetConnection =
        await _connectivityChecker.checkConnectivityOnce();
    if (internetConnection) {
      final tempVendingMachines = await db.read(CloudDatabase.vendingMachine);
      final processedVendingMachine = tempVendingMachines.map((map) {
        return VendingMachine.fromJson(map);
      }).toList();
      _vendingMachine = processedVendingMachine;
      notifyListeners();
    }
  }
}
