class AppConstants {
  static const String appName = 'WanderMate';
  static const String defaultCity = 'Bilecik';
  static const double defaultLat = 40.1506;
  static const double defaultLng = 29.9792;

  static const List<String> searchPlaceholders = [
    "Kocaeli'de ne yenir?",
    'Yakınımdaki sakin kafeleri göster',
    "Bilecik'te tarihi yerler",
    'Kalabalık olmayan restoran bul',
    'Yağmurlu havada nereye gideyim?',
    '1 saatim var, rota öner',
    'Öğrenci bütçesiyle gezi planı',
  ];

  static const List<String> travelStyles = [
    'Sakin',
    'Popüler',
    'Aile',
    'Romantik',
    'Öğrenci',
  ];

  static const List<String> travelStyleEmojis = [
    '🌿',
    '🔥',
    '👨‍👩‍👧',
    '💑',
    '🎓',
  ];

  static const List<String> budgetOptions = ['Ekonomik', 'Orta', 'Rahat'];

  static const List<String> budgetEmojis = ['💸', '💳', '💎'];

  static const List<String> languages = ['Türkçe', 'English'];
  static const List<String> currencies = ['TRY ₺', 'USD \$', 'EUR €'];
}
