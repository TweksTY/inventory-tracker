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
  String? path;
  String? name;
  static const String defaultName = "";
  static const String defaultPath = "assets/images/test.jpg";
  late int value = 1;
  late DateTime dateTime;
  final TextEditingController _dateTimeController = TextEditingController();


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
                  children: [
                    GestureDetector(
                      onTap: () async {
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
                        print(result);
                      if (result == null) {
                        print("Діалог прервано");
                        return;
                      }
                      else {
                        XFile? image = await ImagePicker().pickImage(source: result == "camera" ? ImageSource.camera : ImageSource.gallery);
                        if (image == null) {
                          print("Не вдалося завантажити зображення");
                          return;
                        }
                        File tmpFile = File(image?.path ?? defaultPath);
                        String newFilePath = join(await getApplicationDocumentsDirectory().then((dir)  {return dir.path;}), '${DateTime.now().toString()}${extension(tmpFile.path)}');
                        image?.saveTo(newFilePath);
                        print(newFilePath);
                        setState(() {
                          path = newFilePath;
                        });
                      }
                      },
                      child: getImage()

                    )

                    //Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),child: Text(widget.product.name, maxLines: 2, softWrap: true,),))
                  ],
                ),
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
    if (path == null) {
      return const Image(
        height: 150,
        width: 150,
        fit: BoxFit.fitHeight,
        image: AssetImage(defaultPath),
      );
    }
    else {
      return Image.file(File(path ?? defaultPath),

        height: 150,
        width: 150,
        fit: BoxFit.fitHeight,);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dateTimeController.dispose();
  }
}