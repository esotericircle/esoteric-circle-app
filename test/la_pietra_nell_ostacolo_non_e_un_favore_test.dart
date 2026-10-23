// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA PIETRA NELL'OSTACOLO NON E' UN FAVORE, E OGNI SCHEDA LEGGE LA SUA
/// POSIZIONE.** Ordine GA voce GA.06, la cura delle Rune di Caligo, 21
/// ottobre 2026.
///
/// I lettori ciechi, sul commit 1804c7d7: *"La posizione non è mai letta.
/// Urdhr, Verdhandi, Skuld, Ostacolo, Esito, Al centro, Ai margini: nessuna
/// scheda dice che cosa significa la pietra in quel posto. Una pietra in
/// Ostacolo è letta come favorevole"* (Raidho dritta nell'Ostacolo, "ogni
/// passo serve a qualcosa"). Il titolo della scheda era la riga della runa,
/// la stessa in ogni posto.
///
/// La guardia mette ognuna delle quaranta pietre nell'Ostacolo della Croce
/// delle Cinque e pretende: il titolo della scheda dice "Ciò che ti frena" e
/// legge il lato difficile della pietra (il senso del suo verso d'ombra, o il
/// lato scritto per le simmetriche), mai il senso favorevole della pietra
/// dritta; la frase del freno nel paragrafo della risposta, quando c'e', dice
/// la stessa cosa. Poi, in ogni gettata a piu' pietre, il titolo di ogni
/// scheda comincia con cio' che dice la sua posizione.
void main() {
  final ruoli = {
    'Urdhr': 'Da dove vieni',
    'Verdhandi': 'Dove sei adesso',
    'Skuld': 'Dove tende la strada',
    'Cuore': 'Il cuore della questione',
    'Radice': 'La radice',
    'Ostacolo': 'Ciò che ti frena',
    'Consiglio': 'Il consiglio',
    'Esito': 'Dove tende la questione',
    'Al centro': 'Ciò che pesa di più',
    'Presso il centro': 'Ciò che accompagna',
    'Ai margini': 'Una voce lieve',
  };

  test('nell\'Ostacolo ogni pietra si legge dal suo lato difficile', () {
    final colpe = <String>[];
    var provate = 0;
    final altre = [
      for (final r in kElderFuthark)
        if (kRuneSimmetriche.contains(r.name)) r
    ];
    for (final chiave in LaPietraLetta.tutte.keys) {
      final nome = chiave.split('/').first;
      final inOmbra = chiave.endsWith('/ombra');
      final runa = kElderFuthark.firstWhere((r) => r.name == nome);
      final compagne = [
        for (final r in altre)
          if (r.name != nome) r
      ];
      final pietre = <RunaGettata>[
        for (var i = 0; i < 5; i++)
          i == 2
              ? RunaGettata(
                  rune: runa,
                  verso: inOmbra ? RuneVerso.merkstave : RuneVerso.dritto,
                  posizione: gettataCroce.posizioni[2])
              : RunaGettata(
                  rune: compagne[i],
                  verso: RuneVerso.dritto,
                  posizione: gettataCroce.posizioni[i]),
      ];
      final esito = EsitoGettata(gettata: gettataCroce, rune: pietre);
      final p = IlPresagioDalCorpus.componi(
        corpus: corpusDelPresagio,
        esito: esito,
        domanda: 'Devo accettare l’offerta della nuova azienda?',
        persona: 'ostacolo',
        oggi: DateTime(2026, 10, 21),
        memoria: LaMemoriaDelPresagio(),
      );
      provate++;
      final titolo = p.schede[2].titolo;
      final lato = LaPietraLetta.latoDifficile(pietre[2]);
      final favore =
          LaPietraLetta.tutte[LaPietraLetta.chiave(nome, false)]!.senso;
      if (!titolo.startsWith('Ciò che ti frena:')) {
        colpe.add('$chiave: il titolo non dice che frena: «$titolo»');
      }
      if (!titolo.contains(lato)) {
        colpe.add('$chiave: il titolo non legge il lato difficile «$lato»: '
            '«$titolo»');
      }
      if (!inOmbra && titolo.contains(favore)) {
        colpe.add('$chiave: nell\'Ostacolo letta come favore «$favore»');
      }
      final freno = RegExp(r'Ciò che ti frena, nell’Ostacolo, è ([^.]+)\.')
          .firstMatch(p.principale.risposta);
      if (freno != null && freno[1] != lato) {
        colpe.add('$chiave: il paragrafo dice che frena «${freno[1]}»');
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: pietre messe nell\'Ostacolo $provate, '
        'lette come favore o senza posizione ${colpe.length}');
    cardinaleMinimo(provate, 40, cosa: 'pietre nell\'Ostacolo');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('ogni scheda comincia con cio\' che dice la sua posizione', () {
    final colpe = <String>[];
    var schede = 0;
    for (final g in gettate) {
      if (g.id == 'odino') continue;
      for (var seme = 0; seme < 30; seme++) {
        final esito = RuneCast.getta(g, random: Random(300 + seme));
        final p = IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: esito,
          domanda: 'Nel lavoro, quale passo fare?',
          persona: 'posizione-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
        );
        for (var i = 0; i < p.schede.length; i++) {
          schede++;
          final titolo = esito.rune[i].posizione.titolo;
          final ammessi = titolo == 'Ai margini'
              ? LaRispostaDellaGettata.ruoliAiMargini
              : [ruoli[titolo]];
          if (!ammessi.any((ruolo) =>
              ruolo != null && p.schede[i].titolo.startsWith('$ruolo:'))) {
            colpe.add('${g.id}, $seme, ${esito.rune[i].posizione.titolo}: '
                '«${p.schede[i].titolo}»');
          }
        }
      }
    }
    cardinaleMinimo(schede, 3 * 30 * 3, cosa: 'schede lette');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  });
}
