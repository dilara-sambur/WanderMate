import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String description;
  final double temperature;
  final String iconCode;
  final String cityName;

  const WeatherData({
    required this.description,
    required this.temperature,
    required this.iconCode,
    required this.cityName,
  });

  String get weatherEmoji {
    if (iconCode.startsWith('01')) return '☀️';
    if (iconCode.startsWith('02') || iconCode.startsWith('03')) return '⛅';
    if (iconCode.startsWith('04')) return '☁️';
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return '🌧️';
    if (iconCode.startsWith('11')) return '⛈️';
    if (iconCode.startsWith('13')) return '❄️';
    return '🌤️';
  }
}

class WeatherService {
  final String apiKey;
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  WeatherService({required this.apiKey});

  Future<WeatherData?> getWeather({
    required double lat,
    required double lng,
  }) async {
    // TODO: Replace with production weather API call
    // Demo fallback weather data
    try {
      if (apiKey == 'ca5e5b715d7ffb9e8ada754af9c21926' || apiKey.isEmpty) {
        return const WeatherData(
          description: 'Parçalı Bulutlu',
          temperature: 22.0,
          iconCode: '02d',
          cityName: 'Bilecik',
        );
      }

      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=tr',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData(
          description: data['weather'][0]['description'] as String,
          temperature: (data['main']['temp'] as num).toDouble(),
          iconCode: data['weather'][0]['icon'] as String,
          cityName: data['name'] as String,
        );
      }
    } catch (_) {}
    return const WeatherData(
      description: 'Parçalı Bulutlu',
      temperature: 22.0,
      iconCode: '02d',
      cityName: 'Bilecik',
    );
  }
}
