package com.esotericircle.esoteric_circle

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // IL MOTORE SOPRAVVIVE ALLA RICREAZIONE DELL'ATTIVITA'. Ordine DO voce 07,
    // trovato alla prova sul telefono del 15 settembre 2026.
    //
    // Impostato il Sigillo come sfondo, il sistema ricalcola i colori del
    // tema dal nuovo sfondo (ThemeOverlayController) e ricrea l'attivita':
    // e' un cambio di configurazione che il manifest non puo' dichiarare. Col
    // motore legato all'attivita', Flutter ripartiva da capo e la persona si
    // ritrovava nella home, senza la schermata del Sigillo e senza sapere se
    // lo sfondo era stato messo. Adesso il motore sta nella cache: l'attivita'
    // ricreata lo ritrova com'era. Si distrugge solo quando l'attivita' finisce
    // davvero, cosi' un'apertura nuova resta un'apertura da capo, come prima.
    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(MOTORE)?.let {
            motoreRitrovato = true
            return it
        }
        motoreRitrovato = false
        val motore = FlutterEngine(context.applicationContext)
        motore.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        cache.put(MOTORE, motore)
        return motore
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    // IL TASTO INDIETRO SI RIAGGANCIA. Col ritorno di sistema di Android 13
    // (enableOnBackInvokedCallback nel manifest) Flutter registra il suo
    // ascolto solo quando il framework dice che il suo stato e' cambiato.
    // L'attivita' ricreata nasce senza ascolto, e il framework, per cui
    // niente e' cambiato, non lo ridice: alla prova sul telefono un solo
    // indietro dopo lo sfondo chiudeva l'app invece di tornare al Libro. Se
    // il motore e' ritrovato, l'ascolto si rimette subito; il framework lo
    // corregge al primo cambio di pagina.
    private var motoreRitrovato = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (motoreRitrovato) setFrameworkHandlesBack(true)
    }

    override fun onDestroy() {
        val finisceDavvero = isFinishing
        super.onDestroy()
        if (finisceDavvero) {
            FlutterEngineCache.getInstance().get(MOTORE)?.destroy()
            FlutterEngineCache.getInstance().remove(MOTORE)
        }
    }

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
        // LO SCHERMO RESTA ACCESO NEL LIVE. Ordine EK, guasto trovato alla
        // prova sul Realme del 24 settembre 2026: il LIVE si fa parlando senza
        // toccare il telefono, e lo schermo si spegneva da solo al suo tempo,
        // cinque minuti su quel telefono, trenta secondi su molti altri. Con
        // lo schermo spento il microfono tace e il LIVE si chiude. Il segno
        // sulla finestra non chiede permessi e se ne va con la finestra.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCHERMO)
            .setMethodCallHandler { chiamata, risposta ->
                if (chiamata.method != "tieniAcceso") {
                    risposta.notImplemented()
                    return@setMethodCallHandler
                }
                val acceso = chiamata.arguments as? Boolean ?: false
                runOnUiThread {
                    if (acceso) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    risposta.success(null)
                }
            }
    }

    companion object {
        const val CANALE = "esoteric_circle/sfondo"
        const val SCHERMO = "esoteric_circle/schermo"
        const val MOTORE = "esoteric_circle/motore"
    }
}
