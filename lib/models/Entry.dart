class Entry {
  String name = 'Product name';
  String barcode = '0000000';
  DateTime endDate = DateTime.now();
  int count = 0;
  String? imagePath = "";
  int id = 0;
  Entry(this.name, this.barcode, this.endDate, this.count, {required this.id, this.imagePath } );

  compareTo(Entry comparable, bool forExpired) {
    int result;
    if (forExpired) {
      result = endDate.compareTo(comparable.endDate);
      if (result == 0) {
        result = name.compareTo(comparable.name);
      }
    }
    else {
      result = name.compareTo(comparable.name);
      if (result == 0) {
        result = endDate.compareTo(comparable.endDate);
      }
    }
    return result;
  }
}