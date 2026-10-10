import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// LA PORTA DEI MESSAGGI. Ordine FD voce 06.5.
///
/// **L'invio lo fa la persona.** Questa porta compone UN messaggio gia'
/// scritto, coi destinatari scelti, e lo consegna all'app dei messaggi del
/// telefono: e' li' che la persona lo legge, lo cambia se vuole e lo manda.
/// L'app non invia niente da se', non apre nessuna connessione e non
/// registra chi e' stato scelto.
///
/// Sta fuori da `PortaDellaCondivisione`, che apre il foglio di sistema per
/// un testo senza destinatari: qui i destinatari ci sono, e la strada e' lo
/// schema dei messaggi (`smsto:` su Android, `sms:` su iOS).
abstract final class LaPortaDeiMessaggi {
  /// L'apertura vera, sostituibile nelle prove.
  static Future<bool> Function(Uri) apri =
      (u) => launchUrl(u, mode: LaunchMode.externalApplication);

  /// Il messaggio per [numeri] col [testo], nella forma della piattaforma.
  static Uri messaggio(List<String> numeri, String testo, {bool? ios}) {
    final suIos = ios ?? defaultTargetPlatform == TargetPlatform.iOS;
    final pulite = [
      for (final n in numeri) n.replaceAll(RegExp(r'[^0-9+]'), ''),
    ];
    final corpo = Uri.encodeComponent(testo);
    if (suIos) {
      // iOS: un indirizzo solo nello schema, gli altri nel parametro.
      return Uri.parse('sms:/open?addresses=${pulite.join(',')}&body=$corpo');
    }
    return Uri.parse('smsto:${pulite.join(';')}?body=$corpo');
  }

  /// Consegna il messaggio all'app dei messaggi. Vero se l'app si e' aperta.
  static Future<bool> consegna(List<String> numeri, String testo) async {
    try {
      return await apri(messaggio(numeri, testo));
    } catch (errore) {
      // Nessuna app dei messaggi, o lo schema rifiutato: non si e' mandato
      // niente, e la schermata lo dice.
      debugPrint('I messaggi non si aprono: $errore');
      return false;
    }
  }
}
