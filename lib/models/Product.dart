

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

  Product.fromMap(map) {
    name = map['Name'];
    imagePath = map['ImagePath'];
    barcode = map['Barcode'];
  }

  Map<String, Object?> toMap() {
    return {
      'Name' : name,
      'Barcode' : barcode,
      'ImagePath' : imagePath
    };
  }
}