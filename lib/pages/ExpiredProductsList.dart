
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/services/DatabaseService.dart';

class ExpiredProductsList extends StatelessWidget {

  ExpiredProductsList({required this.entries, super.key});
  final Future<List<Entry>> entries;
  final DatabaseService db = DatabaseService.instance;
  //final List<Entry> entries = db.getExpiredEntries();
  //final expiredProducts = List<AddedProduct>.from(addedProducts.where((element) => DateTime.utc(element.endDate.year, element.endDate.month, element.endDate.day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays < 0));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Entry>>(
        future: entries,
        builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
      if(snapshot.hasData) {
        return SafeArea(child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(snapshot.data?[index].imagePath ?? "Помилка"),
                  ),
                  title: Text(snapshot.data?[index].name ?? "Помилка"),
                  subtitle: Text('${DateFormat("dd.MM.yyyy").format(snapshot.data?[index].endDate ?? DateTime.now())}\n' 'Прострочено на: ${DateTime.utc((snapshot.data?[index].endDate ?? DateTime.now()).year, (snapshot.data?[index].endDate ?? DateTime.now()).month, (snapshot.data?[index].endDate ?? DateTime.now()).day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays.abs()} дні')

              );},
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: snapshot.data?.length ?? 0
        )
        );
      }
        else {
        return const Text('aboba');
      }});

  }
}