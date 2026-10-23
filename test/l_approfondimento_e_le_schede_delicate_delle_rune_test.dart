// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'APPROFONDIMENTO COMPOSTO E LE SCHEDE DI SALUTE, LEGGE E DENARO.**
/// Ordine GA voce GA.06, riapertura delle Rune di Caligo, 21 ottobre 2026.
///
/// Tre difetti della lettura severa (la mia, sulle dodici gettate di dopo il
/// terzo giro dei lettori ciechi), ognuno col suo padre:
/// 1. L'APPROFONDIMENTO CONCORDA E NON CONTRADDICE: "Da sola la pietra non
///    danno un verdetto" (padre: la riapertura stessa, voce GA.06, la chiusa
///    scritta al plurale), e una pietra in ombra aperta col significato della
///    dritta ("qualcosa di nuovo germoglia" sopra "un germoglio che stenta");
/// 2. NESSUN SENSO DA ESITO SOTTO SALUTE, LEGGE E DENARO: "un bene che cresce
///    quando circola" sotto un investimento, "una rottura che libera spazio"
///    sotto un'operazione al ginocchio, "una crescita che si e' fermata" sotto
///    "Rimarro' incinta?" (padre: i sensi scritti per ogni domanda in
///    `LaPietraLetta.tutte`, ordine GA voce GA.06);
/// 3. LE SCHEDE DI UNA GETTATA NON HANNO LO STESSO TESTO: il telo ha sette
///    pietre e le forme erano sei (padre: `formeSchedaDelicata` e
///    `formeConsiglioDelicato`, la riapertura), e nessuna ripete il riquadro
///    del principale.
void main() {
  test('1. L\'APPROFONDIMENTO ESISTE SEMPRE E CONCORDA CON LE PIETRE', () {
    final colpe = <String>[];
    var provati = 0;
    for (final g in gettate) {
      for (var seme = 0; seme < 120; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        for (final direzione in <ClasseDellaPietra?>[
          null,
          ...ClasseDellaPietra.values
        ]) {
          for (final ambito in <AmbitoDelicato?>[
            null,
            ...AmbitoDelicato.values
          ]) {
            for (var v = 0; v < 3; v++) {
              provati++;
              final t = LaRispostaDellaGettata.approfondimento(
                  esito: esito,
                  direzione: direzione,
                  ambito: ambito,
                  variante: v);
              final dove = '${g.id} seme $seme $direzione $ambito v$v';
              if (t == null) {
                colpe.add('$dove: nessuna composizione nella misura');
                continue;
              }
              if (esito.rune.length == 1) {
                if (RegExp(r'pietra (non )?(danno|sostengono|chiedono|dicono)')
                    .hasMatch(t)) {
                  colpe
                      .add('$dove: verbo al plurale con una pietra sola: «$t»');
                }
                final p = esito.rune.first;
                if (p.inOmbra && t.contains(p.rune.meaning)) {
                  colpe.add('$dove: la pietra in ombra apre col significato '
                      'della dritta: «$t»');
                }
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: approfondimenti provati $provati, '
        'difetti ${colpe.length}');
    cardinaleMinimo(provati, 10000, cosa: 'approfondimenti provati');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('2. SALUTE, LEGGE E DENARO: NESSUN SENSO CHE SUONI COME UN ESITO', () {
    const domande = <String>[
      'L\'operazione al ginocchio del mese prossimo andrà bene?',
      'Rimarrò incinta quest\'anno?',
      'Conviene investire i miei risparmi in borsa adesso?',
      'Compro casa adesso o aspetto un anno?',
      'Vincerò la causa contro il mio ex socio?',
      'Il mio cane guarirà?',
    ];
    final esito = RegExp(r'bene che cresce quando circola|bene che si disperde|'
        r'rottura che libera|crescita che si è fermata|'
        r'qualcosa di nuovo che germoglia|abitudine ereditata|'
        r'fretta che ferisce|raccolto');
    final virgolaPrimaDiE = RegExp(r',\s+(e|ed)\s');
    // "parla di il passo giusto": la preposizione si contrae (lettura severa
    // del terzo giro, padre: la forma delle schede delicate, riapertura).
    final nonContratta = RegExp(r'\bdi (il|lo|la|i|gli|le) ');
    final colpe = <String>[];
    var testi = 0;
    for (final d in domande) {
      for (final g in gettate) {
        for (var seme = 0; seme < 24; seme++) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: RuneCast.getta(g, random: Random(seme)),
            domanda: d,
            persona: 'delicata-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
            lunga: true,
          );
          final tutti = [
            p.principale.risposta,
            p.principale.cosaFare,
            p.principale.approfondimento ?? '',
            for (final s in p.schede) ...[s.risposta, s.cosaFare],
          ];
          for (final t in tutti) {
            testi++;
            if (esito.hasMatch(t)) {
              colpe.add('«$d»: un senso da esito: «$t»');
            }
            if (virgolaPrimaDiE.hasMatch(t)) {
              colpe.add('«$d»: virgola prima di "e": «$t»');
            }
            if (nonContratta.hasMatch(t)) {
              colpe.add('«$d»: preposizione non contratta: «$t»');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: testi delicati letti $testi, difetti '
        '${colpe.length}');
    cardinaleMinimo(testi, 2500, cosa: 'testi delicati letti');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('3. LE SCHEDE DELICATE DI UNA GETTATA NON HANNO LO STESSO TESTO', () {
    const domande = <String>[
      'L\'operazione al ginocchio del mese prossimo andrà bene?',
      'Conviene investire i miei risparmi in borsa adesso?',
      'Vincerò la causa contro il mio ex socio?',
      'Devo lasciare il lavoro per tornare a studiare?',
      'Mi devo operare alla schiena?',
      'Devo fare causa al mio datore di lavoro?',
    ];
    final colpe = <String>[];
    var gettateLette = 0;
    for (final d in domande) {
      for (final g in gettate) {
        for (var seme = 0; seme < 40; seme++) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: RuneCast.getta(g, random: Random(500 + seme)),
            domanda: d,
            persona: 'delicata-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
          );
          if (p.schede.length < 2) continue;
          gettateLette++;
          final azioni = {for (final s in p.schede) s.cosaFare};
          final paragrafi = {for (final s in p.schede) s.risposta};
          if (azioni.length != p.schede.length) {
            colpe.add('${g.id} seme $seme «$d»: due schede con lo stesso '
                'cosa fare');
          }
          if (paragrafi.length != p.schede.length) {
            colpe.add('${g.id} seme $seme «$d»: due schede con lo stesso '
                'paragrafo');
          }
          for (final s in p.schede) {
            if (s.cosaFare == p.principale.cosaFare) {
              colpe.add('${g.id} seme $seme «$d»: una scheda ripete il '
                  'riquadro del principale');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: gettate delicate con schede '
        '$gettateLette, schede uguali ${colpe.length}');
    cardinaleMinimo(gettateLette, 300, cosa: 'gettate delicate con schede');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('4. OGNI FORMA DELLA SCHEDA DELICATA E\' ITALIANO: QUARANTA PIETRE', () {
    final nonContratta = RegExp(r'\bdi (il|lo|la|i|gli|le) ');
    final virgolaPrimaDiE = RegExp(r',\s+(e|ed)\s');
    final esito = RegExp(r'bene che cresce quando circola|bene che si '
        r'disperde|rottura che libera|crescita che si è fermata|'
        r'qualcosa di nuovo che germoglia|abitudine ereditata|'
        r'fretta che ferisce|raccolto');
    final colpe = <String>[];
    var forme = 0;
    for (final rune in kElderFuthark) {
      final versi = kRuneSimmetriche.contains(rune.name)
          ? const [RuneVerso.dritto]
          : RuneVerso.values;
      for (final verso in versi) {
        for (final posto in const ['Urdhr', 'Ostacolo', 'Al centro', 'Cuore']) {
          final pietra = RunaGettata(
              rune: rune,
              verso: verso,
              posizione: PosizioneGettata(posto, 'prova'));
          for (final ambito in AmbitoDelicato.values) {
            for (var chi = 0; chi < 8; chi++) {
              for (final f in LaRispostaDellaGettata.formeSchedaDelicata(
                  ambito: ambito, pietra: pietra, chi: chi)) {
                forme++;
                final dove = '${rune.name} $verso $posto ${ambito.name}';
                if (nonContratta.hasMatch(f)) {
                  colpe.add('$dove: preposizione non contratta: «$f»');
                }
                if (virgolaPrimaDiE.hasMatch(f)) {
                  colpe.add('$dove: virgola prima di "e": «$f»');
                }
                if (esito.hasMatch(f)) {
                  colpe.add('$dove: un senso da esito: «$f»');
                }
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: forme delicate lette $forme, difetti '
        '${colpe.length}');
    cardinaleMinimo(forme, 20000, cosa: 'forme delicate lette');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });
}
