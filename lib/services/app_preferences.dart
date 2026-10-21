import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias simples guardadas en el dispositivo (no en el backend).
class AppPreferences {
  static const _autoSaveAudioKey = 'auto_save_audio';

  static Future<bool> getAutoSaveAudio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveAudioKey) ?? false;
  }

  static Future<void> setAutoSaveAudio(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveAudioKey, value);
  }
}
