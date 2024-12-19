class Entry {
  String name = 'Product name';
  String barcode = '0000000';
  DateTime endDate = DateTime.now();
  int qty = 0;
  String? imagePath = "";
  int id = 0;
  Entry(this.name, this.barcode, this.endDate, this.qty, {required this.id, this.imagePath } );

  Entry.fromMap(var map) {
    print(map);
    name = map['Name'] as String;
    barcode = map['Barcode'] as String;
    endDate = DateTime.parse(map['EndDate']);
    qty = map['Qty'] as int;
    imagePath = map['ImagePath'] as String?;
    id = map['ID'] as int;
  }

  String getDateMessage() {
    int difference = endDate.difference(DateTime.now()).inDays;
    String daysMessage = getDays(difference);
    String message;
    switch (difference) {
      case 0:
          return "Строк закінчується сьогодні";
      case >0:
        return "Строк закінчиться через ${difference} ${daysMessage}";
      default:
        return "Прострочено на ${difference} ${daysMessage}";
    }
  }

  String getDays(int days) {
    switch(days) {
      case 1: return 'день';
      case >=2 && <5: return 'дні';
      default: return 'днів';
    }
  }
}