import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Default base URL, can be overridden if using a proxy
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> translate({
    required String text,
    required String targetLanguage,
    required String apiKey,
    String? sourceLanguage,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional translator. Translate the user input directly without explanation.'
            },
            {
              'role': 'user',
              'content': 'Translate the following text ${sourceLanguage != null && sourceLanguage != "Auto Detect" ? "from $sourceLanguage " : ""}to $targetLanguage:\n\n$text'
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].toString().trim();
        }
        return 'No translation returned.';
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Error ${response.statusCode}: ${errorData['error']?['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Failed to translate: $e');
    }
  }
}
