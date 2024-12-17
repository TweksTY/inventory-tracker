import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/models/Entry.dart';
import 'package:practice_two/services/DatabaseService.dart';

class AllProductList extends StatefulWidget {
  final Future<List<Entry>> entries;
  const AllProductList({required this.entries, super.key});


  @override
  State<AllProductList> createState() => _AllProductListState();
}

class _AllProductListState extends State<AllProductList> {
  final DatabaseService db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Entry>>(
        future: widget.entries,
        builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
          if(snapshot.hasData) {
            return SafeArea(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(snapshot.data?[index].imagePath ?? "Помилка"),
                        ),
                        title: Text(snapshot.data?[index].name ?? "Помилка"),
                        subtitle: Text(
                            '${DateFormat("dd.MM.yyyy").format(snapshot.data?[index].endDate ?? DateTime.now())}\n'
                            'Залишилось часу: ${DateTime.utc((snapshot.data?[index].endDate ?? DateTime.now()).year, (snapshot.data?[index].endDate ?? DateTime.now()).month, (snapshot.data?[index].endDate ?? DateTime.now()).day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}'),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: snapshot.data?.length ?? 0));
          }
          else {
            return const Text("Завантаження...");
          }
        });
//   return SafeArea(child: ListView.separated(
//       itemBuilder: (BuildContext context, int index) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: AssetImage(),
//           ),
//           title: Text(entries[index].name),
//           subtitle: Text('${DateFormat("dd.MM.yyyy").format(addedProducts[index].endDate)}\n' 'Залишилось часу: ${DateTime.utc(addedProducts[index].endDate.year, addedProducts[index].endDate.month, addedProducts[index].endDate.day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}'),

//         );},
//       separatorBuilder: (context, index) {
//         return const Divider();
//       },
//       itemCount: addedProducts.length
//   )
//   );
  }

}