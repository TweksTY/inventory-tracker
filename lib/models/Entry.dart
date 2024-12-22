/// клас, що являє собою модель наявного продукту
/// name - назва продукту
/// barcode - штрихкод продукту
/// endDate - дата закінчення строку
/// qty - кількість товару
/// imagePath - шлях до зображення або null
/// id - номер запису про наявний продукт
class Entry {
  String name = 'Product name';
  String barcode = '0000000';
  DateTime endDate = DateTime.now();
  int qty = 0;
  String? imagePath = "";
  int id = 0;

  Entry(this.name, this.barcode, this.endDate, this.qty,
      {required this.id, this.imagePath});

  Entry.fromMap(var map) {
    name = map['Name'] as String;
    barcode = map['Barcode'] as String;
    endDate = DateTime.parse(map['EndDate']);
    qty = map['Qty'] as int;
    imagePath = map['ImagePath'] as String?;
    id = map['ID'] as int;
  }

  /// метод для отримання коректного повідомлення про кількість днів,
  /// що залишилися до кінця строку
  String getDateMessage() {
    int difference = endDate.difference(DateTime.now()).inDays;
    String daysMessage = _getDays(difference.abs());
    switch (difference) {
      case 0:
        return "Строк закінчується сьогодні";
      case > 0:
        return "Строк закінчиться через ${difference.abs()} $daysMessage";
      case < 0:
        return "Прострочено на ${difference.abs()} $daysMessage";
      default:
        return "Невідомий строк";
    }
  }

  String _getDays(int days) {
    switch (days) {
      case 1:
        return 'день';
      case >= 2 && < 5:
        return 'дні';
      default:
        return 'днів';
    }
  }
}
