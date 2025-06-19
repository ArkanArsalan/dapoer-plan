import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../storage/secure_storage.dart';
import '../utils/constants.dart';

class AuthResponse {
  final String token;
  final User user;
  AuthResponse({required this.token, required this.user});
}

class AuthService {
  static Future<AuthResponse?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$API_BASE/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final token = data['token'] as String;
      final user = User.fromJson(data['userFound']);  // ambil userFound
      await SecureStorage.saveToken(token);
      return AuthResponse(token: token, user: user);
    }
    return null;
  }



  static Future<AuthResponse?> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$API_BASE/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final user = User.fromJson(data);
      return AuthResponse(token: '', user: user);
    }
    return null;
  }



  static Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}
