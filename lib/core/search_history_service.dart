import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = 'search_history';

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();

    final history = prefs.getStringList(_key) ?? [];

    history.remove(query);
    history.insert(0, query);

    if (history.length > 10) {
      history.removeLast();
    }

    await prefs.setStringList(_key, history);
  }
}