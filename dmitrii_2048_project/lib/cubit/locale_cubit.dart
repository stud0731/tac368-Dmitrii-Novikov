import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';



// this cubit stores the selected app language
// HydratedCubit saves the choice after the app closes
class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void setEnglish() {
    emit(const Locale('en'));
  }

  void setSpanish() {
    emit(const Locale('es'));
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    // Load saved language
    final code = json['code'];
    if (code == 'es') {
      return const Locale('es');
    }
    return const Locale('en');
  }

  @override
  Map<String, dynamic>? toJson(Locale state) {
    // Save current language
    return {
      'code': state.languageCode,
    };
  }
}