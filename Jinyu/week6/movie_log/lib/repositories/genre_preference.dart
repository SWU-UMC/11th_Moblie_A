import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference {
  GenrePreference({SharedPreferences? preferences})
      : _preferencesFuture = preferences != null ? Future.value(preferences) : SharedPreferences.getInstance();

  static const _selectedGenreKey = 'selected_genre';
  final Future<SharedPreferences> _preferencesFuture;

  Future<String> read() async {
    final prefs = await _preferencesFuture;
    return prefs.getString(_selectedGenreKey) ?? '전체';
  }

  Future<void> save(String genre) async {
    final prefs = await _preferencesFuture;
    await prefs.setString(_selectedGenreKey, genre);
  }

  Future<void> clear() async {
    final prefs = await _preferencesFuture;
    await prefs.remove(_selectedGenreKey);
  }
}
