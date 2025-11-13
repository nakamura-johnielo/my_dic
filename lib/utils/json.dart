import 'dart:convert';
import 'dart:io';
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

// Future<Map<String, dynamic>> readJsonFile(String path) async {
//   final contents = await rootBundle.loadString(path);
//   final json = jsonDecode(contents);
//   return json;

//   Map<String, dynamic> toMap(dynamic value) {
//     if (value is Map) {
//       return value.map((k, v) => MapEntry(k.toString(), toMap(v)));
//     } else {
//       return value;
//     }
//   }

//   print("json");
//   print(json);

//   return toMap(json);
// }

Future<Map<String, T>> readJsonFile2<T>(String path) async {
  final file = File(path);
  final contents = await file.readAsString();
  return jsonDecode(contents) as Map<String, T>;
}
