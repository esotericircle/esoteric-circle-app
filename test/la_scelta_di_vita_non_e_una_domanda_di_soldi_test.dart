// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **UNA SCELTA DI VITA CON UN LATO DI DENARO NON E' UNA DOMANDA DI SOLDI.**
/// Ordine GA voce GA.06, riapertura delle Rune di Caligo, ultimo giro,
/// 21 ottobre 2026.
///
/// Il lettore cieco indipendente, su "Devo lasciare il lavoro per tornare a
/// studiare?" e su "E' il momento giusto per aprire la mia attivita'?": il
/// responso apriva con "Le rune non danno consigli di denaro", ignorava la
/// pietra (Dagaz, Ansuz), il cosa fare presumeva debiti ("quanto devi") e non
/// diceva niente sullo studio, e i due testi condividevano tre frasi intere.
/// Il limite sui conti va detto (e' una regola), ma poi la risposta legge la
/// pietra sulla scelta e da' un criterio, come fa l'Oracolo. Padre: l'ordine
/// GA voce GA.06 della prima riapertura, che aveva esteso il denaro ad "aprire
/// un'attivita'" e "lasciare il lavoro" senza distinguere la scelta dal conto.
void main() {
  const vita = <String>[
    'Devo lasciare il lavoro per tornare a studiare?',
    'È il momento giusto per aprire la mia attività?',
    'Devo licenziarmi per cambiare vita?',
    'Posso mettermi in proprio?',
    'Conviene aprire un negozio?',
  ];
  const soldiVeri = <String>[
    'Conviene investire i miei risparmi in borsa adesso?',
    'Compro casa adesso o aspetto un anno?',
    'Devo chiedere un prestito per la caparra?',
  ];

  final debiti = RegExp(r'quanto (hai|devi)|debit[ioa]|risparmi|prestit[oi]|'
      r'mutu[oi]|somm[ae]|capitale|cifre vere');

  List<IlPresagioComposto> componi(String domanda, {int semi = 12}) {
    final fuori = <IlPresagioComposto>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        fuori.add(IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: RuneCast.getta(g, random: Random(900 + seme)),
          domanda: domanda,
          persona: 'vita-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
          lunga: seme.isOdd,
        ));
      }
    }
    return fuori;
  }

  test('1. LA DOMANDA SI LEGGE COME SCELTA DI VITA, NON COME SOLDI', () {
    for (final d in vita) {
      final q = LaDomandaLetta.di(d);
      expect(q.sceltaDiVita, isTrue, reason: d);
      expect(q.delicato, AmbitoDelicato.denaro, reason: d);
    }
    for (final d in soldiVeri) {
      final q = LaDomandaLetta.di(d);
      expect(q.sceltaDiVita, isFalse, reason: d);
      expect(q.delicato, AmbitoDelicato.denaro, reason: d);
    }
  });

  test('2. IL LIMITE IN UNA FRASE, POI LA PIETRA E UN CRITERIO, MAI UN DEBITO',
      () {
    final colpe = <String>[];
    var responsi = 0;
    for (final d in vita) {
      for (final p in componi(d)) {
        responsi++;
        final r = p.principale;
        if (r.risposta.startsWith('Le rune non danno consigli')) {
          colpe.add('«$d»: apre come una domanda di soldi: «${r.risposta}»');
        }
        if (!r.risposta.contains('consulente')) {
          colpe.add('«$d»: il limite sui conti non c\'e\': «${r.risposta}»');
        }
        if (!r.risposta.contains('preferisci la strada che')) {
          colpe.add('«$d»: manca il criterio della pietra: «${r.risposta}»');
        }
        if (!RegExp(r'\b(Fehu|Uruz|Thurisaz|Ansuz|Raidho|Kenaz|Gebo|Wunjo|'
                r'Hagalaz|Nauthiz|Isa|Jera|Eihwaz|Perthro|Algiz|Sowilo|Tiwaz|'
                r'Berkano|Ehwaz|Mannaz|Laguz|Ingwaz|Dagaz|Othala)\b')
            .hasMatch(r.risposta)) {
          colpe.add('«$d»: la pietra non e\' nominata: «${r.risposta}»');
        }
        for (final t in [
          r.risposta,
          r.cosaFare,
          for (final s in p.schede) ...[s.risposta, s.cosaFare],
        ]) {
          if (debiti.hasMatch(t)) {
            colpe.add('«$d»: dà per presenti debiti o somme: «$t»');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: scelte di vita lette $responsi, '
        'difetti ${colpe.length}');
    cardinaleMinimo(responsi, 200, cosa: 'responsi di scelte di vita');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('3. DUE SCELTE DI VITA DIVERSE NON CONDIVIDONO DUE FRASI DEL PARAGRAFO',
      () {
    // Il lettore: "Le rune non danno consigli di denaro...", "ti offre il modo
    // di prendere questa decisione" e "fino all'incontro con il consulente"
    // erano in entrambi i testi. Qui il paragrafo porta il limite, che puo'
    // essere lo stesso, e poi la pietra: quella e' di ogni gettata.
    final colpe = <String>[];
    var coppie = 0;
    List<String> frasi(String t) => [
          for (final f in t.split(RegExp(r'(?<=[.!?])\s+')))
            if (f.trim().length > 25) f.trim(),
        ];
    for (final g in gettate) {
      for (var seme = 0; seme < 12; seme++) {
        final a = IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: RuneCast.getta(g, random: Random(900 + seme)),
          domanda: vita[0],
          persona: 'vita-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
        );
        final b = IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: RuneCast.getta(g, random: Random(1900 + seme)),
          domanda: vita[1],
          persona: 'vita-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
        );
        coppie++;
        final comuni = frasi(a.principale.risposta)
            .toSet()
            .intersection(frasi(b.principale.risposta).toSet());
        if (comuni.length >= 2) {
          colpe.add('${g.id} seme $seme: ${comuni.length} frasi uguali: '
              '${comuni.take(3).join(' | ')}');
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: coppie di scelte di vita $coppie, con '
        'due frasi uguali nel paragrafo ${colpe.length}');
    cardinaleMinimo(coppie, 30, cosa: 'coppie di scelte di vita');
    expect(colpe, isEmpty, reason: colpe.take(6).join('\n'));
  });
}
