// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';

/// **LA SCELTA DELLE TRENTA LUNE**, ordine FV voce FV.03, 15 ottobre 2026.
///
/// La serie "Moon Phase and Libration, 2026" dello Scientific Visualization
/// Studio (svs.gsfc.nasa.gov/5587, la pagina dell'anno di
/// svs.gsfc.nasa.gov/5612) ha un fotogramma per ogni ora del 2026: il
/// fotogramma N e' l'istante 1 gennaio 2026 00:00 UT piu' N meno 1 ore
/// (8760 fotogrammi, uno per riga di mooninfo_2026.json).
///
/// Questo strumento sceglie la lunazione e le trenta ore col motore del
/// ramo (`IlMotoreLunare.elongazione`, che usa `IlCieloDiMeeus`):
/// - la lunazione e' quella che comincia con la Luna nuova di ottobre 2026
///   (la prima ora dopo il passaggio dell'elongazione per lo zero dopo il 1
///   ottobre) e finisce alla Luna nuova seguente;
/// - il giorno lunare k (da 1 a 30) e' quello di `IlMotoreLunare`, cioe'
///   l'elongazione fra (k - 1) per 12 e k per 12 gradi; per ognuno si
///   prende l'ora della lunazione con l'elongazione piu' vicina al centro
///   del suo settore, (k - 0,5) per 12 gradi.
///
/// Scrive docs/collaudo/FV/fv03_lune_scelte.json, che legge
/// tool/le_lune_della_nasa.py per scaricare, scontornare e generare la
/// tabella Dart.
///
/// Uso: dart run tool/le_lune_della_nasa_scelta.dart
void main() {
  final inizioAnno = DateTime.utc(2026, 1, 1);
  double el(int ora) =>
      IlMotoreLunare.elongazione(inizioAnno.add(Duration(hours: ora)));

  // La Luna nuova di ottobre: l'elongazione passa da poco sotto 360 a poco
  // sopra 0.
  final daOttobre = DateTime.utc(2026, 10, 1).difference(inizioAnno).inHours;
  var inizio = daOttobre;
  while (!(el(inizio - 1) > 300 && el(inizio) < 60)) {
    inizio++;
  }
  var fine = inizio + 1;
  while (!(el(fine - 1) > 300 && el(fine) < 60)) {
    fine++;
  }
  final scelte = <Map<String, Object>>[];
  for (var k = 1; k <= 30; k++) {
    final centro = (k - 0.5) * 12;
    var migliore = inizio;
    var scarto = 360.0;
    for (var ora = inizio; ora < fine; ora++) {
      final d = (el(ora) - centro).abs();
      if (d < scarto) {
        scarto = d;
        migliore = ora;
      }
    }
    final istante = inizioAnno.add(Duration(hours: migliore));
    final e = el(migliore);
    scelte.add({
      'giorno_lunare': k,
      'centro_del_settore': centro,
      'fotogramma': migliore + 1,
      'istante_utc': istante.toIso8601String(),
      'elongazione': double.parse(e.toStringAsFixed(3)),
      'illuminazione_dal_motore':
          double.parse(((1 - math.cos(e * math.pi / 180)) / 2 * 100)
              .toStringAsFixed(2)),
    });
  }
  final uscita = {
    'serie': 'Moon Phase and Libration, 2026',
    'pagina': 'https://svs.gsfc.nasa.gov/5587/',
    'luna_nuova_di_inizio_utc':
        inizioAnno.add(Duration(hours: inizio)).toIso8601String(),
    'luna_nuova_di_fine_utc':
        inizioAnno.add(Duration(hours: fine)).toIso8601String(),
    'scelte': scelte,
  };
  File('docs/collaudo/FV/fv03_lune_scelte.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(uscita)}\n');
  print('lunazione: ${uscita['luna_nuova_di_inizio_utc']} -> '
      '${uscita['luna_nuova_di_fine_utc']}');
  for (final s in scelte) {
    print('${s['giorno_lunare']}\t${s['fotogramma']}\t${s['istante_utc']}\t'
        '${s['elongazione']}');
  }
}
