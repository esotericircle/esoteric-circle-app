package com.esotericircle.esoteric_circle

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // IL SIGILLO COME SFONDO DEL TELEFONO. Ordine DO voce 07, 15 settembre
    // 2026. Android ha l'API di sistema per impostare lo sfondo, col permesso
    // SET_WALLPAPER che non chiede conferma a schermo: la scelta fra Home,
    // Blocco ed Entrambe la fa la persona dentro l'app, e arriva qui come
    // "dove". L'immagine arriva gia' composta da Flutter, in PNG: qui non si
    // disegna niente, si consegna al sistema.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANALE)
            .setMethodCallHandler { chiamata, risposta ->
                if (chiamata.method != "imposta") {
                    risposta.notImplemented()
                    return@setMethodCallHandler
                }
                val png = chiamata.argument<ByteArray>("png")
                val dove = chiamata.argument<String>("dove") ?: "entrambe"
                if (png == null) {
                    risposta.error("senza_immagine", "Nessuna immagine", null)
                    return@setMethodCallHandler
                }
                // Decodificare un'immagine di 1440 per 3200 e consegnarla al
                // sistema dura quasi un secondo: fuori dal filo principale,
                // o la schermata si ferma mentre la persona aspetta.
                val principale = Handler(Looper.getMainLooper())
                Thread {
                    try {
                        val bitmap = BitmapFactory.decodeByteArray(png, 0, png.size)
                        val gestore = WallpaperManager.getInstance(applicationContext)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            val quale = when (dove) {
                                "home" -> WallpaperManager.FLAG_SYSTEM
                                "blocco" -> WallpaperManager.FLAG_LOCK
                                else -> WallpaperManager.FLAG_SYSTEM or
                                    WallpaperManager.FLAG_LOCK
                            }
                            gestore.setBitmap(bitmap, null, true, quale)
                        } else {
                            // Prima di Android 7 le due schermate non si
                            // separano: lo sfondo e' uno solo per entrambe.
                            gestore.setBitmap(bitmap)
                        }
                        principale.post { risposta.success(true) }
                    } catch (e: Exception) {
                        principale.post {
                            risposta.error("sfondo_rifiutato", e.message, null)
                        }
                    }
                }.start()
            }
    }

    companion object {
        const val CANALE = "esoteric_circle/sfondo"
    }
}
