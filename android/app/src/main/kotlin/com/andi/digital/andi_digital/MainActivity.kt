package com.andi.digital.andi_digital

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.andi.digital.andi_digital/screenshot"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableScreenshotProtection" -> {
                    enableScreenshotProtection()
                    result.success(true)
                }
                "disableScreenshotProtection" -> {
                    disableScreenshotProtection()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun enableScreenshotProtection() {
        runOnUiThread {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
    }

    private fun disableScreenshotProtection() {
        runOnUiThread {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
