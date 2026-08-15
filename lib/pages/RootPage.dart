import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/AddEntryPage.dart';
import 'package:practice_two/pages/AddProductPage.dart';
import 'package:practice_two/pages/EntryListPage.dart';
import 'package:practice_two/pages/ProductListPage.dart';
import 'package:practice_two/services/DatabaseService.dart';

// Page that hosts all list tabs
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final pageController = PageController(initialPage: 0);
  final db = DatabaseService.instance;
  // Titles of the sub-pages
  final screenNames = <String>[
    "In stock",
    "Expired",
    "All products"
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
          setState(() {
            currentIndex = pageNumber;
          });
        },
      ),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 || currentIndex == 2 ? true : false,
        child: FloatingActionButton(
          onPressed: () async {
            // If the current page is the in-stock list
            if (currentIndex == 0) {
              String? barcode;
              // Let the user scan a barcode
              barcode = await FlutterBarcodeScanner.scanBarcode("#000000", "Enter manually", true, ScanMode.BARCODE);
              // If scanning failed, allow manual barcode entry
              if (barcode == "-1") {
                barcode = await showBarcodeEnterDialog(context);
                // If the user closed the dialog or pressed cancel, do nothing
                if (barcode == null) {
                  return;
                }
              }
              /// Once a barcode is available, look up the matching product in the database
                Product? result = await db.getProduct(barcode);
                // If not found, notify the user
                if (result == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: const Text("No product found with this barcode.")));
                  return;
                }
                // If found, open the page for adding the product to in-stock
                else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddEntryPage(product: result))).then((_) {
                    setState(() {});
                  });
                }
              }
            // If the current page is the full product list,
            // open the page for adding a new product
            else if (currentIndex == 2) {
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
            pageController.jumpToPage(index);
            currentIndex = index;
          })
        },
      ),
    );
  }

  /// Shows a dialog for manual barcode entry and returns its result.
  /// Output: barcode, or null if the user closed the dialog or pressed cancel
  Future<String?> showBarcodeEnterDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController BarcodeController = TextEditingController();
    String? result = await showDialog<String?>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Enter barcode"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: BarcodeController,
                validator: (barcode) {
                  if (barcode == null || barcode.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                  Expanded(
                      child: TextButton(
                        child: const Text('Confirm'),
                        onPressed: () {
                          bool result = formKey.currentState?.validate() ?? false;
                          if (result) {
                            Navigator.pop(context, BarcodeController.text);
                          }
                        },
                      ))
                ],
              )
            ],
          ),
        )

        );
    });
    return result;
  }

}
