// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '2048 Modificado';

  @override
  String get score => 'Puntuación';

  @override
  String get highScores => 'Mejores puntuaciones';

  @override
  String get reset => 'Reiniciar';

  @override
  String get quit => 'Salir';

  @override
  String get resume => 'Continuar';

  @override
  String get gameOver => 'Fin del juego';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get quitMessage => '¿Quieres guardar esta partida o reiniciarla?';

  @override
  String get save => 'Guardar';

  @override
  String get gameSaved => 'Partida guardada';
}
