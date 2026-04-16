// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عرض الترجمة';

  @override
  String get helloWorld => 'مرحباً بالعالم!';

  @override
  String counterMessage(int count) {
    return 'لقد نقرت $count مرات';
  }

  @override
  String get increment => 'زيادة';

  @override
  String get currentLanguage => 'اللغة الحالية: العربية';
}
