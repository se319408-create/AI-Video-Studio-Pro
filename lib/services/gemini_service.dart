import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static Future<String> analyzeText(String text) async {
    if (text.trim().isEmpty) throw ArgumentError('Enter text to analyze.');
    final model = await _model();
    final response = await model.generateContent([Content.text('Analyze this text and summarize its subject and tone. Text: $text')]);
    return response.text?.trim() ?? 'No analysis was returned.';
  }

  static Future<String> analyzeImage({required String prompt, required String mimeType, required List<int> bytes}) async {
    if (bytes.isEmpty) throw ArgumentError('Choose an image with content.');
    final model = await _model();
    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
    ]);
    return response.text?.trim() ?? 'No analysis was returned.';
  }

  static Future<GenerativeModel> _model() async {
    final preferences = await SharedPreferences.getInstance();
    final apiKey = preferences.getString('gemini_api_key')?.trim();
    if (apiKey == null || apiKey.isEmpty) throw StateError('Add a Gemini API key in Settings to use online analysis.');
    return GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }
}