import 'package:path/path.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/models/Product.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final db = openDatabase(join(await getDatabasesPath(), 'products_db.db'),
        onCreate: (db, version) async {
      await db.execute('CREATE TABLE Products('
          'Name TEXT NOT NULL,'
          'Barcode TEXT PRIMARY KEY,'
          'ImagePath TEXT'
          ')');
      await db.execute('CREATE TABLE Entries('
          'ProductBarcode TEXT NOT NULL,'
          'EndDate TEXT NOT NULL,'
          'Qty INTEGER NOT NULL,'
          'FOREIGN KEY(ProductBarcode) REFERENCES Products(Barcode)'
          ')');
    }, version: 1);
    return db;
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert('Products', product.toMap());
  }

  Future<List<Entry>> getEntries() async {
    final db = await database;
    List<Map<String, Object?>> entries = await db.rawQuery(
        '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath, Entries.ID
        FROM Entries
        JOIN Products ON Products.Barcode = Entries.ProductBarcode;''');
    print('aboba');
    var res = [for (var map in entries) Entry.fromMap(map)];
    print('aboba');

    return res;
  }

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

  //Future<Entry> getEntry(int id) async {
  //  final db = await database;
  //  List<Map<String, Object?>> entries = await db.rawQuery(
  //      '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath, Entries.ID
  //      FROM Entries
  //      JOIN Products ON Products.Barcode = Entries.ProductBarcode
  //      WHERE Entries.ID = ?
  //      ''', [id]
  //  );
  //  return getEntriesFromMapList(entries)[0];
  //}

  Future<Product?> getProduct(String barcode) async {
    final db = await database;
    List<Map> products =
        await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    if (products.isNotEmpty) {
      return Product(products[0]['Name'], products[0]['ImagePath'],
          products[0]['Barcode']);
    } else {
      return null;
    }
  }

  Future<String> getImagePath(String barcode) async {
    final db = await database;
    var result = await db.rawQuery(
        '''SELECT ImagePath FROM Products WHERE Barcode = ?''', [barcode]);
    return result[0]['ImagePath'] as String;
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.rawQuery('''SELECT Name, ImagePath, Barcode
        FROM Products
        ORDER BY Name''');
    return [for (var product in products) Product.fromMap(product)];
  }

  Future<bool> checkIfProductExists(String barcode) async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    return products.isNotEmpty;
  }

  Future<void> addEntry(String barcode, String endDate, int qty) async {
    final db = await database;
    await db.insert(
        'Entries', {'ProductBarcode': barcode, 'EndDate': endDate, 'Qty': qty});
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('Entries', where: 'ID = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(String barcode) async {
    final db = await database;
    await db
        .delete('Entries', where: 'ProductBarcode = ?', whereArgs: [barcode]);
    await db.delete('Products', where: 'Barcode = ?', whereArgs: [barcode]);
  }

  Future<void> updateEntry(String endDate, int id, int count) async {
    final db = await database;
    await db.rawQuery(
        '''UPDATE Entries SET Qty = ?, EndDate = ? WHERE ID = ?''',
        [count, endDate, id]);
  }

  Future<void> updateProduct(Product oldProduct, Product newProduct) async {
    final db = await database;
    if (oldProduct.barcode != newProduct.barcode) {
      await db.rawQuery(
          '''INSERT INTO Products SELECT ?, ?, ? FROM Products WHERE Barcode = ?''',
          [
            newProduct.name,
            newProduct.barcode,
            newProduct.imagePath,
            oldProduct.barcode
          ]);
      await db.rawQuery(
          '''UPDATE Entries SET ProductBarcode = ? WHERE ProductBarcode = ?''',
          [newProduct.barcode, oldProduct.barcode]);
      await db.delete('Products',
          where: 'Barcode = ?', whereArgs: [oldProduct.barcode]);
    } else {
      await db.rawQuery(
          '''UPDATE Products SET Name = ?, ImagePath = ? WHERE Barcode = ?''',
          [newProduct.name, newProduct.imagePath, oldProduct.barcode]);
    }
  }
}
