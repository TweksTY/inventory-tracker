import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_selector/number_selector.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/services/DatabaseService.dart';

/// сторінка для редагування наявного товару
/// вхідні дані: наявний продукт, що потрібно відредагувати
class EditEntryPage extends StatefulWidget {
  final Entry entry;

  const EditEntryPage({required this.entry, super.key});

  @override
  State<StatefulWidget> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  late DateTime dateTime;
  late int value;
  final TextEditingController _dateTimeController = TextEditingController();
  final db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    dateTime = widget.entry.endDate;
    _dateTimeController.text = DateFormat("dd.MM.yyyy").format(dateTime);
    value = widget.entry.qty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редагування наявного продукту"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Column(
          children: [
            Row(
              children: [
                getImage(widget.entry.imagePath),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    widget.entry.name,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Text(('Штрихкод:\n${widget.entry.barcode}')),
                ))
              ],
            ),
            const Row(
              children: [
                Text("Кількість:"),
              ],
            ),
            Row(
              children: [
                IntrinsicHeight(
                  child: NumberSelector(
                    current: value,
                    min: 1,
                    max: 1000,
                    showMinMax: false,
                    contentPadding: 10,
                    hasCenteredText: true,
                    width: 150,
                    height: 50,
                    showSuffix: false,
                    onUpdate: (int number) {
                      setState(() {
                        value = number;
                      });
                    },
                  ),
                )
              ],
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                  child: Text("Дійсно до:"),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    //initialValue: DateFormat("dd.MM.yyyy").format(widget.entry.endDate),
                    controller: _dateTimeController,
                    enabled: false,
                    showCursor: false,
                    decoration: const InputDecoration(
                        label: Text("Оберіть дату"),
                        //enabledBorder: OutlineInputBorder(),
                        border: OutlineInputBorder()),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      dateTime = (await showDatePicker(
                              context: context,
                              locale: const Locale('ru', 'RU'),
                              firstDate: DateTime.now().subtract(const Duration(days: 5)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 800))))!;
                      _dateTimeController.text =
                          DateFormat("dd.MM.yyyy").format(dateTime);
                      setState(() {});
                    },
                    child: const Icon(Icons.edit_calendar))
              ],
            ),
            Expanded(
                child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 50),
                    child: MaterialButton(
                        color: Theme.of(context).colorScheme.error,
                        textTheme: ButtonTextTheme.primary,
                        child: const Text('Видалити'),
                        onPressed: () async {
                          await db.deleteEntry(widget.entry.id);
                          Navigator.of(context).pop();
                        }),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                    child: MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        textTheme: ButtonTextTheme.primary,
                        child: const Text('Підтвердити'),
                        onPressed: () async {
                          await db.updateEntry(
                              DateFormat("y-M-d").format(dateTime),
                              widget.entry.id,
                              value);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Наявний продукт змінено!")));
                          Navigator.pop(context);
                        }),
                  )),
                ],
              ),
            ))
          ],
        ),
      )),
    );
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
              image: AssetImage("assets/images/default.png"),
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
    _dateTimeController.dispose();
  }
}
