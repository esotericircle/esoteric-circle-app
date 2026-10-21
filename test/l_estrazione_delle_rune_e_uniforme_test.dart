// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ESTRAZIONE DELLE RUNE E' UNIFORME, E IL CAMPIONE DEI LETTORI CIECHI
/// LA RAPPRESENTA.** Ordine GA voce GA.06, la cura delle Rune di Caligo, 21
/// ottobre 2026.
///
/// Il lettore cieco dell'ordine GA: *"Ingwaz è la pietra che decide in 9
/// gettate su 40 (attese circa 1,7 su 24 rune) ed esce 13 volte su 160
/// pietre"*. La misura su 4.000 gettate ha detto da dove veniva: l'estrazione
/// dell'app e' uniforme; era il generatore dei campioni a seminare ogni
/// gettata con un seme consecutivo (`Random(606 * 100 + i)`), e in Dart semi
/// vicini danno estrazioni vicine.
///
/// Due prove. La prima getta 24.000 volte con un generatore solo, come fa la
/// persona vera, e misura col chi quadro quante volte ogni runa decide e
/// quante esce in tutto: la soglia e' il chi quadro con 23 gradi di liberta'
/// al livello dell'uno per mille (49,73), e il verso d'ombra delle sedici
/// rune che possono girarsi resta vicino alla meta' nelle gettate fisse. La
/// seconda pretende che il generatore dei campioni non semini piu' una
/// gettata per volta.
void main() {
  const soglia = 49.73;

  double chiQuadro(Map<String, int> conti, int totale) {
    final atteso = totale / kElderFuthark.length;
    var chi = 0.0;
    for (final r in kElderFuthark) {
      final o = conti[r.name] ?? 0;
      chi += (o - atteso) * (o - atteso) / atteso;
    }
    return chi;
  }

  test('ogni runa decide e esce con la stessa probabilita\'', () {
    final caso = Random(2026);
    final decide = <String, int>{};
    final uscite = <String, int>{};
    var getti = 0;
    var pietre = 0;
    var girabili = 0;
    var inOmbra = 0;
    for (var i = 0; i < 24000; i++) {
      final g = gettate[i % gettate.length];
      final esito = RuneCast.getta(g, random: caso);
      getti++;
      final d = IlPresagioDalCorpus.pietraCheDecide(esito).rune.name;
      decide[d] = (decide[d] ?? 0) + 1;
      for (final p in esito.rune) {
        pietre++;
        uscite[p.rune.name] = (uscite[p.rune.name] ?? 0) + 1;
        if (!g.libera && !kRuneSimmetriche.contains(p.rune.name)) {
          girabili++;
          if (p.inOmbra) inOmbra++;
        }
      }
    }
    final chiDecide = chiQuadro(decide, getti);
    final chiUscite = chiQuadro(uscite, pietre);
    final quotaOmbra = inOmbra / girabili;
    print('ORDINE GA VOCE GA.06, RUNE: gettate $getti, chi quadro della '
        'pietra che decide ${chiDecide.toStringAsFixed(1)}, delle pietre '
        'uscite ${chiUscite.toStringAsFixed(1)} (soglia $soglia), ombra '
        '${(quotaOmbra * 100).toStringAsFixed(1)} per cento');
    cardinaleMinimo(getti, 24000, cosa: 'gettate misurate');
    expect(chiDecide, lessThan(soglia),
        reason: 'la pietra che decide non e\' uniforme: $decide');
    expect(chiUscite, lessThan(soglia),
        reason: 'le pietre uscite non sono uniformi: $uscite');
    expect(quotaOmbra, inInclusiveRange(0.48, 0.52));
  });

  test('il campione dei lettori ciechi non semina una gettata per volta', () {
    final t = File('test/ga06_campioni_per_i_lettori_ciechi_test.dart')
        .readAsStringSync();
    final rune = t.substring(
        t.indexOf('List<Map<String, Object?>> campioniDelleRune'),
        t.indexOf('List<Map<String, Object?>> campioniDellOracolo'));
    expect(RegExp(r'RuneCast\.getta\([^)]*Random\(').hasMatch(rune), isFalse,
        reason: 'il generatore dei campioni crea un Random per ogni gettata: '
            'semi vicini danno gettate vicine e il campione non rappresenta '
            'l\'app');
    expect(rune.contains('RuneCast.getta('), isTrue,
        reason: 'la prova non trova piu\' la gettata del campione');
  });
}
