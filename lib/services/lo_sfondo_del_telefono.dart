import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

/// Dove va lo sfondo, su Android: le tre scelte della voce DO.07.
enum DoveVaLoSfondo { home, blocco, entrambe }

/// **LE DUE PIATTAFORME NON SI COMPORTANO ALLO STESSO MODO.** Ordine DO voce
/// 07, 15 settembre 2026, e va rispettato nell'interfaccia invece che
/// nascosto.
///
/// * **Android** ha l'API di sistema, `WallpaperManager`, col permesso
///   SET_WALLPAPER che non chiede conferma a schermo: [imposta] la raggiunge
///   dal canale di `MainActivity`.
/// * **iOS** non ha nessuna API per impostare lo sfondo, e non c'e'
///   scappatoia: [salvaNelleFoto] mette l'immagine nella libreria, e la
///   persona la sceglie dalle impostazioni.
///
/// **Un pulsante identico sulle due piattaforme, che su iPhone non funziona,
/// non si fa**: chi disegna la schermata chiede [puoImpostare] e mostra il
/// pulsante giusto.
class PortaDelloSfondo {
  const PortaDelloSfondo();

  static const MethodChannel _canale = MethodChannel('esoteric_circle/sfondo');

  /// Vero dove lo sfondo si imposta davvero dall'app.
  bool get puoImpostare => defaultTargetPlatform == TargetPlatform.android;

  /// Imposta [png] come sfondo. Falso se il sistema rifiuta.
  Future<bool> imposta(Uint8List png, DoveVaLoSfondo dove) async {
    try {
      return await _canale
              .invokeMethod<bool>('imposta', {'png': png, 'dove': dove.name}) ??
          false;
    } catch (errore) {
      // Il sistema che rifiuta lo sfondo si dice a video col falso: la
      // schermata scrive che il telefono non l'ha accettato.
      return false;
    }
  }

  /// Salva [png] nella libreria delle foto. Falso se la persona nega il
  /// permesso o il salvataggio non riesce.
  Future<bool> salvaNelleFoto(Uint8List png) async {
    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) return false;
      await Gal.putImageBytes(png, name: 'sigillo_dell_intenzione');
      return true;
    } catch (errore) {
      // Permesso negato o libreria piena: la schermata dice dove si concede.
      return false;
    }
  }
}
