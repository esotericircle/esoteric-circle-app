import 'package:flutter/foundation.dart';

import '../../services/free_astro_client.dart';
import 'birth_details.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

enum ChartStatus { idle, loading, ready }

/// Orchestrazione del calcolo della carta natale.
///
/// Il segno solare si calcola sempre in locale (deterministico dalla data),
/// cosi' e' disponibile anche senza API. Poi si prova l'API per la carta
/// completa; se la chiave manca o l'API non risponde, si ripiega sul cielo
/// essenziale con un messaggio in tono, senza bloccare il flusso ne mostrare
/// errori tecnici.
class NatalChartController extends ChangeNotifier {
  NatalChartController({FreeAstroClient? client})
      : _client = client ?? FreeAstroClient();

  final FreeAstroClient _client;

  ChartStatus status = ChartStatus.idle;
  NatalChart? chart;

  /// Messaggio gentile mostrato quando si e' usato il cielo essenziale.
  String? note;

  /// Segno solare risultante (per evidenziare la costellazione nel cosmo).
  Zodiac? get sunSign => chart?.sunSign;

  Future<void> compute(BirthDetails details) async {
    status = ChartStatus.loading;
    chart = null;
    note = null;
    notifyListeners();

    final localSun = Zodiac.fromDate(details.date);
    try {
      chart = await _client.fetchNatalChart(details);
    } catch (_) {
      chart = NatalChart.essential(
        sunSign: localSun,
        hasTime: details.hasTime,
      );
      note = _client.hasKey
          ? 'Ho tracciato il tuo cielo essenziale. Completero\' la mappa dei pianeti appena le stelle torneranno raggiungibili.'
          : 'Per ora leggo il tuo cielo essenziale. La mappa completa dei pianeti si aprira\' quando il motore astrologico sara\' collegato.';
    }
    status = ChartStatus.ready;
    notifyListeners();
  }

  void reset() {
    status = ChartStatus.idle;
    chart = null;
    note = null;
    notifyListeners();
  }
}
