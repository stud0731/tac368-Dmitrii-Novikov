// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Demonstração de localização';

  @override
  String get helloWorld => 'Olá, mundo!';

  @override
  String counterMessage(int count) {
    return 'Você clicou $count vezes';
  }

  @override
  String get increment => 'Incrementar';

  @override
  String get currentLanguage => 'Idioma atual: Português';
}
