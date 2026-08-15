import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/models/Product.dart';
import 'package:sqflite/sqflite.dart';

// Service that helps work with the database
class DatabaseService {
  static Database? _db;
  static String? _databasePath;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  /// Points the singleton at a temporary database path (for unit tests).
  @visibleForTesting
  static Future<void> setUpForTest(String path) async {
    await _db?.close();
    _db = null;
    _databasePath = path;
  }

  /// Closes and clears the test database override.
  @visibleForTesting
  static Future<void> tearDownForTest() async {
    await _db?.close();
    _db = null;
    _databasePath = null;
  }

  // Opens an existing database or creates a new one
  Future<Database> _getDatabase() async {
    final path =
        _databasePath ?? join(await getDatabasesPath(), 'products_db.db');
    final db = openDatabase(path,
        onCreate: (db, version) async {
      await db.execute('CREATE TABLE Products('
          'Name TEXT NOT NULL,'
          'Barcode TEXT PRIMARY KEY,'
          'ImagePath TEXT'
          ')');
      await db.execute('CREATE TABLE Entries('
          'ID INTEGER PRIMARY KEY,'
          'ProductBarcode TEXT NOT NULL,'
          'EndDate TEXT NOT NULL,'
          'Qty INTEGER NOT NULL,'
          'FOREIGN KEY(ProductBarcode) '
            'REFERENCES Products(Barcode) '
            'ON UPDATE CASCADE '
            'ON DELETE CASCADE '
          ')');
    },
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        }, version: 1);
    return db;
  }

  String _dateOffset(int days) {
    final date = DateTime.now().add(Duration(days: days));
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Adds a product to the database.
  /// Input: Product object to insert
  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert('Products', product.toMap());
  }

  /// Returns all in-stock entries.
  /// Output: list of Entry objects loaded from the database
  Future<List<Entry>> getEntries() async {
    final db = await database;
    List<Map<String, Object?>> entries = await db.rawQuery(
        '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath, Entries.ID
        FROM Entries
        JOIN Products ON Products.Barcode = Entries.ProductBarcode
        ORDER BY Entries.EndDate;''');
    var res = [for (var map in entries) Entry.fromMap(map)];

    return res;
  }

  /// Returns in-stock entries that have already expired.
  /// Output: list of Entry objects loaded from the database
  Future<List<Entry>> getExpiredEntries() async {
    final db = await database;
    List<Map<String, Object?>> entries = await db.rawQuery(
        '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath, Entries.ID
        FROM Entries
        JOIN Products ON Products.Barcode = Entries.ProductBarcode
        WHERE Entries.EndDate < date()
        ORDER BY Entries.EndDate ASC;
        ''');
    return [for (var map in entries) Entry.fromMap(map)];
  }

  /// Looks up a product by barcode.
  /// Input: barcode
  /// Output: matching Product, or null if none found
  Future<Product?> getProduct(String barcode) async {
    final db = await database;
    List<Map> products =
        await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    if (products.isNotEmpty) {
      return Product.fromMap(products[0]);
    } else {
      return null;
    }
  }

  /// Returns the image path for a product.
  /// Input: barcode
  /// Output: product image path
  Future<String> getImagePath(String barcode) async {
    final db = await database;
    var result = await db.rawQuery(
        '''SELECT ImagePath FROM Products WHERE Barcode = ?''', [barcode]);
    return result[0]['ImagePath'] as String;
  }

  /// Returns all products from the database.
  /// Output: list of Product objects loaded from the database
  Future<List<Product>> getProducts() async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.rawQuery('''SELECT Name, ImagePath, Barcode
        FROM Products
        ORDER BY Name''');
    return [for (var product in products) Product.fromMap(product)];
  }

  /// Checks whether a product with the given barcode exists.
  /// Input: barcode
  /// Output: true if found, false otherwise
  Future<bool> checkIfProductExists(String barcode) async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    return products.isNotEmpty;
  }

  /// Adds a new in-stock entry.
  /// Input: product barcode, expiration date, quantity
  Future<void> addEntry(String barcode, String endDate, int qty) async {
    final db = await database;
    await db.insert(
        'Entries', {'ProductBarcode': barcode, 'EndDate': endDate, 'Qty': qty});
  }

  /// Deletes an in-stock entry.
  /// Input: entry id
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('Entries', where: 'ID = ?', whereArgs: [id]);
  }

  /// Deletes a product; related in-stock entries with the same barcode
  /// are removed as well (cascade).
  /// Input: barcode
  Future<void> deleteProduct(String barcode) async {
    final db = await database;
    await db.delete('Products', where: 'Barcode = ?', whereArgs: [barcode]);
  }

  /// Updates an in-stock entry.
  /// Input: entry id, expiration date, quantity
  Future<void> updateEntry(String endDate, int id, int count) async {
    final db = await database;
    await db.update('Entries', {
      'Qty' : count,
      'EndDate' : endDate,
    },
      where: 'ID = ?',
      whereArgs: [id]
    );
    
  }

  /// Updates product data.
  /// Input: Product with the previous data and Product with the new data
  Future<void> updateProduct(Product oldProduct, Product newProduct) async {
    final db = await database;
    await db.rawUpdate('UPDATE Products SET Name = ?, Barcode = ?, ImagePath = ? WHERE Barcode = ?',
    [newProduct.name, newProduct.barcode, newProduct.imagePath, oldProduct.barcode]
    );

  }
}
