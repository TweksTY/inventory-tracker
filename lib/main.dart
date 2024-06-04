
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:number_selector/number_selector.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class Product {
  String name = "Product name";
  String imagePath = "assets/images/test.jpg";
  String barcode = "000000000000";

  Product(this.name, this.imagePath, this.barcode);

}

class AddedProduct extends Product {
  DateTime endDate = DateTime.now();
  int count = 0;
  int productIndex = 0;

  AddedProduct(this.endDate, this.count, this.productIndex) : super(products[productIndex].name, products[productIndex].imagePath, products[productIndex].barcode);
}
var products = List<Product>.generate(15, (index) => Product(("product$index"), "assets/images/test.jpg", "00000000000"));
var addedProducts = List<AddedProduct>.generate(5, (index) => AddedProduct(index % 2 == 0 ? DateTime.now().subtract(const Duration(days: 3)) : DateTime.now(), index*2, index));
void main() {
  Intl.defaultLocale = 'ru_RU';
  products[0].barcode = "8594001021499";
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MaterialApp( localizationsDelegates: [
    GlobalMaterialLocalizations.delegate
  ],
      supportedLocales: [
        Locale('en'),
        Locale('ru', 'RU')
      ],home:RootPage())));
}


class AddProductPage extends StatefulWidget {
  final int index;
  const AddProductPage({required this.index, super.key});

  @override
  State<StatefulWidget> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late int value = 1;
  late DateTime dateTime;
  final TextEditingController _dateTimeController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Додавання продукту"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
          child: Column(
            children: [
              Row(
                children: [
                  Image(
                    height: 150,
                    width: 150,
                    fit: BoxFit.fitHeight,
                    image: AssetImage(products[widget.index].imagePath),
                  ),
                  Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),child: Text(products[widget.index].name, maxLines: 2, softWrap: true,),))
                ],
              ),
              Row(
                children: [Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Text(('Штрихкод:\n${products[widget.index].barcode}')
                      ),
                )
                )
                ],
              ),
             const Row(
               children: [
                   Text("Кількість:"),
               ],),
              Row(
                children: [
                  IntrinsicHeight(
                    child: NumberSelector(
                      current: 1,
                      min: 1,
                      max: 1000,
                      showMinMax: false,
                      contentPadding: 10,
                      hasCenteredText: true,
                      width: 150,
                      height: 50,
                      showSuffix: false,
                      onUpdate: (int number) {
                        setState(() {
                          value = number;
                        });
                      },
                    ),
                  )
                ],
              ),
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Text("Дійсно до:"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                     //initialValue: DateFormat.yMd().format(DateTime.now()),
                     controller: _dateTimeController,
                     enabled: false,
                     showCursor: false,
                     decoration: const InputDecoration(
                       label: Text("ДД.ММ.РРРР"),
                       //enabledBorder: OutlineInputBorder(),
                       border: OutlineInputBorder()
                     ),
                    ),
                  ),
                  TextButton(onPressed: () async {
                    dateTime = await showDatePicker(context: context, locale: const Locale('ru', 'RU'), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days:5000))) ?? DateTime.now();
                    _dateTimeController.text = DateFormat("dd.MM.yyyy").format(dateTime);
                    setState(() {

                    });
                  }
                  , child: const Icon(Icons.edit_calendar))
                ],
              ),
              Row(
                children: [Expanded(child: ElevatedButton(
                  onPressed: () {
                    addedProducts.add(AddedProduct(dateTime, value, widget.index));
                    Navigator.pop(context);
                  },
                  child: const Text("Підтвердити"),
                ))],
              )
            ],
          ),
        )
        ),
      );
  }


}

Widget _getSelectedWidget(BuildContext context, int index) {
  switch(index) {
    case 0:
      // ignore: prefer_const_constructors
      return AllProductList();
    case 1:
      return ExpiredProductsList();
    case 2:
      return Text(index.toString());
  }
  return Text(index.toString());
}

class AllProductList extends StatefulWidget {
  const AllProductList({super.key});

  @override
  State<AllProductList> createState() => _AllProductListState();
}

class _AllProductListState extends State<AllProductList> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(products[index].imagePath),
                ),
                title: Text(addedProducts[index].name),
                subtitle: Text('${DateFormat("dd.MM.yyyy").format(addedProducts[index].endDate)}\n' 'Залишилось часу: ${DateTime.utc(addedProducts[index].endDate.year, addedProducts[index].endDate.month, addedProducts[index].endDate.day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}'),

            );},
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: addedProducts.length
    )
    );
  }

}

class ExpiredProductsList extends StatelessWidget {
  ExpiredProductsList({super.key});
  
  final expiredProducts = List<AddedProduct>.from(addedProducts.where((element) => DateTime.utc(element.endDate.year, element.endDate.month, element.endDate.day).difference(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays < 0));
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(expiredProducts[index].imagePath),
            ),
            title: Text(expiredProducts[index].name),
            subtitle: Text(expiredProducts[index].endDate.toLocal().toString()),

          );},
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: expiredProducts.length
    )
    );
  }
}

class EnterBarcodePage extends StatefulWidget {
  const EnterBarcodePage({super.key});

  @override
  State<EnterBarcodePage> createState() => _EnterBarcodePageState();

}

class _EnterBarcodePageState extends State<EnterBarcodePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Expanded(child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _controller,
                )),
                Expanded(child: TextButton(onPressed: () => {Navigator.pop(context, _controller.value.text)}, child: const Center(child: Text("Submit"),)))
              ],
            ))
          ],
        )
    );

  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final screenNames = <String>["Усі продукти", "Прострочені продукти", "Додавання продукту"];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenNames[currentIndex]),
      ),

      body: _getSelectedWidget(context, currentIndex),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 ? true : false,
        child: FloatingActionButton(
          onPressed: () async{
            //int productIndex = -1;
            //String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode("#000000", "Ввести вручну", true, ScanMode.BARCODE);
            //if (barcodeScanResult == (-1).toString()) {
            //  String? barcodeEnterResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EnterBarcodePage()));
            //  productIndex = products.indexWhere((element) =>  element.barcode.compareTo(barcodeEnterResult ?? "") == 0);
            //}  else {
            //  productIndex = products.indexWhere((element) =>  element.barcode.compareTo(barcodeScanResult) == 0);
            //}
            int productIndex = 0;
            if (productIndex != -1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage(index: productIndex))
              ).then((_) {setState(() {});}) ;

            }},
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "Усі продукти",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error),
            label: "Прострочені продукти",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Додати продукт",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => {
          setState(() {
          currentIndex = index;
        })},
      ),

    );
  }

}