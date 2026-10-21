// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/l_oggetto_della_domanda.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.g.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE RISPOSTE DIRETTE DELLE RUNE.** Ordine GA voce GA.06, il secondo
/// giro della cura delle Rune di Caligo, 21 ottobre 2026.
///
/// Il lettore cieco indipendente sulla prima cura (paragrafi montati da
/// frammenti): la prima frase rispondeva in 33 responsi su 40, il cosa fare
/// era concreto e pertinente in 25, la coerenza in 24; il cosa fare era una
/// formula ("cura con costanza ciò che dipende da te" cinque volte), la
/// persona della domanda spariva ("per il lavoro" al posto del capo), "Lo
/// chiede la pietra che decide" tornava in 21 responsi su 40.
///
/// Quattro misure sulle risposte dirette (`diretta.md`, `azione.md`):
/// 1. IL CORPUS E' NEL CODICE E COMPLETO: ogni gruppo `runa/verso/tipo` ha le
///    sue voci, il generato e' quello dei file;
/// 2. OGNI VOCE STA CON OGNI SPAZIO: con i valori veri dello spazio letti
///    dalle domande di prova, ogni voce trova un valore che la fa stare fra
///    40 e 50 parole, e almeno il tema ce la fa sempre;
/// 3. LA PERSONA NON SPARISCE: quando la domanda nomina una persona o una
///    cosa e il paragrafo la puo' portare, il paragrafo la porta;
/// 4. NESSUNA FORMULA: su 400 responsi composti da gettate diverse, nessuna
///    frase di sei parole o piu' torna in piu' di 12 responsi (il tre per
///    cento), e nessuna delle formule contate dal lettore torna mai.
void main() {
  final domande = <String, List<String>>{
    'decisione': [
      'Devo accettare l’offerta della nuova azienda?',
      'Devo chiudere l’amicizia con Giulia?',
      'Devo iscrivermi al corso di ceramica con Anna?',
      'Ha senso riprovarci con la mia ex?',
      'Dovrei cambiare lavoro quest’anno?',
    ],
    'scelta': [
      'Devo trasferirmi a Milano o restare a Bari?',
      'Quale strada scelgo tra i due corsi di laurea?',
    ],
    'come': [
      'Come gestisco il conflitto con il mio capo?',
      'Mio figlio sta attraversando un periodo difficile, come lo aiuto?',
      'Come posso fare pace con mia sorella?',
      'Come affronto il pranzo di Natale con la famiglia di lui?',
    ],
    'quando': [
      'Quando finirà questo periodo di stallo?',
      'Quando troverò l’amore?',
    ],
    'previsione': [
      'Passerò l’esame di stato a dicembre?',
      'Il colloquio di giovedì andrà bene?',
      'Il progetto che ho presentato verrà approvato?',
    ],
    'altrui': [
      'Cosa prova davvero Marco per me?',
      'Posso fidarmi del mio compagno?',
      'Lui tornerà da me dopo quello che è successo?',
    ],
    'vaga': ['Andrà tutto bene?', 'Che cosa mi aspetta?', 'Dimmi qualcosa.'],
  };

  test('1. IL CORPUS E\' NEL CODICE E COMPLETO', () {
    var voci = 0;
    for (final campo in const ['diretta', 'azione']) {
      final gruppi = leRisposteDirette[campo]!;
      for (final r in [
        for (final x in IlPresagioDalCorpus.rune) ...[
          '$x/dritta',
          if (!IlPresagioDalCorpus.simmetriche.contains(x)) '$x/ombra',
        ]
      ]) {
        for (final t in LeRisposteDirette.tipi) {
          final elenco = gruppi['$r/$t'];
          expect(elenco, isNotNull, reason: '$campo: manca $r/$t');
          final serve =
              IlPresagioDalCorpus.simmetriche.contains(r.split('/').first)
                  ? 8
                  : 5;
          expect(elenco!.where((v) => v.trim().isNotEmpty).length,
              greaterThanOrEqualTo(serve),
              reason: '$campo/$r/$t');
          voci += elenco.length;
        }
      }
    }
    // Il generato dice i file: lo strumento rigenera e git non vede
    // differenze. Qui si controlla che il file del corpus esista e abbia le
    // stesse voci.
    for (final campo in const ['diretta', 'azione']) {
      final righe = File('docs/corpus/rune/$campo.md')
          .readAsLinesSync()
          .where((r) => RegExp(r'^\d+\. ').hasMatch(r))
          .length;
      expect(
          righe,
          leRisposteDirette[campo]!
              .values
              .fold<int>(0, (a, v) => a + v.length));
    }
    print('ORDINE GA VOCE GA.06, RUNE: risposte dirette nel codice $voci');
    cardinaleMinimo(voci, 3000,
        cosa: 'risposte dirette',
        perche: '280 gruppi per campo, 5 voci (8 per le simmetriche)');
  });

  test('2. OGNI VOCE STA FRA 40 E 50 PAROLE COI VALORI VERI DELLO SPAZIO', () {
    final colpe = <String>[];
    var prove = 0;
    for (final MapEntry(key: tipo, value: elenco) in domande.entries) {
      for (final d in elenco) {
        final q = LaDomandaLetta.di(d);
        expect(LeRisposteDirette.tipoDelCorpus(q, d), tipo, reason: d);
        final valori = LeRisposteDirette.valori(q, d, tipo);
        for (final campo in const ['diretta', 'azione']) {
          for (final MapEntry(key: g, value: voci)
              in leRisposteDirette[campo]!.entries) {
            if (!g.endsWith('/$tipo')) continue;
            for (var i = 0; i < voci.length; i++) {
              prove++;
              if (LeRisposteDirette.riempi(voci[i], valori) == null) {
                colpe.add('$campo/$g/${i + 1} con «$d»: nessun valore la fa '
                    'stare ($valori)');
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: voci provate coi valori veri $prove, '
        'fuori misura ${colpe.length}');
    // 22 domande, ognuna contro le 224 voci del suo tipo in ciascuno dei due
    // campi (1568 voci per campo, divise in 7 tipi): 22 x 224 x 2 = 9856. Il primo numero scritto qui, 30000, era
    // una stima sbagliata fatta prima di contare.
    cardinaleMinimo(prove, 9800, cosa: 'prove di misura');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test(
      '3. LA PERSONA NON SPARISCE: il paragrafo porta cio\' che la domanda '
      'nomina', () {
    final colpe = <String>[];
    var lette = 0;
    for (final MapEntry(key: tipo, value: elenco) in domande.entries) {
      if (tipo == 'vaga') continue;
      for (final d in elenco) {
        final q = LaDomandaLetta.di(d);
        final nomina = tipo == 'decisione'
            ? LOggettoDellaDomanda.azioni(q.azione).first
            : (LOggettoDellaDomanda.di(d, q.tipo, strade: q.strade)
                    .firstOrNull ??
                q.tema);
        for (final g in gettate) {
          for (var seme = 0; seme < 20; seme++) {
            final p = IlPresagioDalCorpus.componi(
              corpus: corpusDelPresagio,
              esito: RuneCast.getta(g, random: Random(800 + seme)),
              domanda: d,
              persona: 'persona-$seme',
              oggi: DateTime(2026, 10, 21),
              memoria: LaMemoriaDelPresagio(),
            );
            lette++;
            final r = p.principale.risposta;
            // Il valore piu' fedele, o la sua forma corta: almeno la testa.
            final testa = nomina.split(' ').take(2).join(' ');
            if (!r.contains(testa)) {
              colpe.add('${g.id}, $seme, «$d»: il paragrafo non nomina '
                  '«$nomina»: «$r»');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: paragrafi letti $lette, senza la cosa '
        'della domanda ${colpe.length}');
    cardinaleMinimo(lette, 1500, cosa: 'paragrafi letti');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  });

  test(
      '4. NESSUNA FORMULA: nessuna frase torna in piu\' del tre per cento '
      'dei responsi', () {
    final conti = <String, int>{};
    var composti = 0;
    final caso = Random(4242);
    final tutte = [for (final e in domande.values) ...e];
    const vietate = [
      'lo chiede la pietra',
      'ciò che dipende da te',
      'primo passo concreto',
      'un gesto preciso',
      'la gettata indica',
      'è questa la via',
      'cura con costanza',
      'non annunciare prima del tempo',
    ];
    final colpe = <String>[];
    for (var i = 0; i < 400; i++) {
      final d = tutte[i % tutte.length];
      final p = IlPresagioDalCorpus.componi(
        corpus: corpusDelPresagio,
        esito: RuneCast.getta(gettate[caso.nextInt(4)], random: caso),
        domanda: d,
        persona: 'formula-$i',
        oggi: DateTime(2026, 10, 21),
        memoria: LaMemoriaDelPresagio(),
      );
      composti++;
      final testo = '${p.principale.risposta} ${p.principale.cosaFare}';
      for (final v in vietate) {
        if (testo.toLowerCase().contains(v)) colpe.add('«$v» in «$testo»');
      }
      final viste = <String>{};
      for (final f in testo.split(RegExp(r'[.?:;]\s+'))) {
        final k = f
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-zà-ÿ ]'), ' ')
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .join(' ');
        if (k.split(' ').length >= 6 && viste.add(k)) {
          conti[k] = (conti[k] ?? 0) + 1;
        }
      }
    }
    for (final MapEntry(key: f, value: n) in conti.entries) {
      if (n > 12) colpe.add('«$f» torna in $n responsi su $composti');
    }
    print('ORDINE GA VOCE GA.06, RUNE: responsi composti $composti, formule '
        '${colpe.length}');
    cardinaleMinimo(composti, 400, cosa: 'responsi composti');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  });
}
