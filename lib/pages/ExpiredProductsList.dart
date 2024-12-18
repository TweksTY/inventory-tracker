
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:practice_two/methods/getImageForList.dart';

class ExpiredProductsList extends StatelessWidget {

  ExpiredProductsList({required this.entries, super.key});
  final Future<List<Entry>> entries;
  final DatabaseService db = DatabaseService.instance;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Entry>>(
        future: entries,
        builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
      if(snapshot.hasData) {
        var data = snapshot.data;
        return SafeArea(child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: getImage(data?[index].imagePath),
                  ),
                  title: Text(data?[index].name ?? "Помилка"),
                  subtitle: Text('${DateFormat("dd.MM.yyyy").format(data?[index].endDate ?? DateTime.now())}\n' 'Прострочено на: ${DateTime.utc((data?[index].endDate ?? DateTime.now()).year, (data?[index].endDate ?? DateTime.now()).month, (data?[index].endDate ?? DateTime.now()).day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays.abs()} дні')

              );},
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: data?.length ?? 0
        )
        );
      }
        else {
        return const Text('Завантаження...');
      }});

  }
}