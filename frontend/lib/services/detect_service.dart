import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';

class DetectService {
  static Future<Map<String, dynamic>> detect(File img) async {
    final base64img = base64Encode(await img.readAsBytes());
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.parse('$API_BASE/detect');
      final req = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 15));
      req.headers.set('Content-Type', 'application/json');
      req.add(utf8.encode(jsonEncode({'base64image': base64img})));

      final resp = await req.close().timeout(const Duration(seconds: 15));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      } else {
        print('Detect error: HTTP ${resp.statusCode}');
        return {'error': 'HTTP ${resp.statusCode}'};
      }
    } on TimeoutException {
      print('Detect error: Timeout');
      return {'error': 'Timeout'};
    } on SocketException {
      print('Detect error: Network issue');
      return {'error': 'No internet'};
    } catch (e) {
      print('Detect unexpected error: $e');
      return {'error': 'Unexpected'};
    } finally {
      client.close(force: true);
    }
  }
}
