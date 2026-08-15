import 'package:flutter_test/flutter_test.dart';
import 'package:practice_two/models/Product.dart';

void main() {
  group('Product', () {
    test('toMap serializes fields for SQLite', () {
      final product = Product('Bread', '/tmp/bread.jpg', '482000000010');

      expect(product.toMap(), {
        'Name': 'Bread',
        'Barcode': '482000000010',
        'ImagePath': '/tmp/bread.jpg',
      });
    });

    test('fromMap builds a product from a database row', () {
      final product = Product.fromMap({
        'Name': 'Juice',
        'Barcode': '482000000020',
        'ImagePath': null,
      });

      expect(product.name, 'Juice');
      expect(product.barcode, '482000000020');
      expect(product.imagePath, isNull);
    });

  });
}
