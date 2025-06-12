// detect_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class DetectService {
  static Future<Map<String, dynamic>> detectThumbnail(String base64img) async {
    final url = Uri.parse('$API_BASE/detect/ingredient/llm');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64img}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      return {
        'error': 'Status ${res.statusCode}',
        'body': res.body,
      };
    }
  }
}
