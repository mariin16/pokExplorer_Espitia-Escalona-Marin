import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorites';

  // Obtener favoritos guardados
  static Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(_key) ?? [];

    return saved.map(int.tryParse).whereType<int>().toSet();
  }

  // Guardar lista de favoritos
  static Future<bool> saveFavorites(
    Set<int> favorites,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final list = favorites.map((id) => id.toString()).toList();

    return prefs.setStringList(_key, list);
  }
}
