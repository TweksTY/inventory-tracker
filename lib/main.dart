import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:practice_two/pages/RootPage.dart';



/// головна функція додатку
/// виконує попередні налаштування та запускає основну сторінку
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru_RU';
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
