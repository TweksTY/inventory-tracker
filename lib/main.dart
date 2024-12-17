
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:practice_two/pages/RootPage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:practice_two/services/DatabaseService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseService.instance;
  Intl.defaultLocale = 'ru_RU';

  print(await db.getEntries());
  //db.addProduct(products[0]);
  //db.addEntry(products[0].barcode, DateTime.now().subtract(const Duration(days: 3)), 25);
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MaterialApp( localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate
  ],
      supportedLocales: [
        Locale('en'),
        Locale('ru', 'RU')
      ],home:RootPage())));
}


