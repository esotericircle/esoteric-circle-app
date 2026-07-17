import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

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
      if (_kDemoChart) {
        final raw =
            await rootBundle.loadString('assets/data/sample_natal_rome.json');
        chart = _client.parseResponse(
            jsonDecode(raw) as Map<String, dynamic>, details);
      } else {
        chart = await _client.fetchNatalChart(details);
      }
    } catch (_) {
      chart = NatalChart.essential(
        sunSign: localSun,
        hasTime: details.hasTime,
      );
      note = _client.hasKey
          ? 'Ho tracciato il tuo cielo essenziale. Completerò la mappa dei pianeti appena le stelle torneranno raggiungibili.'
          : 'Per ora leggo il tuo cielo essenziale. La mappa completa dei pianeti si aprirà quando il motore astrologico sarà collegato.';
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
