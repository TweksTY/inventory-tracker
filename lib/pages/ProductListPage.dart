import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';

class ProductListPage extends StatefulWidget {
  final Future<List<Product>> entries;
  const ProductListPage({required this.entries, super.key});


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
            return SafeArea(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(snapshot.data?[index].imagePath ?? "Помилка"),
                        ),
                        title: Text(snapshot.data?[index].name ?? "Помилка"),
                        subtitle: Text('Код: ${snapshot.data?[index].barcode ?? "Помилка"}'),
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