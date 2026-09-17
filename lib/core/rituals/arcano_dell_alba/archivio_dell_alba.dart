import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'diario_dell_alba.dart';
import 'responso_dell_alba.dart';
import 'sacchetto_dell_alba.dart';

/// **L'ARCHIVIO DELL'ARCANO DELL'ALBA: la porta unica del diario.** Ordine DT
/// voci 05 e 25, 17 settembre 2026.
///
/// Da qui passano tutti: la schermata del dono che estrae, la Carta del giorno
/// di Medora in chat e il Sigillo del Sogno che leggono senza estrarre, il
/// custode del cammino che porta il diario al Cerchio e lo riporta su un
/// telefono nuovo. **Una carta al giorno e una porta sola**: se la chat la
/// calcolasse per conto suo, direbbe una carta che il dono non ha.
///
/// Sul telefono il diario sta in una chiave sola; fra i telefoni viaggia col
/// cammino, e il Cerchio tiene il piu' avanti dei due.
///
/// Best-effort come gli altri archivi: senza preferenze non lancia, e un
/// diario illeggibile si ricompone.
abstract final class ArchivioDellAlba {
  static const String chiave = 'arcano_alba.diario';

  /// L'ultimo diario letto o scritto, per chi ne ha bisogno senza aspettare:
  /// il custode del cammino raccoglie in modo sincrono.
  static DiarioDellAlba? _inMemoria;

  /// Il diario in memoria, o null se in questa sessione non e' ancora stato
  /// letto.
  static DiarioDellAlba? get inMemoria => _inMemoria;

  /// Solo per le prove: dimentica la copia in memoria.
  static void dimenticaLaMemoria() => _inMemoria = null;

  /// Legge il diario. Se non ce n'e', ne nasce uno nuovo, che si salva solo
  /// alla prima estrazione.
  static Future<DiarioDellAlba> leggi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(chiave);
      // **Senza chiave il diario e' nuovo, anche se in memoria ce n'era uno**:
      // la chiave manca dopo una cancellazione dei dati, e ridare la copia in
      // memoria resusciterebbe cio' che la persona ha appena cancellato.
      final diario = grezzo == null
          ? DiarioDellAlba.nuovo()
          : DiarioDellAlba.daJson(jsonDecode(grezzo));
      return _inMemoria = diario;
    } catch (errore) {
      return _inMemoria ??= DiarioDellAlba.nuovo();
    }
  }

  static Future<void> scrivi(DiarioDellAlba diario) async {
    _inMemoria = diario;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(chiave, jsonEncode(diario.toJson()));
    } catch (errore) {
      // Best-effort: la copia in memoria resta per la sessione.
    }
  }

  /// **LA CARTA DI OGGI, SE E' GIA' STATA SCELTA**, senza estrarre. E' cio'
  /// che leggono la chat e il Sigillo del Sogno.
  static Future<ResponsoDellAlba?> diOggi(DateTime adesso) async =>
      (await leggi()).diOggi(adesso);

  /// **ESTRAE LA CARTA DI OGGI**, o restituisce quella gia' estratta. Il caso
  /// e' quello sicuro del sistema: il verso non si prevede.
  static Future<ResponsoDellAlba> estraiOggi(DateTime adesso,
      {Random? caso}) async {
    final diario = await leggi();
    final e = diario.estrai(
      utente: diario.seme,
      giorno: adesso,
      caso: caso ?? Random.secure(),
    );
    if (!identical(e.dopo, diario)) await scrivi(e.dopo);
    return e.responso;
  }

  /// **ADOTTA IL DIARIO TORNATO DAL CERCHIO**, se e' piu' avanti di quello del
  /// telefono. La stessa regola del server, cosi' che le due parti non
  /// decidano in modo diverso.
  static Future<void> adottaDalCerchio(Map<String, Object?>? dati) async {
    if (dati == null) return;
    final tornato = DiarioDellAlba.daJson(dati);
    final mio = await leggi();
    if (identical(piuAvanti(tornato, mio), tornato)) await scrivi(tornato);
  }

  /// Il piu' avanti di due diari: il giorno dell'ultima estrazione, poi il
  /// ciclo, poi gli stati usciti nel ciclo. A parita' vince [primo].
  static DiarioDellAlba piuAvanti(
      DiarioDellAlba primo, DiarioDellAlba secondo) {
    (String, int, int) avanzamento(DiarioDellAlba d) => (
          d.ultima?.giorno ?? '',
          d.sacchetto.ciclo,
          SacchettoDellAlba.stati - d.sacchetto.rimasti.length,
        );
    final a = avanzamento(primo), b = avanzamento(secondo);
    final giorno = a.$1.compareTo(b.$1);
    if (giorno != 0) return giorno > 0 ? primo : secondo;
    if (a.$2 != b.$2) return a.$2 > b.$2 ? primo : secondo;
    if (a.$3 != b.$3) return a.$3 > b.$3 ? primo : secondo;
    return primo;
  }
}
