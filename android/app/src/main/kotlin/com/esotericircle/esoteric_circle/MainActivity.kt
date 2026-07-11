package com.esotericircle.esoteric_circle

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Activity principale.
 *
 * Espone un canale per leggere il segreto di debug di App Check direttamente
 * sul telefono, cosi' Mauro puo' copiarlo senza logcat ne' PC quando vorremo
 * attivare l'enforcement. Usa solo API Android, nessuna classe Firebase, cosi'
 * compila a prescindere dalle versioni delle librerie. Tutto e' protetto: se il
 * token non c'e' ancora, restituisce null e la UI mostra "non disponibile".
 */
class MainActivity : FlutterActivity() {
    private val channelName = "esoteric_circle/app_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDebugToken" -> result.success(readDebugToken())
                    else -> result.notImplemented()
                }
            }
    }

    private fun readDebugToken(): String? {
        return try {
            val prefsDir = File(applicationInfo.dataDir, "shared_prefs")
            val files = prefsDir.listFiles() ?: return null
            val storeFile = files.firstOrNull {
                it.name.startsWith("com.google.firebase.appcheck.debug.store") &&
                    it.name.endsWith(".xml")
            } ?: return null
            val prefsName = storeFile.name.removeSuffix(".xml")
            val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            prefs.getString("com.google.firebase.appcheck.debug.API_KEY", null)
        } catch (e: Exception) {
            null
        }
    }
}
