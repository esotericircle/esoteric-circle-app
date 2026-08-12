import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// LA PORTA UNICA DELLA CONDIVISIONE. Ordine P voce 28.
///
/// **Il difetto che chiude.** Tredici punti dell'app chiamavano
/// `SharePlus.instance.share` per conto loro, e tredici punti che fanno la
/// stessa cosa sono tredici occasioni di farla in modo diverso: chi metteva il
/// testo e chi no, chi gestiva l'errore e chi lo lasciava salire, chi scriveva
/// il nome del file e chi lo lasciava al caso. Non e' un problema di stile: e'
/// che nessuna regola sulla condivisione poteva essere applicata, perche' non
/// c'era un posto dove applicarla.
///
/// **Adesso il posto c'e'.** Ogni condivisione dell'app passa da qui, e
/// `test/una_sola_porta_per_condividere_test.dart` ENUMERA i chiamanti invece
/// di visitarne uno: se domani nasce la quattordicesima chiamata diretta, la
/// prova cade col nome del file.
///
/// **Cosa fa in piu' di una chiamata cruda.** Tiene l'errore invece di lasciarlo
/// salire in faccia a chi stava compiendo un rito, e dice a chi ha chiamato se
/// la cosa e' andata: `false` non e' un guasto, e' anche il caso di chi ha
/// aperto il foglio di sistema e ha cambiato idea.
class PortaDellaCondivisione {
  const PortaDellaCondivisione._();

  /// La firma comune col nome del file delle immagini condivise.
  static const String nomeDelFile = 'esoteric-circle.png';

  /// Manda del TESTO. Torna falso se la condivisione non e' partita.
  static Future<bool> testo(String cosa, {String? oggetto}) async {
    if (cosa.trim().isEmpty) return false;
    try {
      await SharePlus.instance.share(
        ShareParams(text: cosa, subject: oggetto),
      );
      return true;
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
      assert(errore is Object);
      // Non si rilancia: chi condivide sta finendo un rito, e un'eccezione
      // sopra una celebrazione e' peggio di una condivisione mancata. Chi ha
      // chiamato riceve falso e decide cosa dire.
      return false;
    }
  }

  /// Manda un FILE gia' scritto su disco, con un testo di accompagnamento.
  ///
  /// E' la forma piu' usata: le card condivisibili si compongono in memoria, si
  /// scrivono in un file temporaneo e si mandano da li'.
  static Future<bool> daFile(
    String percorso, {
    String? testo,
    String tipo = 'image/png',
  }) async {
    if (percorso.isEmpty) return false;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: testo,
          files: [XFile(percorso, mimeType: tipo)],
        ),
      );
      return true;
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
      assert(errore is Object);
      return false;
    }
  }

  /// Manda un'IMMAGINE, con un testo di accompagnamento facoltativo.
  static Future<bool> immagine(
    Uint8List byte, {
    String? testo,
    String nome = nomeDelFile,
    String tipo = 'image/png',
  }) async {
    if (byte.isEmpty) return false;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: testo,
          files: [XFile.fromData(byte, name: nome, mimeType: tipo)],
        ),
      );
      return true;
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
      assert(errore is Object);
      return false;
    }
  }
}
