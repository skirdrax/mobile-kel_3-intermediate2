import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  ApiService({http.Client? client, this.timeout = const Duration(seconds: 10)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<Map<String, dynamic>> getData() async {
    final response = await _client
        .get(Uri.parse(Config.dataUrl))
        .timeout(timeout);
    return _decode(response, 'GET /api/data');
  }

  Future<Map<String, dynamic>> getHistory({int limit = 20}) async {
    final uri = Uri.parse(
      Config.historyUrl,
    ).replace(queryParameters: {'limit': '$limit'});
    final response = await _client.get(uri).timeout(timeout);
    return _decode(response, 'GET /api/history');
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await _client
        .post(
          Uri.parse(Config.messageUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        )
        .timeout(timeout);
    return _decode(response, 'POST /api/message');
  }

  Map<String, dynamic> _decode(http.Response response, String label) {
    if (response.statusCode != 200) {
      throw Exception('$label gagal (HTTP ${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('$label mengembalikan format yang tidak dikenal');
    }
    return body;
  }

  void dispose() => _client.close();
}
