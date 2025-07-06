// Only for mobile/desktop
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadConfig() async {
  final configStr = await rootBundle.loadString('assets/config.json');
  return jsonDecode(configStr);
}
