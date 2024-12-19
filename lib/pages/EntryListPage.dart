import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/methods/getImageForList.dart';
import 'package:practice_two/pages/EditEntryPage.dart';
import 'package:practice_two/services/DatabaseService.dart';
class EntryListPage extends StatefulWidget {
  final Function updateFunction;
  final Future<List<Entry>> entries;
  const EntryListPage({required this.entries,required this.updateFunction, super.key});


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
          if(snapshot.hasData) {
            var data = snapshot.data;
            return SafeArea(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditEntryPage(entry: snapshot.data![index]))
                          ).then((_) {setState(() {}); widget.updateFunction();});

                        },
                        leading: CircleAvatar(

                          backgroundImage: getImage(data[index].imagePath),
                        ),
                        title: Text(data[index].name),
                        subtitle: Text(
                            'Кількість: ${data[index].qty}\n'
                                '${data[index].getDateMessage()}'),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: data!.length));
          }
          else {
            return const Text("Завантаження...");
          }
        });
  }

}