import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:number_selector/number_selector.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/services/DatabaseService.dart';


class AddProductPage extends StatefulWidget {
  final Product product;
  const AddProductPage({required this.product, super.key});

  @override
  State<StatefulWidget> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
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
                    Image(
                      height: 150,
                      width: 150,
                      fit: BoxFit.fitHeight,
                      image: AssetImage(widget.product.imagePath),
                    ),
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
                        //initialValue: DateFormat.yMd().format(DateTime.now()),
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
                Row(
                  children: [Expanded(child: ElevatedButton(
                    onPressed: () {
                      final db = DatabaseService.instance;
                      db.addEntry(widget.product.barcode, dateTime, value);
                      Navigator.pop(context);
                    },
                    child: const Text("Підтвердити"),
                  ))],
                )
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