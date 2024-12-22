
import 'package:flutter/material.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/pages/EditEntryPage.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'dart:io';

/// Сторінка, що містить список наявних товарів
class EntryListPage extends StatefulWidget {
  // функція для оновлення батьківського віджету
  final Function updateFunction;
  final Future<List<Entry>> entries;

  const EntryListPage(
      {required this.entries, required this.updateFunction, super.key});

  @override
  State<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends State<EntryListPage> {
  DatabaseService db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Entry>>(
        future: widget.entries,
        builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            return SafeArea(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: ObjectKey(snapshot.data![index]),
                        background: Container(color: Colors.red,),
                        onDismissed: (DismissDirection direction) {
                          setState(() {
                            db.deleteEntry(snapshot.data![index].id);
                            snapshot.data?.removeAt(index);
                          });
                        },
                        confirmDismiss: (DismissDirection direction) {return openDismissDialog(context);},
                        child: ListTile(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditEntryPage(
                                        entry: snapshot.data![index]))).then((_) {
                              setState(() {});
                              widget.updateFunction();
                            });
                          },
                          leading: CircleAvatar(
                            backgroundImage: getImage(data[index].imagePath),
                          ),
                          title: Text(data[index].name),
                          subtitle: Text('Кількість: ${data[index].qty}\n'
                              '${data[index].getDateMessage()}'),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: data!.length));
          } else {
            return const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  /// метод для відкриття діалогу для видалення наявного продукту
  /// та отримання його результату
  /// вихідні дані: true якщо користувач хоче видалити продукт, false - якщо ні,
  /// null - якщо діалог було закрита
  Future<bool?> openDismissDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Підтвердження видалення"),
        content: const Text("Ви впевнені що хочете видалити цей продукт з наявних?"),
        actions: [
          TextButton(onPressed: () {Navigator.of(context).pop(false);}, child: const Text('Ні')),
          TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text('Так')),],

      );
    });
    return result;
  }

  /// функція для отримання ImageProvider в залежності від шляху
  /// вхідні дані: шлях до зображення
  /// вихідні дані: зображення за замовчуванням, якщо шлях = null,
  /// зображення, до якого веде шлях у іншому випадку
  ImageProvider getImage(String? path) {
    return path == null
        ? const AssetImage("assets/images/default.png")
        : Image.file(File(path)).image;
  }



}
