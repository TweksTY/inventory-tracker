import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/methods/getImageForList.dart';
import 'package:practice_two/pages/EditEntryPage.dart';
import 'package:practice_two/services/DatabaseService.dart';
class AllProductList extends StatefulWidget {
  final Future<List<Entry>> entries;
  final Function updateFunction;
  const AllProductList({required this.entries, required this.updateFunction, super.key});


  @override
  State<AllProductList> createState() => _AllProductListState();
}

class _AllProductListState extends State<AllProductList> {
  late Future<List<Entry>> entries;
  DatabaseService db = DatabaseService.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    entries = db.getEntries();
  }
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
                          ).then((_) {setState(() {entries = db.getEntries();}); widget.updateFunction();});
                          //await db.deleteEntry(data[index].id);

                        },
                        leading: CircleAvatar(
                          backgroundImage: getImage(data![index].imagePath),
                        ),
                        title: Text(data[index].name ?? "Помилка"),
                        subtitle: Text(
                            '${DateFormat("dd.MM.yyyy").format(data[index].endDate ?? DateTime.now())}\n'
                            'Залишилось часу: ${DateTime.utc((data[index].endDate ?? DateTime.now()).year, (data[index].endDate ?? DateTime.now()).month, (data[index].endDate ?? DateTime.now()).day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}'),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: data?.length ?? 0));
          }
          else {
            return const Text("Завантаження...");
          }
        });
  }

}