import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class DetectService {
  static Future<String?> detectLLM(String base64img) async {
    final url = Uri.parse('$API_BASE/detect/ingredient/llm');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64img}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['result'] as String?;
    } else {
      print('Error ${res.statusCode}: ${res.body}');
      return null;
    }
  }
}
