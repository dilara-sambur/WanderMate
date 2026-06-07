class AppStrings {
  static String tr(String key) {
    switch (key) {
      case 'explore':
        return 'Keşfet';
      case 'ai_active':
        return 'AI Aktif';
      case 'good_morning':
        return 'Günaydın';
      case 'good_day':
        return 'İyi Günler';
      case 'good_evening':
        return 'İyi Akşamlar';
      case 'weather':
        return 'Hava Durumuna Göre';
      case 'show_suggestions':
        return 'Önerileri Gör';
      default:
        return key;
    }
  }

  static String en(String key) {
    switch (key) {
      case 'explore':
        return 'Explore';
      case 'ai_active':
        return 'AI Active';
      case 'good_morning':
        return 'Good Morning';
      case 'good_day':
        return 'Good Afternoon';
      case 'good_evening':
        return 'Good Evening';
      case 'weather':
        return 'Weather Based';
      case 'show_suggestions':
        return 'Show Suggestions';
      default:
        return key;
    }
  }

  static String get(String language, String key) {
    if (language.toLowerCase().contains('english')) {
      return en(key);
    }
    return tr(key);
  }
}