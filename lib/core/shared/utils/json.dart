import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadBeConjugacion() async {
  final jsonString =
      await rootBundle.loadString('assets/data/be_conjugacion.json');
  return jsonDecode(jsonString);
}

Future<Map<String, dynamic>> readJsonFile(String path) async {
  final contents = await rootBundle.loadString(path);
  final json = jsonDecode(contents);

  if (json is Map<String, dynamic>) {
    return json;
  } else {
    throw Exception('JSON is not a Map: $path');
  }
}
