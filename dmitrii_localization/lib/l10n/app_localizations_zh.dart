// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '本地化演示';

  @override
  String get helloWorld => '你好，世界！';

  @override
  String counterMessage(int count) {
    return '你点击了 $count 次';
  }

  @override
  String get increment => '增加';

  @override
  String get currentLanguage => '当前语言：中文';
}
