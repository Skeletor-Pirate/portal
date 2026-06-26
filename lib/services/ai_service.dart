import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'api_service.dart';

class AiService {
  static Future<dynamic> _callAiEndpoint(String endpoint, Map<String, dynamic> payload) async {
    try {
      String baseUrl = ConfigService.aiUrl;
      if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      final uri = Uri.parse('$baseUrl$endpoint');
      final h = <String, String>{'Content-Type': 'application/json'};
      if (TokenStore.access != null) {
        h['Authorization'] = 'Bearer ${TokenStore.access}';
      }
      final res = await http.post(
        uri,
        headers: h,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 45));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      }
      throw Exception('Backend returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      throw Exception('Failed to generate AI content. Error: $e');
    }
  }

  static Future<dynamic> askDeepSeek(String prompt) {
    return _callAiEndpoint('/api/v1/tutor/chat/', {'prompt': prompt});
  }

  static Future<dynamic> generateLessonPlan(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_lesson_plan/', p);
  static Future<dynamic> generateWorksheet(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_worksheet/', p);
  static Future<dynamic> evaluateWorksheet(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/evaluate_worksheet/', p);
  static Future<dynamic> generateQuiz(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_quiz/', p);
  static Future<dynamic> generateQuestionPaper(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_question_paper/', p);
  static Future<dynamic> generateStudyNotes(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_study_notes/', p);
  static Future<dynamic> generatePresentationOutline(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_presentation_outline/', p);
  static Future<dynamic> generateRubric(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/generate_rubric/', p);
}
