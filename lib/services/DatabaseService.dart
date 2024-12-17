
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:practice_two/models/Product.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';

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
    final db = openDatabase(
        join(await getDatabasesPath(), 'products_db.db'),
        onCreate:(db, version) async {
          await db.execute(
              'CREATE TABLE Products('
                  'Name TEXT NOT NULL,'
                  'Barcode TEXT PRIMARY KEY,'
                  'ImagePath TEXT'
                  ')');
          await db.execute(
              'CREATE TABLE Entries('
                  'ID INTEGER PRIMARY KEY,'
                  'ProductBarcode TEXT NOT NULL,'
                  'EndDate TEXT NOT NULL,'
                  'Qty INTEGER NOT NULL,'
                  'FOREIGN KEY(ProductBarcode) REFERENCES Products(Barcode)'
                  ')');
        },
        version : 1
    );
    return db;
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert('Products', product.toMap());

  }

  Future<List<Entry>> getEntries() async {
    final db = await database;
    List<Map<String, Object?>> entries = await db.rawQuery(
      '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath
        FROM Entries
        JOIN Products ON Products.Barcode = Entries.ProductBarcode;'''
    );
    return getEntriesFromMapList(entries);
  }

  Future<List<Entry>> getExpiredEntries() async {
    final db = await database;
    List<Map<String, Object?>> entries = await db.rawQuery(
        '''SELECT Products.Name, Products.Barcode, Entries.EndDate, Entries.Qty, Products.ImagePath
        FROM Entries
        JOIN Products ON Products.Barcode = Entries.ProductBarcode
        WHERE Entries.EndDate < date()
        ORDER BY Entries.EndDate ASC;
        '''
    );
    return getEntriesFromMapList(entries);
  }


  Future<Product?> getProduct(String barcode) async {
    final db = await database;
    List<Map> products = await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    if (products.isNotEmpty) {
      return Product(products[0]['Name'], products[0]['ImagePath'], products[0]['Barcode']);
    }
    else {
      return null;
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    List<Map<String, Object?>> products = await db.rawQuery(
        '''SELECT Name, ImagePath, Barcode
        FROM Products
        ORDER BY Name'''
    );
    return [
      for (var product in products)
        Product.fromMap(product)
    ];
  }


  Future<void> addEntry(String barcode, DateTime endDate, int qty) async {
    final db = await database;
    await db.insert('Entries', {
      'ProductBarcode' : barcode,
      'EndDate' : DateFormat("y-M-d").format(endDate),
      'Qty' : qty
    });
  }

  // TODO: Transfer to Entry class
  List<Entry> getEntriesFromMapList(List<Map<String, Object?>> entries) {
    return [
      for (final {
      'Name' : name as String,
      'Barcode' : barcode as String,
      'EndDate' : endDate as String,
      'Qty' : qty as int?,
      'ImagePath' : imagePath as String
      } in entries)
        Entry(name, barcode, DateTime.parse(endDate), qty ?? 0, imagePath)
    ];
  }
}