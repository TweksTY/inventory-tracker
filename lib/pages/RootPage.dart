import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/AddProductPage.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:practice_two/pages/AllProductList.dart';
import 'package:practice_two/pages/AddEntryPage.dart';
import 'package:practice_two/pages/ExpiredProductsList.dart';
import 'package:practice_two/pages/ProductListPage.dart';

import 'package:practice_two/pages/EnterBarcodePage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final db = DatabaseService.instance;
  final screenNames = <String>["Усі продукти", "Прострочені продукти", "Список продуктів"];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenNames[currentIndex]),
      ),

      body: _getSelectedWidget(context, currentIndex),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 || currentIndex == 2 ? true : false,
        child: FloatingActionButton(
          onPressed: () async{
            if (currentIndex == 0) {
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddEntryPage(product: result))
              ).then((_) {setState(() {});}) ;
              }
            }
            else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage())
              ).then((_) {setState(() {});}) ;
            }

            },
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu),
            label: screenNames[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.error),
            label: screenNames[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box),
            label: screenNames[2],
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
        return ProductListPage(entries: db.getProducts());
    }
    return Text(index.toString());
  }

}

