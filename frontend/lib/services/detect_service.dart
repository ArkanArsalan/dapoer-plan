import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';

class DetectService {
  static Future<Map<String, dynamic>> detect(File img) async {
    final bytes = await img.readAsBytes();
    // Sertakan header data sesuai base64 format
    final base64img = 'data:image/png;base64,${base64Encode(bytes)}';

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.parse('$API_BASE/detect/ingredient');
      final req = await client.postUrl(uri).timeout(const Duration(seconds: 15));
      req.headers.set('Content-Type', 'application/json');
      req.add(utf8.encode(jsonEncode({'image': base64img})));

      final resp = await req.close().timeout(const Duration(seconds: 15));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      } else {
        print('Detect error: HTTP ${resp.statusCode}');
        return {'error': 'HTTP ${resp.statusCode}'};
      }
    } on TimeoutException {
      return {'error': 'Timeout'};
    } on SocketException {
      return {'error': 'No internet'};
    } catch (e) {
      return {'error': 'Unexpected: $e'};
    } finally {
      client.close(force: true);
    }
  }
}
