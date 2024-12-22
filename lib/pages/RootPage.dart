import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/AddEntryPage.dart';
import 'package:practice_two/pages/AddProductPage.dart';
import 'package:practice_two/pages/EnterBarcodePage.dart';
import 'package:practice_two/pages/EntryListPage.dart';
import 'package:practice_two/pages/ProductListPage.dart';
import 'package:practice_two/services/DatabaseService.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final pageController = PageController(initialPage: 0);
  final db = DatabaseService.instance;
  final screenNames = <String>[
    "Наявні продукти",
    "Прострочені продукти",
    "Усі продукти"
  ];
  late int currentIndex = 0;

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenNames[currentIndex]),
      ),
      body: PageView(
        controller: pageController,
        children: [
          EntryListPage(
            entries: db.getEntries(),
            updateFunction: update,
          ),
          EntryListPage(
            entries: db.getExpiredEntries(),
            updateFunction: update,
          ),
          ProductListPage(entries: db.getProducts(), updateFunction: update)
        ],
        onPageChanged: (int pageNumber) {
          print(pageNumber);
          setState(() {
            currentIndex = pageNumber;
          });
        },
      ),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 || currentIndex == 2 ? true : false,
        child: FloatingActionButton(
          onPressed: () async {
            if (currentIndex == 0) {
              //int productIndex = -1;
              //String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode("#000000", "Ввести вручну", true, ScanMode.BARCODE);
              //if (barcodeScanResult == (-1).toString()) {
              String? barcodeEnterResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EnterBarcodePage()));
              Product? result = await db.getProduct(barcodeEnterResult!);
              if (result != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEntryPage(product: result))).then((_) {
                  setState(() {});
                });
              }
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductPage())).then((_) {
                setState(() {});
              });
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
            print('a');
            pageController.jumpToPage(index);
            //pageController.animateToPage(index,
                //duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
            print('b');
            currentIndex = index;
          })
        },
      ),
    );
  }
}
