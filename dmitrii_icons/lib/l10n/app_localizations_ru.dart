// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Демо локализации';

  @override
  String get helloWorld => 'Привет, мир!';

  @override
  String counterMessage(int count) {
    return 'Вы нажали $count раз';
  }

  @override
  String get increment => 'Увеличить';

  @override
  String get currentLanguage => 'Текущий язык: русский';
}
