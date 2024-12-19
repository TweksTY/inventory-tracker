import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/pages/RootPage.dart';
import 'package:practice_two/services/DatabaseService.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru_RU';
  DatabaseService db = DatabaseService.instance;
  Database db1 = await db.database;
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: [
            Locale('en'),
            Locale('ru', 'RU')
          ],
          home: RootPage())));
}
