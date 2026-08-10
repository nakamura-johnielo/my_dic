// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<void> deleteMyDicIndexedDb() async {
  await html.window.indexedDB!.deleteDatabase('my_dic_db');
}
