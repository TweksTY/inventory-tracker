import 'package:flutter/material.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/EditProductPage.dart';
import 'dart:io';
import 'package:practice_two/services/DatabaseService.dart';

/// Page that shows the full product catalog
class ProductListPage extends StatefulWidget {
  final Future<List<Product>> entries;
  // Callback to refresh the parent widget
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
                          title: Text(data?[index].name ?? "Error"),
                          subtitle:
                              Text('Code: ${data?[index].barcode ?? "Error"}'),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: snapshot.data?.length ?? 0));
          } else {
            return const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  /// Opens a delete confirmation dialog and returns the user's choice.
  /// Output: true if the user wants to delete, false if not,
  /// null if the dialog was dismissed
  Future<bool?> openDismissDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Confirm deletion"),
        content: const Text("Are you sure you want to delete this product? All related stock entries will also be removed."),
        actions: [
          TextButton(onPressed: () {Navigator.of(context).pop(false);}, child: const Text('No')),
          TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text('Yes')),],

      );
    });
    return result;
  }
  /// Returns an ImageProvider based on the given path.
  /// Input: image path
  /// Output: default image if path is null, otherwise the image at that path
  getImage(String? path) {
    return path == null
        ? const AssetImage("assets/images/default.png")
        : Image.file(File(path)).image;
  }

}
