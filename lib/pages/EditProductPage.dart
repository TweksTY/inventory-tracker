import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isBarcodeUnique = true;
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _BarcodeController = TextEditingController();
  final DatabaseService _db = DatabaseService.instance;

  @override
  void initState() {
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
          title: const Text("Edit product"),
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
                          'Choose an image:',
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
                            validator: (value) {if (value == null || value.isEmpty) return "This field is required"; return null;},
                            decoration: const InputDecoration(
                                label: Text("Enter name"),
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
                              if (value == null || value.isEmpty) return "This field is required";
                              if (!_isBarcodeUnique) return "A product with this barcode already exists";
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
                                label: Text("Enter barcode"),
                                border: OutlineInputBorder()),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.barcode_reader),
                            onPressed: () async {
                              String barcodeScanResult =
                              await FlutterBarcodeScanner.scanBarcode(
                                  "#000000",
                                  "Cancel",
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
                          Expanded(child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 0, 50),
                            child: MaterialButton(
                                color: Theme.of(context).colorScheme.error,
                                textTheme: ButtonTextTheme.primary,
                                child: Text('Delete'),
                                onPressed: () async {
                                  await _db.deleteProduct(widget.product.barcode);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text("Product deleted!")));
                                  Navigator.of(context).pop();
                                }
                            ),
                          ) ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 50),
                                child: MaterialButton(
                                  color: Theme.of(context).colorScheme.primary,
                                  textTheme: ButtonTextTheme.primary,
                                  child: const Text('Confirm'),
                                  onPressed: () async {
                                    bool validationResult = formKey.currentState?.validate() ?? false;
                                    if (!validationResult) {
                                      return;
                                    }
                                    else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text("Product updated!")));
                                      _db.updateProduct(widget.product, Product(_NameController.text, _path, _BarcodeController.text));
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

  /// Checks whether a product with the entered barcode already exists.
  /// Input: barcode
  /// Output: check result
  Future<bool> isBarcodeNotUnique(String barcode) async {
    DatabaseService db = DatabaseService.instance;
    return (barcode != widget.product.barcode && await db.checkIfProductExists(barcode)) ;
  }

  /// Lets the user add or replace a product image
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
                        child: const Text("Take a photo"),
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
                        child: const Text("Choose from gallery"),
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
                        child: const Text("Remove photo"),
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
      setState(() {
        _path = newFilePath;
      });
    }
  }

  // Deletes the original image file if it was replaced
  void deleteOriginalImage() {
    if (_path != widget.product.imagePath && widget.product.imagePath != null) {
      File img = File(widget.product.imagePath!);
      if (img.existsSync()) {
        img.deleteSync();
      }
      setState(() {});
    }
  }

  // Deletes the current image file if one exists
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

  /// Returns an image widget based on the given path.
  /// Input: image path
  /// Output: default image if path is null, otherwise the image at that path
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
