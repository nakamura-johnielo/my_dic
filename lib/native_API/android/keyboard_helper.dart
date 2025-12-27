import 'dart:developer';
import 'dart:io' if (dart.library.html) 'package:my_dic/core/infrastructure/database/drift/_WEB/io_stub.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardHelper {
  static const platform = MethodChannel('keyboard_helper');

  static Future<void> showKeyboard() async {
    log("==============================================");
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await platform.invokeMethod('showKeyboard');
      } catch (e) {
        log("Error showing keyboard: $e");
      }
    }
  }
}
