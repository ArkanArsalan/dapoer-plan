import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GenerateService {
  static Future<String> generate(List<String> ingredients) async {
    final res = await http.post(
      Uri.parse('$API_BASE/generate/recipe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      // Sesuaikan key output sesuai balikannya backend
      return jsonData['result'] as String;
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
