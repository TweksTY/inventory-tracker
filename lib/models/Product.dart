/// клас, що являє собою модель продукту
/// name - назва продукту,
/// imagePath - шлях до картинки продукту або null
/// barcode - штрихкод продукту

class Product {
  String name = "Product name";
  String? imagePath = "assets/images/test.jpg";
  String barcode = "000000000000";

  Product(this.name, this.imagePath, this.barcode);

  Product.copy(Product p) {
    name = p.name;
    imagePath = p.imagePath;
    barcode = p.barcode;
  }

  // конструктор для створення продукту з відображення
  Product.fromMap(map) {
    name = map['Name'];
    imagePath = map['ImagePath'];
    barcode = map['Barcode'];
  }

  // метод для отримання відображення з даних продукту
  Map<String, Object?> toMap() {
    return {'Name': name, 'Barcode': barcode, 'ImagePath': imagePath};
  }
}
