import 'dart:io';

import 'package:flutter/material.dart';
import 'package:practice_two/methods/getImageForList.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/EditProductPage.dart';

class ProductListPage extends StatefulWidget {
  final Future<List<Product>> entries;
  final Function updateFunction;
  const ProductListPage({required this.entries, required this.updateFunction, super.key});


  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
        future: widget.entries,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if(snapshot.hasData) {
            var data = snapshot.data;
            return SafeArea(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductPage(product: snapshot.data![index]))
                          ).then((_) {setState(() {widget.updateFunction();});});
                          //await db.deleteEntry(data[index].id);

                        },
                        leading: CircleAvatar(
                          backgroundImage: getImage(data?[index].imagePath),
                        ),
                        title: Text(data?[index].name ?? "Помилка"),
                        subtitle: Text('Код: ${data?[index].barcode ?? "Помилка"}'),
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
  }
}