import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/services/DatabaseService.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({required this.product, super.key});

  @override
  State<StatefulWidget> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  String? _path;
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _BarcodeController = TextEditingController();
  final DatabaseService db = DatabaseService.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _NameController.text = widget.product.name;
    _BarcodeController.text = widget.product.barcode;
    _path = widget.product.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        deleteCurrentImage();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Редагування продукту"),
        ),
        body: SafeArea(
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
                          decoration: const InputDecoration(
                              label: Text("Введіть штрихкод"),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.barcode_reader),
                        onPressed: () async {
                          String barcodeScanResult =
                              await FlutterBarcodeScanner.scanBarcode("#000000",
                                  "Відмінити", true, ScanMode.BARCODE);
                          if (barcodeScanResult != "-1") {
                            _BarcodeController.text = barcodeScanResult;
                          }
                        },
                      )
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
                          color: Theme.of(context).colorScheme.error,
                          textTheme: ButtonTextTheme.primary,
                          child: const Text('Видалити'),
                          onPressed: () async {
                            await db.deleteProduct(widget.product.barcode);
                            Navigator.of(context).pop();
                          }),
                    )),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 50),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        textTheme: ButtonTextTheme.primary,
                        child: const Text('Підтвердити'),
                        onPressed: () async {
                          String result = await validateData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(result)));
                          if (result == "Дані про продукт успішно оновлено!") {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    )),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

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
    if (result == null) {
      return;
    }
    if (result == "delete") {
      deleteCurrentImage();
      return;
    } else {
      XFile? image = await ImagePicker().pickImage(
          source:
              result == "camera" ? ImageSource.camera : ImageSource.gallery);
      if (image == null) {
        print("Не вдалося завантажити зображення");
        return;
      }
      deleteCurrentImage();
      File tmpFile = File(image.path);
      String newFilePath = join(
          await getApplicationDocumentsDirectory().then((dir) {
            return dir.path;
          }),
          '${DateTime.now().toString()}${extension(tmpFile.path)}');
      image.saveTo(newFilePath);
      print(newFilePath);
      setState(() {
        _path = newFilePath;
      });
    }
  }

  void deleteOriginalImage() {
    if (_path != widget.product.imagePath && widget.product.imagePath != null) {
      File img = File(widget.product.imagePath!);
      if (img.existsSync()) {
        img.deleteSync();
      }
      setState(() {});
    }
  }

  void deleteCurrentImage() {
    if (_path == widget.product.imagePath) {
      setState(() {
        _path = null;
      });
    }
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

  Future<String> validateData() async {
    String name = _NameController.text;
    String barcode = _BarcodeController.text;
    if (name == "") {
      return "Помилка. Некоректне ім'я продукта";
    }
    if (barcode == "") {
      return "Помилка. Поле штрихкоду порожнє";
    }
    if (barcode != widget.product.barcode &&
        await db.checkIfProductExists(barcode)) {
      return 'Помилка. Товар з таким штрихкодом вже існує';
    } else {
      await db.updateProduct(widget.product, Product(name, _path, barcode));
      deleteOriginalImage();
      return "Дані про продукт успішно оновлено!";
    }
  }

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


  @override
  void dispose() {
    super.dispose();
    _NameController.dispose();
    _BarcodeController.dispose();
  }
}
