import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _answersKey = 'gemini_answer_cache';

  Future<String?> getAnswer(String question) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(_answersKey);

    if (cacheString == null) return null;

    final Map<String, dynamic> cache = jsonDecode(cacheString);
    final key = _normalize(question);

    return cache[key]?.toString();
  }

  Future<void> saveAnswer(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(_answersKey);

    Map<String, dynamic> cache = {};

    if (cacheString != null) {
      cache = jsonDecode(cacheString);
    }

    final key = _normalize(question);
    cache[key] = answer;

    await prefs.setString(_answersKey, jsonEncode(cache));
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_answersKey);
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}