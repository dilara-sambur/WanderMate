import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<String> askGemini({
    required String prompt,
    String? cityContext,
    String? travelStyle,
    String? budget,
  }) async {
    final systemContext = '''
Sen WanderMate uygulamasının yapay zeka gezi asistanısın.
Şehir: ${cityContext ?? 'Türkiye'}
Kullanıcı gezi tarzı: ${travelStyle ?? 'Sakin'}
Bütçe tercihi: ${budget ?? 'Orta'}

Kurallar:
- Türkçe cevap ver.
- Kısa, samimi ve yardımcı ol.
- Maksimum 200 kelime yaz.
- Harita verisi uydurma.
- Eğer mekan listesi istiyorsa genel öneri ver, kesin mekanları uygulama haritada gösterecek.
''';

    final fullPrompt = '$systemContext\n\nKullanıcı sorusu: $prompt';

    try {
final response = await http
    .post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': fullPrompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 512,
        },
      }),
    )
    .timeout(const Duration(seconds: 20));


final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final candidates = data['candidates'] as List?;

        if (candidates == null || candidates.isEmpty) {
          return 'Gemini yanıt oluşturamadı. Lütfen farklı bir soru deneyin.';
        }

        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      }

      final errorMessage = data['error']?['message'] ?? 'Bilinmeyen hata';

      if (response.statusCode == 429) {
  return '''
AI kotası şu anda dolu olduğu için canlı Gemini cevabı veremiyorum.

Yine de aradığın konuya uygun yerleri haritada gösterebilirim. Aşağıdaki “Haritada Göster” butonuna basarak restoran, kafe, tarihi yer veya gezilecek noktaları görebilirsin.
''';
}

      if (response.statusCode == 403) {
        return 'Gemini erişim hatası: $errorMessage';
      }

      if (response.statusCode == 400) {
        return 'Gemini istek hatası: $errorMessage';
      }

      return 'Gemini hatası (${response.statusCode}): $errorMessage';
    } catch (e) {
      return 'Gemini bağlantı hatası: $e';
    }
  }
}