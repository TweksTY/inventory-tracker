import 'package:path/path.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/models/Product.dart';
import 'package:sqflite/sqflite.dart';

// Сервіс, що допомогає в роботі з базою даних
class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  // метод, що відкриває або створює базу даних
  Future<Database> _getDatabase() async {
    final db = openDatabase(join(await getDatabasesPath(), 'products_db.db'),
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

  /// метод для додавання продуктів у базу даних
  /// вхідні дані: об'єкт класу Product, який потрібно додати
  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert('Products', product.toMap());
  }

  /// метод для отримання усіх наявних товарів
  /// вихідні дані: список об'єктів класу Entry, що були отримані з БД
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

  /// метод для отримання наявних товарів, у який пройшов строк
  /// вихідні дані: список об'єктів класу Entry, що були отримані з БД
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

  /// метод для отримання продукту за штрихкодом
  /// вхідні дані: штрихкод
  /// вихідні дані: продукт, що було знайдено, або null у іншому випадку
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

  /// метод для отримання шляху до картинки продукту
  /// вхідні дані: штрихкод
  /// вихідні дані: шлях до картинки продукту
  Future<String> getImagePath(String barcode) async {
    final db = await database;
    var result = await db.rawQuery(
        '''SELECT ImagePath FROM Products WHERE Barcode = ?''', [barcode]);
    return result[0]['ImagePath'] as String;
  }

  /// метод для отримання усіх продуктів з БД
  /// вихідні дані: список об'єктів класу Product, що були отримані з БД
  Future<List<Product>> getProducts() async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.rawQuery('''SELECT Name, ImagePath, Barcode
        FROM Products
        ORDER BY Name''');
    return [for (var product in products) Product.fromMap(product)];
  }

  /// метод для перевірки наявності продукту з деяким штрихкодом у БД
  /// вхідні дані: штрихкод
  /// вихідні дані: true у разі наявності, false у іншому випадку
  Future<bool> checkIfProductExists(String barcode) async {
    final db = await database;
    List<Map<String, Object?>> products =
        await db.query('Products', where: 'Barcode = ?', whereArgs: [barcode]);
    return products.isNotEmpty;
  }

  /// метод для додавання нового наявного продукту
  /// вхідні дані: штрихкод продукту, дата кінця строку, кількість
  Future<void> addEntry(String barcode, String endDate, int qty) async {
    final db = await database;
    await db.insert(
        'Entries', {'ProductBarcode': barcode, 'EndDate': endDate, 'Qty': qty});
  }

  /// метод для видалення наявного продукту
  /// вхідні дані: номер наявного продукту
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('Entries', where: 'ID = ?', whereArgs: [id]);
  }

  /// метод для видалення наявного продукту, в процесі також будуть видалені
  /// усі наявні продукти з таким штрихкодом
  /// вхідні дані: штрихкод
  Future<void> deleteProduct(String barcode) async {
    final db = await database;
    await db.delete('Products', where: 'Barcode = ?', whereArgs: [barcode]);
  }

  /// метод для оновлення даних про наявний продукт
  /// вхідні дані: номер продукту, дата кінця строку, кількість
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

  /// метод для оновлення даних про продукт
  /// вхідні дані: об'єкт Product, що містить старі дані про продукт, та об'єкт, що містить нові дані про продукт
  Future<void> updateProduct(Product oldProduct, Product newProduct) async {
    final db = await database;
    await db.rawUpdate('UPDATE Products SET Name = ?, Barcode = ?, ImagePath = ? WHERE Barcode = ?',
    [newProduct.name, newProduct.barcode, newProduct.imagePath, oldProduct.barcode]
    );

  }
}
