import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/AddEntryPage.dart';
import 'package:practice_two/pages/AddProductPage.dart';
import 'package:practice_two/pages/EntryListPage.dart';
import 'package:practice_two/pages/ProductListPage.dart';
import 'package:practice_two/services/DatabaseService.dart';

// сторінка, що містить усі списки
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final pageController = PageController(initialPage: 0);
  final db = DatabaseService.instance;
  // Список назв підсторінок
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
          setState(() {
            currentIndex = pageNumber;
          });
        },
      ),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 || currentIndex == 2 ? true : false,
        child: FloatingActionButton(
          onPressed: () async {
            // якщо поточна сторінка - список наявних продуктів
            if (currentIndex == 0) {
              String? barcode;
              // надаємо можливість відсканувати штрихкод
              barcode = await FlutterBarcodeScanner.scanBarcode("#000000", "Ввести вручну", true, ScanMode.BARCODE);
              // якщо штрихкод не вдалося відсканувати - надаємо можливість ввести його
              if (barcode == "-1") {
                barcode = await showBarcodeEnterDialog(context);
                // якщо користувач закрив діалог або нажав "відміна" - нічого не робимо
                if (barcode == null) {
                  return;
                }
              }
              /// якщо якимось чином отримали від користувача штрихкод - отримуємо
              /// відповідний товар з БД
                Product? result = await db.getProduct(barcode);
                // якщо товар не знайдено - повідомляємо користувача
                if (result == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: const Text("Продукт з таким штрихкодом не знайдено.")));
                  return;
                }
                // якщо знайдено - відкриваємо сторінку для додавання товару до наявних
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
            // якщо поточна сторінка - список усіх продуктів
            // відкриваємо сторінку для додавання нового продукту
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

  /// функція для виведення діалогу для введення штрихкоду та отримання його результату
  /// вихідні дані: штрихкод, або null якщо користувач закрив діалог або натиснув "відміна"
  Future<String?> showBarcodeEnterDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController BarcodeController = TextEditingController();
    String? result = await showDialog<String?>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Введення штрихкоду"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: BarcodeController,
                validator: (barcode) {
                  if (barcode == null || barcode.isEmpty) {
                    return "Це поле обов'язкове";
                  } else {
                    return null;
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                        child: const Text('Відміна'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                  Expanded(
                      child: TextButton(
                        child: const Text('Підтвердити'),
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
