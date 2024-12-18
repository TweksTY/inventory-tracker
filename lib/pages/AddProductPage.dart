import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:practice_two/models/Product.dart';
import 'package:number_selector/number_selector.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String? _path;
  String? _name;
  static const String _defaultName = "";
  static const String _defaultPath = "assets/images/default.png";
  late int value = 1;
  late DateTime dateTime;
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _BarcodeController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Додавання продукту"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Оберіть зображення:',
                  style: TextStyle(fontSize: 20)
                  ,),
                GestureDetector(
                    onTap: () async {
                      await pickImage(context);
                    },
                    child: getImage()

                )
              ]
            ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Expanded(child: TextFormField(
                        controller: _NameController,
                        decoration: const InputDecoration(
                            label: Text("Введіть ім'я"),
                            border: OutlineInputBorder()
                        ),
                      ),
                      )
                    ]
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: TextFormField(
                      controller: _BarcodeController,
                      decoration: const InputDecoration(
                          label: Text("Введіть штрихкод"),
                          border: OutlineInputBorder()
                      ),
                    ),
                    )
                  ]
              ),
            ),
            Expanded(child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                children: [
                  Expanded(child: Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 15),
              child: ElevatedButton(
                child: Text('Підтвердити'),
                onPressed: () => {print('aboba')},
              ),
            ) )

                ],
              ),
            ))



          ],
            ),
          )
      ,
    );
  }

  Widget getImage() {
    if (_path == null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.scaleDown,
            image: AssetImage(_defaultPath),
          ),
          border: Border.all(
            color: Colors.black,
            width: 5
          )
        ),
      );
    }
    else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.file(File(_path ?? _defaultPath)).image,
            ),
            border: Border.all(
                color: Colors.black,
                width: 2
            )
        ),
      );
    }
  }

  Future<void> pickImage(context) async {
    String? result = await showModalBottomSheet(context: context, elevation: 50, builder: (BuildContext context) => SizedBox(height: 300, width: double.infinity,
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
                ),),
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
            )
        )
        ]),
    ));
    if (result == null) {
      return null;
    }
    if (result == "delete") {
      setState(() {
        _path = null;
      });
      return;
    }
    else {
      XFile? image = await ImagePicker().pickImage(source: result == "camera" ? ImageSource.camera : ImageSource.gallery);
      if (image == null) {
        print("Не вдалося завантажити зображення");
        return;
      }
      File tmpFile = File(image?.path ?? _defaultPath);
      String newFilePath = join(await getApplicationDocumentsDirectory().then((dir)  {return dir.path;}), '${DateTime.now().toString()}${extension(tmpFile.path)}');
    image?.saveTo(newFilePath);
    print(newFilePath);
    setState(() {
    _path = newFilePath;
    });
  }
  }

  @override
  void dispose() {
    super.dispose();
    _NameController.dispose();
    _BarcodeController.dispose();
  }
}