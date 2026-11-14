import 'package:flutter/foundation.dart';

class Config {
  Config._();

  static const int port = 3000;
  static const int grpcPort = 50051;

  static String get _host {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '192.168.1.21';
    return 'localhost';
  }

  static String get baseUrl => 'http://$_host:$port';
  static String get wsUrl => 'ws://$_host:$port';

  static String get dataUrl => '$baseUrl/api/data';
  static String get historyUrl => '$baseUrl/api/history';
  static String get messageUrl => '$baseUrl/api/message';
  static String get longPollUrl => '$baseUrl/api/long-poll';
  static String get eventsUrl => '$baseUrl/api/events';
  static String get sseUrl => eventsUrl;

  static String get grpcHost => _host;
}
