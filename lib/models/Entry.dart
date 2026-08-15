/// Model for an in-stock product entry.
/// name - product name
/// barcode - product barcode
/// endDate - expiration date
/// qty - quantity
/// imagePath - image path or null
/// id - entry record id
class Entry {
  String name = 'Product name';
  String barcode = '0000000';
  DateTime endDate = DateTime.now();
  int qty = 0;
  String? imagePath = "";
  int id = 0;

  Entry(this.name, this.barcode, this.endDate, this.qty,
      {required this.id, this.imagePath});

  // Constructor that builds an Entry from a database map
  // Input: map row from the query
  Entry.fromMap(Map<String, Object?> map) {
    name = map['Name'] as String;
    barcode = map['Barcode'] as String;
    endDate = DateTime.parse(map['EndDate'] as String);
    qty = map['Qty'] as int;
    imagePath = map['ImagePath'] as String?;
    id = map['ID'] as int;
  }

  /// Returns a human-readable message about how many days
  /// remain until (or past) the expiration date.
  String getDateMessage() {
    int difference = endDate.difference(DateTime.now()).inDays;
    String daysMessage = _getDays(difference.abs());
    switch (difference) {
      case 0:
        return "Expires today";
      case > 0:
        return "Expires in ${difference.abs()} $daysMessage";
      case < 0:
        return "Expired ${difference.abs()} $daysMessage ago";
      default:
        return "Unknown expiry";
    }
  }

  String _getDays(int days) {
    return days == 1 ? 'day' : 'days';
  }
}
