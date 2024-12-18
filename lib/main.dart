
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:practice_two/models/Product.dart';
import 'package:practice_two/pages/RootPage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru_RU';
  DatabaseService db = DatabaseService.instance;
  Database db1 = await db.database;
  db.updateProduct(Product('aboba', null, '1234'), Product('aboba', null, '12345678'));
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MaterialApp( localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate
  ],
      supportedLocales: [
        Locale('en'),
        Locale('ru', 'RU')
      ],home:RootPage())));
}


