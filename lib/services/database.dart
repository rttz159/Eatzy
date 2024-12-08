import 'localdatabase.dart';
import 'clouddatabase.dart';

class Database {
  Database._();

  static final Database _instance = Database._();
  final LocalDatabase _localDatabase = LocalDatabase();
  final CloudDatabase _cloudDatabase = CloudDatabase();

  factory Database() {
    return _instance;
  }

  get localDatabase => _localDatabase;

  get cloudDatabase => _cloudDatabase;

  Future<bool> cacheData() async {
    try {
      final tempProducts = await _cloudDatabase.read("products");
      final tempNotification = await _cloudDatabase.read("notifications");
      final tempPurchaseHistory = await _cloudDatabase.read("purchasehistory");

      if (tempProducts.isNotEmpty) {
        await _localDatabase.replaceRecords(
            LocalDatabase.products, tempProducts);
      } else {
        print("No products found in cloud.");
      }

      if (tempNotification.isNotEmpty) {
        await _localDatabase.replaceRecords(
            LocalDatabase.notifications, tempNotification);
      } else {
        print("No notifications found in cloud.");
      }

      if (tempPurchaseHistory.isNotEmpty) {
        await _localDatabase.replaceRecords(
            LocalDatabase.purchaseHistory, tempPurchaseHistory);
      } else {
        print("No purchase history found in cloud.");
      }

      return true;
    } catch (e) {
      print('Error syncing data: $e');
      return false;
    }
  }

  Future<bool> refreshCache() async {
    try {
      await _localDatabase.delete(LocalDatabase.products, '1=1', []);
      await _localDatabase.delete(LocalDatabase.notifications, '1=1', []);
      await _localDatabase.delete(LocalDatabase.purchaseHistory, '1=1', []);

      return await cacheData();
    } catch (e) {
      print('Error refreshing cache: $e');
      return false;
    }
  }
}
