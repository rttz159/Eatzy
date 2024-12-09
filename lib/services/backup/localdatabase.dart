import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._();
  Database? _database;
  LocalDatabase._();
  static const String products = "products";
  static const String notifications = "notifications";
  static const String purchaseHistory = "purchasehistory";

  factory LocalDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cacheDatabase.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT,
          subId INTEGER,
          description TEXT,
          sellingPrice REAL,
          costPrice REAL,
          qty INTEGER,
          lastUpdated INTEGER
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT,
          description TEXT,
          sellerId TEXT,
          userId TEXT,
          lastUpdated INTEGER
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS purchasehistory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT,
          voucherId INTEGER,
          userId TEXT,
          prodId INTEGER,
          qty INTEGER,
          purchaseDate TEXT,
          lastUpdated INTEGER
        )
      ''');
      },
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, String where,
      List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
      String table, String? where, List<dynamic>? whereArgs) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> replaceRecords(
      String table, List<Map<String, dynamic>> records) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var record in records) {
        final firebaseId = record['firebaseId'];
        final existing = await txn.query(
          table,
          where: 'firebaseId = ?',
          whereArgs: [firebaseId],
        );
        if (existing.isNotEmpty) {
          await txn.update(
            table,
            record,
            where: 'firebaseId = ?',
            whereArgs: [firebaseId],
          );
        } else {
          await txn.insert(table, record);
        }
      }
    });
  }
}
