import 'dart:convert';
import 'package:http/http.dart' as http;

class KatalogService {
  static Future<Map<String, dynamic>> fetchRecipes(int page, int limit, {String? keyword}) async {
    final queryParams = {
      'limit': limit.toString(),
      'page': page.toString(),
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final uri = Uri.https('dapoer-plan.onrender.com', '/recipe', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
