import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/responsi/tetti_dei_responsi.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL PRESAGIO DI CALIGO E' LA PRIMA BOLLA. Ordine S voce 19.
///
/// **Il difetto.** Il presagio stava in fondo, dopo le rune una per una: la
/// persona leggeva tre frammenti e doveva montarli da sola, e la lettura che li
/// tiene insieme arrivava quando aveva gia' finito di interpretare.
///
/// **LA SUA LUNGHEZZA NON SI TOCCA**, e l'ordine lo dichiara perche' nessuno la
/// accorci per uniformita' con le bolle brevi delle rune: e' l'unica misura gia'
/// giusta di tutta la sezione. Per questo la seconda prova qui sotto e' un
/// presidio al contrario, che cade se il presagio DIVENTA corto.
void main() {
  test('nella schermata il presagio e\' dichiarato prima delle rune singole',
      () {
    // **SI GUARDA L'ORDINE DI DICHIARAZIONE dentro la colonna**, che e' cio' che
    // decide chi si legge prima: le due parti vivono nella stessa lista di figli,
    // quindi qui l'ordine del sorgente E' l'ordine a schermo.
    final sorgente =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    final presagio = sorgente.indexOf("Key('rune_presage')");
    final singole = sorgente.indexOf('for (var i = 0; i < esito.rune.length');
    expect(presagio, greaterThan(0),
        reason: 'la bolla del presagio non c\'e\'');
    expect(singole, greaterThan(0),
        reason: 'le bolle delle rune singole non ci sono');
    expect(presagio, lessThan(singole),
        reason:
            'il presagio e\' dichiarato DOPO le rune una per una: la persona '
            'legge i frammenti prima della lettura che li tiene insieme');
  });

  test('il presagio resta lungo: nessuno lo accorcia per uniformita\'', () {
    // **UN PRESIDIO AL CONTRARIO.** Tutte le altre prove di questa sezione
    // difendono un tetto; questa difende un pavimento, perche' l'ordine dichiara
    // che la lunghezza del presagio e' l'unica gia' giusta. Il pavimento e' il
    // TETTO DELLE RUNE BREVI moltiplicato per tre: se il presagio scendesse sotto,
    // vorrebbe dire che qualcuno lo ha uniformato alle bolle brevi.
    const pavimento = TettiDeiResponsi.runaBreve * 3;
    final corti = <String>[];
    for (final gettata in gettate) {
      for (var seme = 0; seme < 40; seme++) {
        final presagio =
            RunePresagio.componi(RuneCast.getta(gettata, random: Random(seme)));
        if (presagio.length < pavimento) {
          corti.add('${gettata.id}, seme $seme: ${presagio.length} caratteri');
        }
      }
    }
    expect(corti, isEmpty,
        reason:
            'questi presagi sono scesi sotto i $pavimento caratteri: la voce '
            'S.19 dichiara che la lunghezza del presagio non si tocca, ed e\' '
            'l\'unica gia\' giusta della sezione:\n${corti.take(5).join("\n")}');
  });
}
