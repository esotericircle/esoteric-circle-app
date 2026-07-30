import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/free_astro_client.dart';
import 'birth_details.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

enum ChartStatus { idle, loading, ready }

/// Flag di sola revisione (spento di default): usa una risposta reale gia'
/// catturata come fixture, per mostrare la ruota completa nell'anteprima web
/// dove il browser non puo' raggiungere l'API. Si attiva con
/// `--dart-define=DEMO_CHART=true`; in produzione la chiamata e' quella vera.
const bool _kDemoChart = bool.fromEnvironment('DEMO_CHART');

/// Orchestrazione del calcolo della carta natale.
///
/// Il segno solare si calcola sempre in locale (deterministico dalla data),
/// cosi' e' disponibile anche senza API. Poi si prova l'API per la carta
/// completa; se la chiave manca o l'API non risponde, si ripiega sul cielo
/// essenziale con un messaggio in tono, senza bloccare il flusso ne mostrare
/// errori tecnici.
class NatalChartController extends ChangeNotifier {
  NatalChartController({FreeAstroClient? client, ArchivioCarta? archivio})
      : _client = client ?? FreeAstroClient(),
        _archivio = archivio ?? const ArchivioCarta();

  final FreeAstroClient _client;
  final ArchivioCarta _archivio;

  ChartStatus status = ChartStatus.idle;
  NatalChart? chart;

  /// Messaggio gentile mostrato quando si e' usato il cielo essenziale.
  ///
  /// **Questo messaggio non lo leggeva nessuno.** Era valorizzato dentro
  /// `compute` e la schermata della carta non lo mostrava mai, quindi chi
  /// riceveva il cielo essenziale non sapeva ne che fosse essenziale ne perche'.
  String? note;

  /// Se la carta in mano e' il RIPIEGO e non il cielo completo. Serve alla
  /// schermata per offrire un modo di riprovare: un ripiego silenzioso e' un
  /// vicolo cieco travestito da risposta.
  bool ripiego = false;

  /// Segno solare risultante (per evidenziare la costellazione nel cosmo).
  Zodiac? get sunSign => chart?.sunSign;

  /// I dati di nascita dell'ultima carta calcolata, per sapere se quella che si
  /// ha in mano e' ancora la carta GIUSTA.
  ///
  /// Una carta conservata male e' peggio di una non conservata: se cambia la
  /// data di nascita e resta quella vecchia, la persona guarda il cielo di un
  /// altro e non ha modo di accorgersene.
  String? _chiaveCorrente;

  /// GARANTISCE la carta, senza ricalcolarla se c'e' gia' quella giusta.
  ///
  /// **Perche' esiste.** Dal Passport si apriva la Carta natale e restava sul
  /// cerchio con "Traccio il tuo cielo..." per sempre. Non era la rete: la
  /// chiamata non partiva mai. `compute` era invocata in UN SOLO punto di tutto
  /// il progetto, alla fine del Risveglio, e questo controller non conserva
  /// niente, quindi il caso si ripeteva a OGNI riavvio anche per chi il
  /// Risveglio l'aveva completato. Funzionava solo nella stessa sessione del
  /// Risveglio, ed e' probabilmente cosi' che era stato verificato.
  ///
  /// Adesso la schermata garantisce il proprio dato chiamando questo metodo, che
  /// e' idempotente: chiamarlo dieci volte non fa dieci chiamate.
  Future<void> assicura(BirthDetails details) async {
    final chiave = _chiaveDi(details);
    if (status == ChartStatus.loading && _chiaveCorrente == chiave) return;
    if (chart != null && _chiaveCorrente == chiave) return;
    await compute(details);
  }

  /// La firma dei dati di nascita: cambia se cambia qualcosa del cielo chiesto.
  static String _chiaveDi(BirthDetails d) {
    final p = d.place;
    return [
      d.date.toIso8601String(),
      d.time?.hour,
      d.time?.minute,
      p?.latitude,
      p?.longitude,
      p?.timezone,
    ].join('|');
  }

  Future<void> compute(BirthDetails details) async {
    final chiave = _chiaveDi(details);
    _chiaveCorrente = chiave;
    status = ChartStatus.loading;
    chart = null;
    note = null;
    notifyListeners();

    final localSun = Zodiac.fromDate(details.date);

    // Prima la memoria: rivedere un cielo gia' visto non deve dipendere dalla
    // rete. La risposta conservata si reinterpreta, cosi' se domani
    // l'interpretazione migliora il cielo gia' scaricato ne beneficia.
    final conservata = await _archivio.leggi(chiave);
    if (conservata != null) {
      try {
        chart = _client.parseResponse(conservata, details);
        status = ChartStatus.ready;
        notifyListeners();
        return;
      } catch (_) {
        // Memoria illeggibile: si butta e si ricalcola, senza dirlo a nessuno.
        await _archivio.dimentica(chiave);
      }
    }

    try {
      if (_kDemoChart) {
        final raw =
            await rootBundle.loadString('assets/data/sample_natal_rome.json');
        chart = _client.parseResponse(
            jsonDecode(raw) as Map<String, dynamic>, details);
      } else {
        final grezza = await _client.fetchRawNatalChart(details);
        chart = _client.parseResponse(grezza, details);
        await _archivio.scrivi(chiave, grezza);
      }
    } catch (_) {
      chart = NatalChart.essential(
        sunSign: localSun,
        hasTime: details.hasTime,
      );
      ripiego = true;
      note = _client.hasKey
          ? 'Ho tracciato il tuo cielo essenziale. Completerò la mappa dei pianeti appena le stelle torneranno raggiungibili.'
          : 'Per ora leggo il tuo cielo essenziale. La mappa completa dei pianeti si aprirà quando il motore astrologico sarà collegato.';
    }
    status = ChartStatus.ready;
    notifyListeners();
  }

  /// Riprova da capo, buttando la memoria: e' il gesto di chi ha letto la nota
  /// del ripiego e vuole il cielo intero adesso che la rete c'e'.
  Future<void> riprova(BirthDetails details) async {
    await _archivio.dimentica(_chiaveDi(details));
    ripiego = false;
    await compute(details);
  }

  void reset() {
    status = ChartStatus.idle;
    chart = null;
    note = null;
    ripiego = false;
    _chiaveCorrente = null;
    notifyListeners();
  }
}

/// Dove la carta natale si conserva fra un avvio e l'altro.
///
/// Tiene la RISPOSTA del cielo, non l'oggetto interpretato, e la tiene sotto una
/// chiave che dipende dai dati di nascita: cambiando data, ora o luogo la chiave
/// cambia e la vecchia carta non viene piu' ritrovata. Una carta conservata
/// sotto una chiave fissa sarebbe peggio del non conservarla, perche' mostrerebbe
/// alla persona il cielo di un altro senza che nessuno se ne accorga.
class ArchivioCarta {
  const ArchivioCarta();

  static const String _prefisso = 'carta_natale_';

  Future<Map<String, dynamic>?> leggi(String chiave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testo = prefs.getString('$_prefisso$chiave');
      if (testo == null) return null;
      final json = jsonDecode(testo);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      // Memoria non disponibile: si ricalcola. Non e' un errore da mostrare.
      return null;
    }
  }

  Future<void> scrivi(String chiave, Map<String, dynamic> risposta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefisso$chiave', jsonEncode(risposta));
    } catch (_) {
      // Se non si riesce a conservare, pazienza: si ricalcolera'.
    }
  }

  Future<void> dimentica(String chiave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefisso$chiave');
    } catch (_) {
      // Niente da fare, e niente di grave.
    }
  }
}
