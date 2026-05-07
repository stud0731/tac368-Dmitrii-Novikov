// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Modified 2048';

  @override
  String get score => 'Score';

  @override
  String get highScores => 'High Scores';

  @override
  String get reset => 'Reset';

  @override
  String get quit => 'Quit';

  @override
  String get resume => 'Resume';

  @override
  String get gameOver => 'Game Over';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get quitMessage => 'Do you want to save this game or reset it?';

  @override
  String get save => 'Save';

  @override
  String get gameSaved => 'Game saved';
}
