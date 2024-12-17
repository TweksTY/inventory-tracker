import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:practice_two/pages/AllProductList.dart';
import 'package:practice_two/pages/AddProductPage.dart';
import 'package:practice_two/pages/ExpiredProductsList.dart';
import 'package:practice_two/pages/EnterBarcodePage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final db = DatabaseService.instance;
  final screenNames = <String>["Усі продукти", "Прострочені продукти", "Додавання продукту"];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenNames[currentIndex]),
      ),

      body: _getSelectedWidget(context, currentIndex),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 ? true : false,
        child: FloatingActionButton(
          onPressed: () async{
            //int productIndex = -1;
            //String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode("#000000", "Ввести вручну", true, ScanMode.BARCODE);
            //if (barcodeScanResult == (-1).toString()) {
            //  String? barcodeEnterResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EnterBarcodePage.dart()));
            //  productIndex = products.indexWhere((element) =>  element.barcode.compareTo(barcodeEnterResult ?? "") == 0);
            //}  else {
            //  productIndex = products.indexWhere((element) =>  element.barcode.compareTo(barcodeScanResult) == 0);
            //}
            Product? result = await db.getProduct('8594001021499');
            if (result != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage(product: result))
              ).then((_) {setState(() {});}) ;

            }},
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "Усі продукти",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error),
            label: "Прострочені продукти",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Додати продукт",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => {
          setState(() {
            currentIndex = index;
          })},
      ),

    );
  }


  Widget _getSelectedWidget(BuildContext context, int index) {
    switch(index) {
      case 0:
        return AllProductList(entries: db.getEntries(),);
      case 1:
        return ExpiredProductsList(entries: db.getExpiredEntries());
      case 2:
        return Text(index.toString());
    }
    return Text(index.toString());
  }
}

