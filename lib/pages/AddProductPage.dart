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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await pickImage(context);
                      },
                      child: getImage()

                    ),
                    Expanded(child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextFormField(
                      controller: _NameController,
                      decoration: const InputDecoration(
                          label: Text("Введіть ім'я"),
                          //enabledBorder: OutlineInputBorder(),
                          border: OutlineInputBorder()
                      ),))

                    )

                    //Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),child: Text(widget.product.name, maxLines: 2, softWrap: true,),))
                  ],
                ),
                Row(children: [
                Expanded(child: TextFormField(
                controller: _BarcodeController,
                  decoration: const InputDecoration(
                      label: Text("Введіть штрихкод"),
                      //enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder()
                  ),))
                ]),
//                Row(
//                  children: [Expanded(
//                      child: Padding(
//                        padding: const EdgeInsets.only(top: 25),
//                        child: Text(('Штрихкод:\n${widget.product.barcode}')
//                        ),
//                      )
//                  )
//                  ],
//                ),
//                const Row(
//                  children: [
//                    Text("Кількість:"),
//                  ],),
//                Row(
//                  children: [
//                    IntrinsicHeight(
//                      child: NumberSelector(
//                        current: 1,
//                        min: 1,
//                        max: 1000,
//                        showMinMax: false,
//                        contentPadding: 10,
//                        hasCenteredText: true,
//                        width: 150,
//                        height: 50,
//                        showSuffix: false,
//                        onUpdate: (int number) {
//                          setState(() {
//                            value = number;
//                          });
//                        },
//                      ),
//                    )
//                  ],
//                ),
//                const Row(
//                  children: [
//                    Padding(
//                      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
//                      child: Text("Дійсно до:"),
//                    ),
//                  ],
//                ),
//                Row(
//                  children: [
//                    Expanded(
//                      child: TextFormField(
//                        //initialValue: DateFormat.yMd().format(DateTime.now()),
//                        controller: _dateTimeController,
//                        enabled: false,
//                        showCursor: false,
//                        decoration: const InputDecoration(
//                            label: Text("Оберіть дату"),
//                            //enabledBorder: OutlineInputBorder(),
//                            border: OutlineInputBorder()
//                        ),
//                      ),
//                    ),
//                    TextButton(onPressed: () async {
//                      dateTime = await showDatePicker(context: context, locale: const Locale('ru', 'RU'), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days:5000))) ?? DateTime.now();
//                      _dateTimeController.text = DateFormat("dd.MM.yyyy").format(dateTime);
//                      setState(() {
//
//                      });
//                    }
//                        , child: const Icon(Icons.edit_calendar))
//                  ],
//                ),
//                Row(
//                  children: [Expanded(child: ElevatedButton(
//                    onPressed: () {
//                      final db = DatabaseService.instance;
//                      db.addEntry(widget.product.barcode, dateTime, value);
//                      Navigator.pop(context);
//                    },
//                    child: const Text("Підтвердити"),
//                  ))],
//                )
              ],
            ),
          )
      ),
    );
  }

  Widget getImage() {
    if (_path == null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
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
    String? result = await showModalBottomSheet(context: context, builder: (BuildContext context) => SafeArea(
      child: Row(children: [Column(
        children: [
          ElevatedButton(
            child: Text("Камера"),
            onPressed: () async {
              Navigator.pop(context, "camera");
            },
          ),
          //ElevatedButton(
          //    child: Text("Галерея")
          //)
        ],
      )]),
    ));
    if (result == null) {
      return null;
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