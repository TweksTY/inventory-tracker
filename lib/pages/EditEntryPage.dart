import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_selector/number_selector.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/services/DatabaseService.dart';

/// Page for editing an in-stock entry.
/// Input: the entry to edit
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
        title: const Text("Edit stock entry"),
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
                  child: Text(('Barcode:\n${widget.entry.barcode}')),
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
                  child: Text("Valid until:"),
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
                        label: Text("Select a date"),
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
                        child: const Text('Delete'),
                        onPressed: () async {
                          await db.deleteEntry(widget.entry.id);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("Product deleted!")));
                          Navigator.of(context).pop();
                        }),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                    child: MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        textTheme: ButtonTextTheme.primary,
                        child: const Text('Confirm'),
                        onPressed: () async {
                          await db.updateEntry(
                              DateFormat("y-M-d").format(dateTime),
                              widget.entry.id,
                              value);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Stock entry updated!")));
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
