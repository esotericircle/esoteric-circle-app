import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

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
///
/// **IL PAVIMENTO SI MISURA SUL PRESAGIO CHE SI VEDE, ordine GA voci GA.03 e
/// GA.07, 20 ottobre 2026.** La seconda prova misurava in caratteri la
/// lettura di casa (`RunePresagio.componi`), cioe' il ripiego del modello,
/// mentre a video, dall'ordine EX voce 03, c'e' il presagio del corpus: una
/// guardia che puntava al pezzo accanto. Adesso misura il presagio composto
/// dal corpus vero, nella forma del fondatore: *"tutte le risposte composte
/// da paragrafi ognuno con tra 40 a 50 parole ognuno. Per le risposte brevi
/// 2 paragrafi"*. Il pavimento e' quello della forma: almeno due paragrafi
/// da almeno quaranta parole, cioe' ottanta parole nella Breve.
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
    // che la lunghezza del presagio e' l'unica gia' giusta. **Dall'ordine GA**
    // il pavimento e' quello della forma: due paragrafi da almeno quaranta
    // parole nella Breve, quattro nella Lunga.
    const pavimento = 2 * LaFormaDelResponso.minimo;
    final corti = <String>[];
    var guardati = 0;
    for (final gettata in gettate) {
      for (var seme = 0; seme < 40; seme++) {
        for (final lunga in const [false, true]) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: RuneCast.getta(gettata, random: Random(seme)),
            domanda: '',
            persona: 'pavimento',
            oggi: DateTime(2026, 10, 20),
            memoria: LaMemoriaDelPresagio(),
            lunga: lunga,
          ).principale;
          guardati++;
          final parole = p.paragrafi.map(LaFormaDelResponso.parole).toList();
          final corto = parole.any((n) => n < LaFormaDelResponso.minimo);
          final somma = parole.fold<int>(0, (a, b) => a + b);
          if (p.paragrafi.length < (lunga ? 4 : 2) ||
              corto ||
              somma < pavimento) {
            corti.add('${gettata.id}, seme $seme, '
                '${lunga ? 'Lunga' : 'Breve'}: paragrafi $parole');
          }
        }
      }
    }
    cardinaleMinimo(guardati, 4 * 40 * 2,
        cosa: 'presagi composti dal corpus',
        perche: 'quattro gettate, quaranta semi, Breve e Lunga');
    expect(corti, isEmpty,
        reason:
            'questi presagi sono scesi sotto la forma: la voce S.19 dichiara '
            'che la lunghezza del presagio non si tocca, e la voce GA.03 la '
            'misura in paragrafi da 40 a 50 parole:\n'
            '${corti.take(5).join("\n")}');
  });
}
