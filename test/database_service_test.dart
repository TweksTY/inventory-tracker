import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late DatabaseService db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('practice_db_test_');
    await DatabaseService.setUpForTest('${tempDir.path}/products_db.db');
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await DatabaseService.tearDownForTest();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('addProduct and getProducts round-trip', () async {
    await db.addProduct(Product('Milk', null, '100'));
    await db.addProduct(Product('Bread', '/img.png', '200'));

    final products = await db.getProducts();
    expect(products.map((p) => p.name), ['Bread', 'Milk']);
    expect(await db.checkIfProductExists('100'), isTrue);
    expect(await db.checkIfProductExists('999'), isFalse);
  });

  test('getProduct returns null when barcode is missing', () async {
    expect(await db.getProduct('missing'), isNull);
  });

  test('addEntry and getEntries return joined product data', () async {
    await db.addProduct(Product('Yogurt', null, '300'));
    await db.addEntry('300', '2099-01-15', 3);

    final entries = await db.getEntries();
    expect(entries, hasLength(1));
    expect(entries.first.name, 'Yogurt');
    expect(entries.first.barcode, '300');
    expect(entries.first.qty, 3);
    expect(entries.first.endDate, DateTime.parse('2099-01-15'));
  });

  test('getExpiredEntries returns only past dates', () async {
    await db.addProduct(Product('Cheese', null, '400'));
    await db.addEntry('400', '2000-01-01', 1);
    await db.addEntry('400', '2099-12-31', 2);

    final expired = await db.getExpiredEntries();
    expect(expired, hasLength(1));
    expect(expired.first.qty, 1);
    expect(expired.first.endDate, DateTime.parse('2000-01-01'));
  });

  test('updateEntry changes quantity and expiry', () async {
    await db.addProduct(Product('Butter', null, '500'));
    await db.addEntry('500', '2099-01-01', 1);

    final id = (await db.getEntries()).first.id;
    await db.updateEntry('2099-06-01', id, 8);

    final updated = (await db.getEntries()).first;
    expect(updated.qty, 8);
    expect(updated.endDate, DateTime.parse('2099-06-01'));
  });

  test('deleteEntry removes a single stock record', () async {
    await db.addProduct(Product('Eggs', null, '600'));
    await db.addEntry('600', '2099-01-01', 1);
    await db.addEntry('600', '2099-02-01', 2);

    final id = (await db.getEntries()).first.id;
    await db.deleteEntry(id);

    expect(await db.getEntries(), hasLength(1));
    expect(await db.checkIfProductExists('600'), isTrue);
  });

  test('deleteProduct cascades to related entries', () async {
    await db.addProduct(Product('Juice', null, '700'));
    await db.addEntry('700', '2099-01-01', 4);

    await db.deleteProduct('700');

    expect(await db.getProducts(), isEmpty);
    expect(await db.getEntries(), isEmpty);
  });

  test('updateProduct renames barcode and updates name', () async {
    await db.addProduct(Product('Old', null, '800'));
    await db.addEntry('800', '2099-01-01', 1);

    await db.updateProduct(
      Product('Old', null, '800'),
      Product('New', '/new.png', '801'),
    );

    expect(await db.getProduct('800'), isNull);
    final product = await db.getProduct('801');
    expect(product?.name, 'New');
    expect(product?.imagePath, '/new.png');

    final entries = await db.getEntries();
    expect(entries, hasLength(1));
    expect(entries.first.barcode, '801');
    expect(entries.first.name, 'New');
  });
}
