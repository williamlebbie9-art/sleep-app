package com.sleeplock.app

import android.app.AppOpsManager
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "sleeploock/lock_permissions"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"openUsageAccessSettings" -> {
						startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
						result.success(true)
					}
					"openOverlaySettings" -> {
						val intent = Intent(
							Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
							android.net.Uri.parse("package:$packageName")
						)
						startActivity(intent)
						result.success(true)
					}
					"checkUsageAccessPermission" -> {
						result.success(hasUsageAccessPermission())
					}
					"checkOverlayPermission" -> {
						result.success(Settings.canDrawOverlays(this))
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun hasUsageAccessPermission(): Boolean {
		val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
		val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			appOps.unsafeCheckOpNoThrow(
				AppOpsManager.OPSTR_GET_USAGE_STATS,
				Process.myUid(),
				packageName
			)
		} else {
			appOps.checkOpNoThrow(
				AppOpsManager.OPSTR_GET_USAGE_STATS,
				Process.myUid(),
				packageName
			)
		}
		return mode == AppOpsManager.MODE_ALLOWED
	}
}
