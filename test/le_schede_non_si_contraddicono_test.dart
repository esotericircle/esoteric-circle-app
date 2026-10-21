// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL PRINCIPALE E LE SCHEDE NON SI CONTRADDICONO SULL'ATTENDERE O SUL
/// FARE.** Ordine GA voce GA.06, riapertura delle Rune di Caligo, ultimo
/// giro, 21 ottobre 2026.
///
/// Il lettore cieco indipendente, su "Come gestisco il conflitto con il mio
/// capo?" (rune-36): la scheda di Perthro diceva "Sospendi per tre settimane
/// ogni discorso decisivo" e quella di Ansuz "chiedi entro tre giorni un
/// momento a quattr'occhi"; su "Devo lasciare Roma?" (rune-8) il principale
/// diceva "Rimanda di una settimana" e due schede "dichiaralo apertamente alla
/// persona interessata". Padre: la scelta delle coppie "come" per le schede
/// (riapertura della voce GA.06, secondo giro), che sceglieva ogni scheda per
/// conto suo senza guardare le altre.
///
/// La misura: la postura di un testo ([LeRisposteDirette.postura]) e' attesa,
/// azione o nessuna. Una gettata non porta mai insieme un testo d'attesa e uno
/// d'azione, fra il principale e le schede e fra le schede.
void main() {
  const domande = <String>[
    'Come gestisco il conflitto con il mio capo?',
    'Devo lasciare Roma, e se lo faccio la mia famiglia capirà?',
    'Devo accettare l’offerta della nuova azienda?',
    'Come posso fare pace con mia sorella?',
    'Posso fidarmi del mio compagno?',
    'Mio figlio sta attraversando un periodo difficile, come lo aiuto?',
    'Devo dirle che sono innamorato di lei?',
    'Quando finirà questo periodo di stallo?',
    'Come faccio a dimenticarlo?',
    'Come affronto il pranzo di Natale con la famiglia di lui?',
  ];

  test('1. NESSUNA GETTATA CHIEDE INSIEME DI ATTENDERE E DI AGIRE', () {
    final colpe = <String>[];
    var gettateConSchede = 0;
    for (final d in domande) {
      for (final g in gettate) {
        for (var seme = 0; seme < 30; seme++) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: RuneCast.getta(g, random: Random(1200 + seme)),
            domanda: d,
            persona: 'postura-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
          );
          if (p.schede.length < 2) continue;
          gettateConSchede++;
          final principale =
              LeRisposteDirette.posturaDelVerdetto(p.principale.risposta) ??
                  LeRisposteDirette.postura(p.principale.cosaFare);
          final poste = <String?>[
            principale,
            for (final s in p.schede) LeRisposteDirette.postura(s.cosaFare),
          ];
          if (poste.contains('attesa') && poste.contains('azione')) {
            colpe.add('${g.id} seme $seme «$d»: $poste\n'
                '  principale: ${p.principale.cosaFare}\n'
                '  schede: ${[for (final s in p.schede) s.cosaFare]}');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: gettate con schede $gettateConSchede, '
        'che chiedono insieme di attendere e di agire ${colpe.length}');
    cardinaleMinimo(gettateConSchede, 800, cosa: 'gettate con schede');
    expect(colpe, isEmpty, reason: colpe.take(4).join('\n'));
  });

  test('2. LA POSTURA SI RICONOSCE: QUATTRO TESTI LETTI DAI LETTORI CIECHI',
      () {
    expect(
        LeRisposteDirette.postura(
            'Sospendi per tre settimane ogni discorso decisivo: niente '
            'chiarimenti a tutti i costi.'),
        'attesa');
    expect(
        LeRisposteDirette.postura(
            'Per questa situazione chiedi entro tre giorni un momento a '
            'quattr’occhi con il tuo capo e apri con una frase sola.'),
        'azione');
    expect(
        LeRisposteDirette.postura(
            'Scegli una cosa piccola da fare ogni giorno e segna il '
            'calendario.'),
        isNull);
    expect(
        LeRisposteDirette.posturaDelVerdetto('Rimanda di una settimana la '
            'decisione di lasciare Roma.'),
        'attesa');
  });
}
