import 'package:flutter/material.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/models/Product.dart';
import 'package:number_selector/number_selector.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:practice_two/methods/getImage.dart';


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
    // TODO: implement initState
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
                    Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),child: Text(widget.entry.name, maxLines: 2, softWrap: true,),))
                  ],
                ),
                Row(
                  children: [Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text(('Штрихкод:\n${widget.entry.barcode}')
                        ),
                      )
                  )
                  ],
                ),
                const Row(
                  children: [
                    Text("Кількість:"),
                  ],),
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
                            border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    TextButton(onPressed: () async {
                      dateTime = await showDatePicker(context: context, locale: const Locale('ru', 'RU'), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days:5000))) ?? DateTime.now();
                      _dateTimeController.text = DateFormat("dd.MM.yyyy").format(dateTime);
                      setState(() {

                      });
                    }
                        , child: const Icon(Icons.edit_calendar))
                  ],
                ),
                Expanded(child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 5, 50),
                        child: MaterialButton(
                            color: Theme.of(context).colorScheme.error,
                            textTheme: ButtonTextTheme.primary,
                            child: Text('Видалити'),
                            onPressed: () async {
                              await db.deleteEntry(widget.entry.id);
                              Navigator.of(context).pop();
                            }
                        ),
                      ) ),
                      Expanded(child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                        child: MaterialButton(
                            color: Theme.of(context).colorScheme.primary,
                            textTheme: ButtonTextTheme.primary,
                            child: Text('Підтвердити'),
                            onPressed: () async {
                              print(value);
                              await db.updateEntry(DateFormat("y-M-d").format(dateTime), widget.entry.id, value);
                              Navigator.pop(context);
                            }
                        ),
                      )
                      ),

                    ],
                  ),
                ))

              ],
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dateTimeController.dispose();
  }
}