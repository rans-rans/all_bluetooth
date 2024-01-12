package com.rans_innovations.all_bluetooth_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity()
{
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "method_channel"
        ).setMethodCallHandler { call, _ ->
            when (call.method) {
                "permit" -> {
                    PermissionHandler(this).requestPermissions()
                }
            }

        }
    }
}
