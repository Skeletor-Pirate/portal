import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'api_service.dart';

class AiService {
  static Future<dynamic> _callAiEndpoint(String endpoint, Map<String, dynamic> payload) async {
    // Primary: try the dedicated AI server
    String? primaryError;
    try {
      final uri = Uri.parse('${ConfigService.aiUrl}$endpoint');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (TokenStore.access != null) 'Authorization': 'Bearer ${TokenStore.access}',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      primaryError = 'AI server returned status ${res.statusCode}.';
    } catch (e) {
      primaryError = 'Could not reach AI server: $e';
    }

    // Fallback: try the main Django backend at /api/v1/tutor/<endpoint_name>/
    try {
      final endpointName = endpoint.split('/').where((s) => s.isNotEmpty).last;
      final fallbackUri = Uri.parse('${ConfigService.serverUrl}/api/v1/tutor/$endpointName/');
      final h = <String, String>{'Content-Type': 'application/json'};
      if (TokenStore.access != null) {
        h['Authorization'] = 'Bearer ${TokenStore.access}';
      }
      final res = await http.post(
        fallbackUri,
        headers: h,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 60));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    // Both failed — throw a descriptive error the UI will display in the red card
    throw Exception(
      'AI generation failed. The AI server at ${ConfigService.aiUrl} is unavailable. '
      'Please check your AI Server URL in Settings. ($primaryError)',
    );
  }

  static Future<dynamic> askDeepSeek(String prompt) {
    return _callAiEndpoint('/api/v1/tutor/chat/', {'prompt': prompt});
  }

  // All endpoints use /api/v1/tutor/ prefix to match Django URL config:
  //   core/urls.py → path('api/v1/tutor/', include('tutor.urls'))
  //   tutor/urls.py → path('generate_lesson_plan/', ...)
  static Future<dynamic> generateLessonPlan(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_lesson_plan/', p);
  static Future<dynamic> generateWorksheet(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_worksheet/', p);
  static Future<dynamic> generateQuiz(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_quiz/', p);
  static Future<dynamic> generateQuestionPaper(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_question_paper/', p);
  static Future<dynamic> generateStudyNotes(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_study_notes/', p);
  static Future<dynamic> generatePresentationOutline(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_presentation_outline/', p);
  static Future<dynamic> generateRubric(Map<String, dynamic> p) => _callAiEndpoint('/api/v1/tutor/generate_rubric/', p);
}
