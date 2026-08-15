/// Model for a product in the catalog.
/// name - product name
/// imagePath - path to the product image or null
/// barcode - product barcode

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

  // Constructor that builds a Product from a database map
  Product.fromMap(map) {
    name = map['Name'];
    imagePath = map['ImagePath'];
    barcode = map['Barcode'];
  }

  // Converts product data to a map for database insertion
  Map<String, Object?> toMap() {
    return {'Name': name, 'Barcode': barcode, 'ImagePath': imagePath};
  }
}
