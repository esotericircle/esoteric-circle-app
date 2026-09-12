import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import '../misura/misura_del_ritorno.dart';
import '../misura/registro_del_ritorno.dart';

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

  /// **DOVE E' ANDATA L'ULTIMA CONDIVISIONE, e vive un istante. Ordine BX
  /// voce 10.**
  ///
  /// Il corpus chiede "mandi un responso a qualcuno in privato, non al
  /// mondo", e per tre voci, una per Maestro. Il foglio di sistema non
  /// chiede alla persona che canale sia: dice pero' QUALE APPLICAZIONE ha
  /// ricevuto, in `ShareResult.raw`, e da li' il canale si legge.
  ///
  /// **Sta qui e non in un valore di ritorno** perche' i dodici chiamanti
  /// leggono un booleano: cambiargli la firma vorrebbe dire toccare dodici
  /// scene per un dato che serve a una riga sola. Lo si scrive qui e lo si
  /// legge subito dopo, nel premio, che e' l'unico a chiederlo.
  static String? ultimoBersaglio;

  /// **IL CANALE, dedotto da chi ha ricevuto.** Le famiglie sono dichiarate
  /// qui e non indovinate ogni volta: i messaggeri sono privati, le piazze
  /// sono pubbliche, e cio' che non si riconosce resta ignoto invece di
  /// essere contato per una delle due. **Non sapere non e' sapere**, ed e'
  /// la stessa prudenza con cui questa porta tratta `unavailable`.
  static const Map<String, List<String>> canaliRiconosciuti = {
    'privato': [
      'whatsapp',
      'telegram',
      'signal',
      'messenger',
      'mms',
      'sms',
      'messages',
      'gmail',
      'mail',
      'outlook',
      'threema',
      'viber',
      'discord',
      'slack',
    ],
    'pubblico': [
      'instagram',
      'facebook',
      'twitter',
      'x.',
      'tiktok',
      'snapchat',
      'linkedin',
      'pinterest',
      'reddit',
      'tumblr',
      'threads',
    ],
  };

  /// Il canale dell'ultima condivisione: 'privato', 'pubblico' o nullo.
  static String? get canaleDellUltima {
    final dove = ultimoBersaglio?.toLowerCase();
    if (dove == null || dove.isEmpty) return null;
    for (final famiglia in canaliRiconosciuti.entries) {
      for (final pezzo in famiglia.value) {
        if (dove.contains(pezzo)) return famiglia.key;
      }
    }
    return null;
  }

  /// **LA CONDIVISIONE E' AVVENUTA DAVVERO?** Ordine AN voce 08.
  ///
  /// Fino a ieri queste tre vie tornavano VERO appena il foglio di sistema
  /// si apriva senza sollevare: bastava aprirlo e premere indietro perche'
  /// il Cerchio credesse a una condivisione mai partita, e accreditasse il
  /// bonus. share_plus l'esito lo dice, e da qui si legge: `success` e'
  /// l'unica cosa che vale, `dismissed` e' la persona che ha cambiato idea,
  /// `unavailable` e' il sistema che non sa rispondere.
  ///
  /// **Su `unavailable` si torna FALSO, ed e' una scelta prudente
  /// dichiarata**: non sapere se e' avvenuta non e' saperlo. Il Sigillo
  /// resta acceso e il bonus resta in attesa, incassabile piu' tardi
  /// riaprendo la card: meglio un premio che arriva dopo di un premio dato
  /// per una cosa che forse non e' successa.
  static bool avvenuta(ShareResult esito) {
    // **SI SEGNA DOVE E' ANDATA, ordine BX voce 10.** Qui passano tutte e tre
    // le vie di questa porta, quindi e' l'unico punto che deve saperlo.
    ultimoBersaglio = esito.raw;
    final riuscita = esito.status == ShareResultStatus.success;
    // **IL RESPONSO CONDIVISO SI SEGNA QUI. Ordine CC voce 09.**
    //
    // Questo metodo dichiara gia' di se' "qui passano tutte e tre le vie di
    // questa porta, quindi e' l'unico punto che deve saperlo", e una prova
    // esistente cade se qualcuno condivide scavalcandola: e' il solo punto da
    // cui la misura non puo' perdere un pezzo.
    //
    // **Si conta solo cio' che e' avvenuto davvero**, con la stessa prudenza
    // con cui questa porta tratta `unavailable`: un foglio aperto e chiuso non
    // e' una condivisione. Il contesto e' la famiglia del bersaglio, privato o
    // pubblico, che e' un elenco chiuso dichiarato sopra: mai il nome
    // dell'applicazione, che direbbe con chi si parla.
    if (riuscita) {
      RegistroDelRitorno.segnalo(EventoDelRitorno.responsoCondiviso,
          contesto: canaleDellUltima);
    }
    return riuscita;
  }

  /// Manda del TESTO. Torna falso se la condivisione non e' partita.
  static Future<bool> testo(String cosa, {String? oggetto}) async {
    if (cosa.trim().isEmpty) return false;
    try {
      final esito = await SharePlus.instance.share(
        ShareParams(text: cosa, subject: oggetto),
      );
      return avvenuta(esito);
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
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
      final esito = await SharePlus.instance.share(
        ShareParams(
          text: testo,
          files: [XFile(percorso, mimeType: tipo)],
        ),
      );
      return avvenuta(esito);
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
      return false;
    }
  }

  /// **MANDA PIU' FILE INSIEME.** Ordine BC voce 02.
  ///
  /// Serve allo scarico dei propri dati, che sono **due**: l'archivio in JSON
  /// e il riepilogo scritto in italiano. Mandarli in due condivisioni
  /// separate vorrebbe dire far scegliere due volte dove metterli, e chi
  /// sbaglia la seconda si ritrova meta' dei suoi dati.
  ///
  /// **Passa di qui e non da `SharePlus` diretto**, come tutto il resto: una
  /// prova enumera i punti che condividono e cade se ne compare uno che
  /// scavalca questa porta.
  static Future<bool> piuFile(
    List<String> percorsi, {
    String? testo,
  }) async {
    final veri = percorsi.where((p) => p.isNotEmpty).toList();
    if (veri.isEmpty) return false;
    try {
      final esito = await SharePlus.instance.share(
        ShareParams(
          text: testo,
          files: [for (final p in veri) XFile(p)],
        ),
      );
      return avvenuta(esito);
    } catch (errore) {
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
      final esito = await SharePlus.instance.share(
        ShareParams(
          text: testo,
          files: [XFile.fromData(byte, name: nome, mimeType: tipo)],
        ),
      );
      return avvenuta(esito);
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: il foglio di sistema puo' non aprirsi, e chi condivide sta finendo un rito.
      return false;
    }
  }
}
