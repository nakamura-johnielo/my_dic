package com.my_dic

import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "keyboard_helper"
        private const val SHOW_KEYBOARD_METHOD = "showKeyboard"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    SHOW_KEYBOARD_METHOD -> {
                        val targetView = window.decorView.findFocus() ?: window.decorView
                        WindowCompat.getInsetsController(window, targetView)
                            .show(WindowInsetsCompat.Type.ime())
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
