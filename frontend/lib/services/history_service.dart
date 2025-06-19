import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import 'package:frontend/utils/constants.dart';

class HistoryService {
  static Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Token tidak valid');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  static Future<void> addHistory(String prompt, String recipe) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final payload = _parseJwt(token);
    final userId = payload['id'];

    final response = await http.post(
      Uri.parse('$API_BASE/history/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'prompt': prompt,
        'recipe': recipe,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menyimpan history: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchHistory() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final payload = _parseJwt(token);
    final userId = payload['id'];

    final res = await http.get(
      Uri.parse('$API_BASE/history/$userId'),
      headers: { 'Authorization': 'Bearer $token' }
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load history: ${res.body}');
    }
  }

static Future<void> deleteHistory(String id) async {
  final token = await SecureStorage.getToken();
  final res = await http.delete(
    Uri.parse('$API_BASE/history/$id'),
    headers: { 'Authorization': 'Bearer $token' }
  );
  if (res.statusCode != 200) {
    throw Exception('Failed to delete history');
  }
}

}
