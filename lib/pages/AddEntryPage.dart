import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_selector/number_selector.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/services/DatabaseService.dart';

// Page for adding a product to in-stock
// Input: the product being added
class AddEntryPage extends StatefulWidget {
  final Product product;

  const AddEntryPage({required this.product, super.key});

  @override
  State<StatefulWidget> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late int value = 1;
  late DateTime dateTime;
  final TextEditingController _dateTimeController = TextEditingController();
  final DatabaseService db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add to stock"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                children: [
                  getImage(widget.product.imagePath),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      widget.product.name,
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
                    child: Text(('Barcode:\n${widget.product.barcode}')),
                  ))
                ],
              ),
              const Row(
                children: [
                  Text("Quantity:"),
                ],
              ),
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
                    child: Text("Valid until:"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: TextFormField(
                      controller: _dateTimeController,
                      validator: (date) {
                        if (date == null || date.isEmpty) {
                          return "Date is required";
                        }
                        return null;
                      },
                      enabled: false,
                      showCursor: false,
                      decoration: const InputDecoration(
                          label: Text("Select a date"),
                          //enabledBorder: OutlineInputBorder(),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                        onPressed: () async {
                          dateTime = await showDatePicker(
                                  context: context,
                                  locale: const Locale('ru', 'RU'),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 5000))) ??
                              DateTime.now();
                          _dateTimeController.text =
                              DateFormat("dd.MM.yyyy").format(dateTime);
                          setState(() {});
                        },
                        icon: const Icon(Icons.edit_calendar)),
                  )
                ],
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
                        child: const Text('Confirm'),
                        onPressed: () async {
                          bool validationResult = formKey.currentState?.validate() ?? false;
                          if (!validationResult) {
                            return;
                          }
                          await db.addEntry(
                              widget.product.barcode, DateFormat("y-M-d").format(dateTime), value);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Product added to stock!")));
                          Navigator.pop(context);
                        },
                      ),
                    ))
                  ],
                ),
              ))
            ],
          ),
        ),
      )),
    );
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
