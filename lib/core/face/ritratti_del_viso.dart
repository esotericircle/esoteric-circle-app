import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// **I RITRATTI DELLE LETTURE, CONSERVATI SUL TELEFONO E SU NESSUN SERVER.**
/// Ordine CX, 8 settembre 2026.
///
/// **Parole del fondatore**: *"quando andro' a vedere le scorse scansioni e
/// risultati vorro' vedere la foto del viso e non del muro"*, e poi: *"c'e' il
/// pulsante custodisci o mi costera' tanto memorizzare le foto? Se mi costera'
/// tanto, puoi tenerle memorizzate solo sul telefono e dare l'opportunita'
/// all'utente di gestirle?"*
///
/// **QUANTO COSTA, verificato nel codice prima di rispondere.** Lo scrigno dei
/// custoditi scrive in `SharedPreferences`, cioe' sul telefono, e per scelta
/// esplicita non salva nessuna immagine. Nessuna fotografia ha mai toccato un
/// server, e con questa classe continua a non toccarlo: **il costo per il
/// fondatore resta zero**, perche' il solo posto che costa e' Cloud Storage e
/// qui non c'entra.
///
/// **COSA CAMBIA DAVVERO, e va detto invece che nascosto dietro il costo.**
/// Fino a ieri la fotografia viveva quanto la schermata e poi spariva. Adesso
/// vive finche' la persona non la cancella. **Non e' una questione di soldi,
/// e' una questione di cosa l'app tiene di qualcuno**, e per questo il
/// perimetro e' scritto qui sotto in numeri invece che lasciato implicito.
///
/// **IL PERIMETRO.**
/// - Le foto si conservano per le **ultime dodici** letture, non per tutte e
///   quaranta: il testo di una lettura pesa un centinaio di byte, una foto
///   qualche centinaio di migliaia, e conservarne quaranta vorrebbe dire
///   decine di megabyte per una cosa che nessuno riguarda mai cosi' indietro.
/// - Ogni foto si riduce a **seicentoquaranta punti di larghezza** prima di
///   toccare il disco: e' la misura in cui si vede bene su uno schermo, e
///   sotto la quale non si guadagna piu' niente.
/// - **Scadono insieme al testo della loro lettura**, non prima e non dopo:
///   due scadenze diverse sullo stesso ricordo sarebbero due verita'.
/// - Si cancellano **una alla volta o tutte insieme**, e la dimenticanza del
///   telefono le porta via col resto.
///
/// **PERCHE' UNA CARTELLA E NON LA CACHE.** Lo scatto della fotocamera nasce
/// in `cache/`, che il sistema operativo puo' svuotare quando gli pare: una
/// lettura che rimanda a un file sparito mostrerebbe un riquadro vuoto senza
/// che nessuno abbia cancellato niente. I ritratti vivono nella cartella dei
/// documenti dell'app, che sparisce solo con l'app.
class RitrattiDelViso {
  const RitrattiDelViso._();

  /// Quante letture conservano la loro foto. Le piu' vecchie tengono il
  /// testo e perdono il ritratto.
  static const int quanteNeTengono = 12;

  /// La larghezza a cui si riduce ogni ritratto prima di finire su disco.
  static const int larghezzaDelRitratto = 640;

  /// La cartella dei ritratti, creata se non c'e'.
  static Future<Directory?> cartella() async {
    try {
      final documenti = await getApplicationDocumentsDirectory();
      final dir = Directory('${documenti.path}/ritratti_del_viso');
      if (!dir.existsSync()) await dir.create(recursive: true);
      return dir;
    } catch (errore) {
      // Senza cartella non si conserva niente, e la lettura resta valida
      // lo stesso: il ritratto e' un di piu', il responso no.
      debugPrint('RITRATTI DEL VISO, cartella non disponibile: $errore');
      return null;
    }
  }

  /// **CONSERVA UNO SCATTO, ridotto, e restituisce dove l'ha messo.**
  ///
  /// Nullo quando non si e' potuto conservare: chi chiama tiene la lettura
  /// senza ritratto invece di perdere tutto.
  static Future<String?> conserva(String percorsoDelloScatto,
      {required DateTime quando}) async {
    try {
      final dir = await cartella();
      if (dir == null) return null;
      final byte = await File(percorsoDelloScatto).readAsBytes();
      final codec = await ui.instantiateImageCodec(byte,
          targetWidth: larghezzaDelRitratto);
      final fotogramma = await codec.getNextFrame();
      final immagine = fotogramma.image;
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.png);
      immagine.dispose();
      codec.dispose();
      if (dati == null) return null;
      final nome = 'viso_${quando.millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$nome');
      await file.writeAsBytes(dati.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (errore) {
      debugPrint('RITRATTI DEL VISO, non conservato: $errore');
      return null;
    }
  }

  /// Cancella un ritratto. Vero se il file non c'e' piu', anche quando non
  /// c'era gia': chi cancella vuole sapere che non esiste, non chi l'ha tolto.
  static Future<bool> cancella(String? percorso) async {
    if (percorso == null || percorso.isEmpty) return true;
    try {
      final file = File(percorso);
      if (file.existsSync()) await file.delete();
      return true;
    } catch (errore) {
      debugPrint('RITRATTI DEL VISO, non cancellato: $errore');
      return false;
    }
  }

  /// **PORTA VIA TUTTO**, per la dimenticanza del telefono e per il pulsante
  /// che cancella le scorse letture in un colpo solo.
  static Future<int> cancellaTutti() async {
    try {
      final dir = await cartella();
      if (dir == null) return 0;
      var quanti = 0;
      for (final f in dir.listSync()) {
        if (f is File) {
          await f.delete();
          quanti++;
        }
      }
      return quanti;
    } catch (errore) {
      debugPrint('RITRATTI DEL VISO, pulizia fallita: $errore');
      return 0;
    }
  }
}
