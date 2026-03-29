import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _localeKey = 'app_locale_code';
  final SharedPreferences _preferences;

  LocaleCubit(this._preferences)
    : super(Locale(_preferences.getString(_localeKey) ?? 'en'));

  Future<void> setLanguageCode(String languageCode) async {
    if (state.languageCode == languageCode) return;
    emit(Locale(languageCode));
    await _preferences.setString(_localeKey, languageCode);
  }
}
