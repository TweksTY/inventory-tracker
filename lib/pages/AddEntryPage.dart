import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:number_selector/number_selector.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:practice_two/methods/getImage.dart';


class AddEntryPage extends StatefulWidget {
  final Product product;
  const AddEntryPage({required this.product, super.key});

  @override
  State<StatefulWidget> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  late int value = 1;
  late DateTime dateTime;
  final TextEditingController _dateTimeController = TextEditingController();
  final DatabaseService db = DatabaseService.instance;
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
                    getImage(widget.product.imagePath),
                    Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),child: Text(widget.product.name, maxLines: 2, softWrap: true,),))
                  ],
                ),
                Row(
                  children: [Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text(('Штрихкод:\n${widget.product.barcode}')
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
                        current: 1,
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
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 50),
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textTheme: ButtonTextTheme.primary,
                          child: Text('Підтвердити'),
                          onPressed: () async {
                            DatabaseService db = DatabaseService.instance;
                            String result = await validateData();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                            if (result == "a") {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ) )

                    ],
                  ),
                ))
              ],
            ),
          )
      ),
    );
  }

  Future<String> validateData() async {
    if (value > 0 && _dateTimeController.text != null) {
      await db.addEntry(widget.product.barcode, DateFormat("y-M-d").format(dateTime), value);
      return "a";
    }
    else {
      return "b";
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dateTimeController.dispose();
  }
}