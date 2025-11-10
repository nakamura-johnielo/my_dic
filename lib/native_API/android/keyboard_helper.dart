import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class KeyboardHelper {
  static const platform = MethodChannel('keyboard_helper');

  static Future<void> showKeyboard() async {
    log("==============================================");
    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('showKeyboard');
      } catch (e) {
        log("Error showing keyboard: $e");
      }
    }
  }
}
