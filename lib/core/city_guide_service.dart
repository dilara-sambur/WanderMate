import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_keys.dart';

class CityGuideService {
  late GenerativeModel _model;

  CityGuideService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  /// Sehir rehberini olustur
  Future<CityGuide> getCityGuide(String city) async {
    final prompt = '''
"$city" sehri icin kapsamli bir gezi rehberi olustur. SADECE JSON don.

{
  "city": "$city",
  "intro": "sehre hakkinda 2 cumlelik giris",
  "popular_places": [
    {"name": "mekan adi", "type": "tur", "description": "kisa aciklama"}
  ],
  "what_people_do": [
    "insanlarin bu sehrde yaptigi aktiviteler (5 madde)"
  ],
  "activities": [
    "ne yapilir (3 madde)"
  ],
  "historical_places": [
    {"name": "tarihi mekan", "description": "kisa tarihi aciklama"}
  ],
  "local_food": [
    {"name": "yemek adi", "description": "kisa aciklama"}
  ],
  "trends": [
    {"title": "trend baslik", "description": "kisa aciklama"}
  ],
  "events": [
    "etkinlik onerisi (5 madde)"
  ],
  "tips": [
    "ipucu (3 madde)"
  ]
}

Her kategoriden 3-5 ornek ver. Turkce yaz. Sadece JSON.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String raw = response.text ?? '{}';
      raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = json.decode(raw) as Map<String, dynamic>;
      return CityGuide.fromJson(data);
    } catch (e) {
      return CityGuide.fallback(city);
    }
  }

  /// AI rota onerisi
  Future<List<RouteStop>> getCityRoute(String city) async {
    final prompt = '''
$city icin 3 saatlik gezi rotasi olustur.
Kafe + tarihi yer + yemek + yuruyus olsun.
4-5 durak olsun. SADECE JSON don.

{
  "route": [
    {
      "order": 1,
      "name": "mekan adi",
      "type": "kafe/restoran/muze/park",
      "duration": "sure (dk)",
      "description": "kisa aciklama"
    }
  ]
}

Sadece JSON, baska sey yazma.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String raw = response.text ?? '{}';
      raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = json.decode(raw) as Map<String, dynamic>;
      final route = data['route'] as List? ?? [];
      return route.map((e) => RouteStop.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

// ═══════════════════════════════════════
//  CITY GUIDE MODEL
// ═══════════════════════════════════════
class CityGuide {
  final String city;
  final String intro;
  final List<Map<String, String>> popularPlaces;
  final List<String> whatPeopleDo;
  final List<String> activities;
  final List<Map<String, String>> historicalPlaces;
  final List<Map<String, String>> localFood;
  final List<Map<String, String>> trends;
  final List<String> events;
  final List<String> tips;

  CityGuide({
    required this.city,
    required this.intro,
    required this.popularPlaces,
    required this.whatPeopleDo,
    required this.activities,
    required this.historicalPlaces,
    required this.localFood,
    required this.trends,
    required this.events,
    required this.tips,
  });

  factory CityGuide.fromJson(Map<String, dynamic> json) {
    return CityGuide(
      city: json['city'] ?? '',
      intro: json['intro'] ?? '',
      popularPlaces: _parseMapList(json['popular_places']),
      whatPeopleDo: _parseStringList(json['what_people_do']),
      activities: _parseStringList(json['activities']),
      historicalPlaces: _parseMapList(json['historical_places']),
      localFood: _parseMapList(json['local_food']),
      trends: _parseMapList(json['trends']),
      events: _parseStringList(json['events']),
      tips: _parseStringList(json['tips']),
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    return (data as List).map((e) => e.toString()).toList();
  }

  static List<Map<String, String>> _parseMapList(dynamic data) {
    if (data == null) return [];
    return (data as List).map((e) => Map<String, String>.from(e)).toList();
  }

  factory CityGuide.fallback(String city) {
    return CityGuide(
      city: city,
      intro: '$city sehrini kesfetmeye hazir misin?',
      popularPlaces: [],
      whatPeopleDo: ['Sehir turlari', 'Kafe ziyaretleri', 'Alisveris'],
      activities: [],
      historicalPlaces: [],
      localFood: [],
      trends: [],
      events: [],
      tips: ['Hava durumuna gore giyin'],
    );
  }
}

// ═══════════════════════════════════════
//  ROTA DURAGI MODEL
// ═══════════════════════════════════════
class RouteStop {
  final int order;
  final String name;
  final String type;
  final String duration;
  final String description;

  RouteStop({
    required this.order,
    required this.name,
    required this.type,
    required this.duration,
    required this.description,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      order: json['order'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }
}