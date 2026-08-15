import 'package:flutter_test/flutter_test.dart';
import 'package:practice_two/models/Entry.dart';

void main() {
  group('Entry.fromMap', () {
    test('builds an entry from a database row', () {
      final entry = Entry.fromMap({
        'Name': 'Milk',
        'Barcode': '482000000001',
        'EndDate': '2026-08-20',
        'Qty': 2,
        'ImagePath': null,
        'ID': 7,
      });

      expect(entry.name, 'Milk');
      expect(entry.barcode, '482000000001');
      expect(entry.endDate, DateTime.parse('2026-08-20'));
      expect(entry.qty, 2);
      expect(entry.imagePath, isNull);
      expect(entry.id, 7);
    });
  });

  group('Entry.getDateMessage', () {
    // Add a 1-hour buffer so inDays stays stable if the clock ticks during the test.
    DateTime inDays(int days) =>
        DateTime.now().add(Duration(days: days, hours: 1));

    DateTime daysAgo(int days) =>
        DateTime.now().subtract(Duration(days: days, hours: 1));

    test('expiry today', () {
      final entry = Entry('Milk', '1', DateTime.now(), 1, id: 1);
      expect(entry.getDateMessage(), 'Expires today');
    });

    test('days remaining with singular day', () {
      final entry = Entry('Milk', '1', inDays(1), 1, id: 1);
      expect(entry.getDateMessage(), 'Expires in 1 day');
    });

    test('days remaining with plural days', () {
      final entry = Entry('Milk', '1', inDays(3), 1, id: 1);
      expect(entry.getDateMessage(), 'Expires in 3 days');
    });

    test('how many days the product is overdue', () {
      final entry = Entry('Milk', '1', daysAgo(2), 1, id: 1);
      expect(entry.getDateMessage(), 'Expired 2 days ago');
    });
  });
}
