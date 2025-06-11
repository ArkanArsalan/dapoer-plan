import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GenerateService {
  static Future<String> generate(List<String> ingredients) async {
    final res = await http.post(
      Uri.parse('$API_BASE/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['recipe'] as String;
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
