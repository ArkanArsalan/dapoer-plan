import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class KatalogService {
  static Future<Map<String, dynamic>> fetchRecipes(int page, int limit) async {
    final response = await http.get(Uri.parse('$API_BASE/recipe/?limit=10&page=1'));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}

