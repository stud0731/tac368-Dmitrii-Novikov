// chatGPT gives us this simple localization demo

// 0. Flutter project

// 1. pubspec.yaml must have ...
//dependencies:
//  flutter:
//    sdk: flutter
//  flutter_localizations:
//    sdk: flutter
//
// 2. put this file in lib/ where you can run it.
//
// 3. run it
// > flutter pub get
// > flutter run
//
// the 'pub get' should take care of loading what you need for the imports,
// or you can do it with "> flutter pub add flutter_localizations" (I think)

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('zh'),
        Locale('ar'),
        Locale('ru'),
        Locale('pt'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final void Function(Locale) onLocaleChanged;

  const HomePage({super.key, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.helloWorld,
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  t.currentLanguage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('en')),
                  child: const Text('English'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('es')),
                  child: const Text('Español'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('zh')),
                  child: const Text('中文'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('ar')),
                  child: const Text('العربية'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('ru')),
                  child: const Text('Русский'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('pt')),
                  child: const Text('Português'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => onLocaleChanged(const Locale('fr')),
                  child: const Text('Français'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Localization Demo',
      'helloWorld': 'Hello World!',
      'currentLanguage': 'Current language: English',
    },
    'es': {
      'appTitle': 'Demostración de localización',
      'helloWorld': '¡Hola Mundo!',
      'currentLanguage': 'Idioma actual: Español',
    },
    'zh': {
      'appTitle': '本地化演示',
      'helloWorld': '你好，世界！',
      'currentLanguage': '当前语言：中文',
    },
    'ar': {
      'appTitle': 'عرض الترجمة',
      'helloWorld': 'مرحباً بالعالم!',
      'currentLanguage': 'اللغة الحالية: العربية',
    },
    'ru': {
      'appTitle': 'Демонстрация локализации',
      'helloWorld': 'Привет, мир!',
      'currentLanguage': 'Текущий язык: русский',
    },
    'pt': {
      'appTitle': 'Demonstração de localização',
      'helloWorld': 'Olá, mundo!',
      'currentLanguage': 'Idioma atual: Português',
    },
    'fr': {
      'appTitle': 'Démo de localisation',
      'helloWorld': 'Bonjour le monde !',
      'currentLanguage': 'Langue actuelle : Français',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get helloWorld => _localizedValues[locale.languageCode]!['helloWorld']!;
  String get currentLanguage =>
      _localizedValues[locale.languageCode]!['currentLanguage']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'zh', 'ar', 'ru', 'pt', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}