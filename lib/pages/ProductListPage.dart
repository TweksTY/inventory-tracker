import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/EditProductPage.dart';
import 'dart:io';

import 'package:practice_two/services/DatabaseService.dart';

class ProductListPage extends StatefulWidget {
  final Future<List<Product>> entries;
  final Function updateFunction;

  const ProductListPage(
      {required this.entries, required this.updateFunction, super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  DatabaseService db = DatabaseService.instance;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
        future: widget.entries,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
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
                            db.deleteProduct(snapshot.data![index].barcode);
                            snapshot.data?.removeAt(index);
                          });
                        },
                        confirmDismiss: (DismissDirection direction) {return openDismissDialog(context);},
                        child: ListTile(
                          onTap: () async {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProductPage(
                                            product: snapshot.data![index])))
                                .then((_) {
                              setState(() {
                                widget.updateFunction();
                              });
                            });
                          },
                          leading: CircleAvatar(
                            backgroundImage: getImage(data?[index].imagePath),
                          ),
                          title: Text(data?[index].name ?? "Помилка"),
                          subtitle:
                              Text('Код: ${data?[index].barcode ?? "Помилка"}'),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: snapshot.data?.length ?? 0));
          } else {
            return const Text("Завантаження...");
          }
        });
  }

  Future<bool?> openDismissDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Підтвердження видалення"),
        content: const Text("Ви впевнені що хочете видалити цей продукт? Також будуть видалені усі записи, що з ним пов'язані"),
        actions: [
          TextButton(onPressed: () {Navigator.of(context).pop(false);}, child: Text('Ні')),
          TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: Text('Так')),],

      );
    });
    return result;
  }

  getImage(String? path) {
    return path == null
        ? const AssetImage("assets/images/default.png")
        : Image.file(File(path)).image;
  }

}
