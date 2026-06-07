import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences_model.dart';

class UserPreferencesService {
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyLanguage = 'language';
  static const String _keyCurrency = 'currency';
  static const String _keyTravelStyle = 'travel_style';
  static const String _keyBudget = 'budget';

  // TODO: Replace with Riverpod provider for production

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  Future<UserPreferencesModel> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferencesModel(
      language: prefs.getString(_keyLanguage) ?? 'Türkçe',
      currency: prefs.getString(_keyCurrency) ?? 'TRY ₺',
      travelStyle: prefs.getString(_keyTravelStyle) ?? 'Sakin',
      budget: prefs.getString(_keyBudget) ?? 'Orta',
    );
  }

  Future<void> savePreferences(UserPreferencesModel prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyLanguage, prefs.language);
    await sp.setString(_keyCurrency, prefs.currency);
    await sp.setString(_keyTravelStyle, prefs.travelStyle);
    await sp.setString(_keyBudget, prefs.budget);
  }
}
