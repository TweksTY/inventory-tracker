import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/services/DatabaseService.dart';

/// сторінка для додавання нового продукту
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final DatabaseService _db = DatabaseService.instance;
  String? _path;
  bool _isBarcodeUnique = true;
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _BarcodeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        deleteCurrentImage();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Додати продукт"),
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Оберіть зображення:',
                          style: TextStyle(fontSize: 20),
                        ),
                        GestureDetector(
                            onTap: () async {
                              await pickImage(context);
                            },
                            child: getImage(_path))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _NameController,
                            validator: (value) {if (value == null || value.isEmpty) return "Це поле обов'язково"; return null;},
                            decoration: const InputDecoration(
                                label: Text("Введіть назву"),
                                border: OutlineInputBorder()),
                          ),
                        )
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _BarcodeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Це поле обов'язково";
                              if (!_isBarcodeUnique) return "Продукт з таким штрихкодом вже існує";
                              return null;
                              },
                            onChanged: (barcode) async {
                              bool check = await isBarcodeNotUnique(barcode);
                              if (check) {
                                setState(() {
                                  _isBarcodeUnique = false;
                                });
                              }
                              else {
                                _isBarcodeUnique = true;
                              }

                            },
                            decoration: const InputDecoration(
                                label: Text("Введіть штрихкод"),
                                border: OutlineInputBorder()),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.barcode_reader),
                            onPressed: () async {
                              String barcodeScanResult =
                                  await FlutterBarcodeScanner.scanBarcode(
                                      "#000000",
                                      "Відмінити",
                                      true,
                                      ScanMode.BARCODE);
                              if (barcodeScanResult != "-1") {
                                _BarcodeController.text = barcodeScanResult;
                              }
                            })
                      ]),
                ),
                Expanded(
                    child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 50),
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textTheme: ButtonTextTheme.primary,
                          child: const Text('Підтвердити'),
                          onPressed: () async {
                            bool validationResult = formKey.currentState?.validate() ?? false;
                            if (!validationResult) {
                              return;
                            }
                              else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text("Продукт успішно додано!")));
                              _db.addProduct(Product(_NameController.text, _path, _BarcodeController.text));
                              Navigator.pop(context);
                              }

                          },
                        ),
                      ))
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// метод для надання можливості додавання нового зображення
  Future<void> pickImage(context) async {
    String? result = await showModalBottomSheet(
        context: context,
        elevation: 50,
        builder: (BuildContext context) => SizedBox(
              height: 300,
              width: double.infinity,
              child: Row(children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Text("Зробити фото"),
                        onPressed: () async {
                          Navigator.pop(context, "camera");
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Text("Обрати фото з галереї"),
                        onPressed: () async {
                          Navigator.pop(context, "gallery");
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Text("Видалити фото"),
                        onPressed: () async {
                          Navigator.pop(context, "delete");
                        },
                      ),
                    ),
                  ],
                ))
              ]),
            ));
    // якщо діалог було закрито - не робимо нічого
    if (result == null) {
      return;
    }
    // якщо користувач натиснув кнопку видалити - видаляємо зображення
    if (result == "delete") {
      deleteCurrentImage();
      return;
      /// у іншому випадку надаємо можливість обрати зображення в залежості
      /// від вибору користувача
    } else {
      XFile? image = await ImagePicker().pickImage(
          source:
              result == "camera" ? ImageSource.camera : ImageSource.gallery);
      /// якщо не вдалося обрати зображення - нічого не робимо
      if (image == null) {
        return;
      }
      /// у іншому випадку видаляємо поточне зображення та
      /// копіюємо обране зображення у директорію дотатку
      deleteCurrentImage();
      File tmpFile = File(image.path);
      String newFilePath = join(
          await getApplicationDocumentsDirectory().then((dir) {
            return dir.path;
          }),
          '${DateTime.now().toString()}${extension(tmpFile.path)}');
      image.saveTo(newFilePath);
      setState(() {
        _path = newFilePath;
      });
    }
  }

  // метод для видалення поточного зображення за його наявності
  void deleteCurrentImage() {
    if (_path != null) {
      File img = File(_path!);
      if (img.existsSync()) {
        img.deleteSync();
      }
      setState(() {
        _path = null;
      });
    }
  }


  /// функція для отримання ImageProvider в залежності від шляху
  /// вхідні дані: шлях до зображення
  /// вихідні дані: зображення за замовчуванням, якщо шлях = null,
  /// зображення, до якого веде шлях у іншому випадку
  Widget getImage(String? path) {
    if (path == null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            image: const DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/defaultAdd.png"),
            ),
            border: Border.all(color: Colors.black, width: 1)),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.file(File(path)).image,
            ),
            border: Border.all(color: Colors.black, width: 1)),
      );
    }
  }

  /// метод для перевірки наявності товару з введеним штрихкодом
  /// вхідні дані: штрихкод
  /// вихідні дані: результат перевірки
  Future<bool> isBarcodeNotUnique(String barcode) async {
    DatabaseService db = DatabaseService.instance;
    return await db.checkIfProductExists(barcode);
  }

  @override
  void dispose() {
    super.dispose();
    _NameController.dispose();
    _BarcodeController.dispose();
  }
}
