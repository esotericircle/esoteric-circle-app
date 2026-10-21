// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE SCHEDE DELLE SINGOLE PIETRE SEGUONO LA DOMANDA.** Ordine GA voce
/// GA.06, riapertura delle Rune di Caligo, 21 ottobre 2026.
///
/// Il fondatore: *"Le risposte vanno curate, sono la parte più importante e
/// criticata dell'app."* Il lettore cieco indipendente, sulle dodici gettate
/// del terzo giro: le schede delle singole pietre avevano il "Cosa fare"
/// slegato dalla domanda o dalla propria risposta in 21 casi su 34, davano
/// per presente "l'altra persona" o "le scosse", e sotto salute, legge e
/// denaro non mandavano da chi e' competente. La lettura severa di chi ha
/// curato (le dodici di dopo) ne ha trovato altre cinque famiglie, che questa
/// guardia misura ognuna per conto suo, sul presagio composto dal corpus
/// vero:
///
/// 1. UNA SCHEDA NON PRESUPPONE UN CONFLITTO O UNA PAURA CHE LA DOMANDA NON
///    PORTA ("la tentazione della ripicca" sotto "Devo dirle che sono
///    innamorato?"); padre: `diretta.md` e `azione.md` del secondo giro, scritte
///    per il caso difficile di ogni tipo;
/// 2. NIENTE "CHI E' COINVOLTO" QUANDO LA DOMANDA NOMINA LA PERSONA ("Marco",
///    "il mio capo", "mia sorella"); padre: le stesse voci;
/// 3. SOTTO UNA PERSONA CHE NON C'E' PIU' NIENTE USCITE INSIEME ("una
///    colazione insieme a lui" sotto "Lui tornerà da me?");
/// 4. UN EVENTO A PICCOLA SCADENZA NON HA UN COSA FARE CHE COMINCIA DOPO
///    SETTE GIORNI ("Rileggi il foglio dopo sette giorni" sotto "Il colloquio
///    di giovedì andrà bene?", rune-21);
/// 5. NESSUNA CUCITURA RIPETUTA: la cosa lunga della domanda ("per il
///    conflitto con il tuo capo") non apre piu' di meta' delle schede, e due
///    schede della stessa gettata non hanno lo stesso testo.
void main() {
  /// Le domande con un tipo del corpus, ognuna con la parola che la licenzia
  /// o la vieta. Scritte a mano: sono la lista dei casi letti.
  const domande = <String>[
    'Come gestisco il conflitto con il mio capo?',
    'Cosa prova davvero Marco per me?',
    'Lui tornerà da me dopo quello che è successo?',
    'Devo dirle che sono innamorato di lei?',
    'Il colloquio di giovedì andrà bene?',
    'Come affronto il pranzo di Natale con la famiglia di lui?',
    'Devo accettare l’offerta della nuova azienda?',
    'Come posso fare pace con mia sorella?',
    'Il progetto che ho presentato verrà approvato?',
    'La mia relazione può durare nonostante la distanza?',
    'Quando finirà questo periodo di stallo?',
    'Devo trasferirmi a Milano o restare a Bari?',
    'Posso fidarmi del mio compagno?',
    'Come faccio a dimenticarlo?',
    'Mio figlio sta attraversando un periodo difficile, come lo aiuto?',
    'Passerò l’esame di stato a dicembre?',
  ];

  // Le parole che una voce non puo' dare per presenti se la domanda non le
  // porta: scritte qui e non lette dal codice, perche' la prova sappia da sola
  // che cosa cerca.
  final conflitto =
      RegExp(r'(?<![a-zà-ÿ])(ripicc[a-zà-ÿ]*|rimprover[a-zà-ÿ]*|rivalsa|rabbia|'
          r'litig[a-zà-ÿ]*|provoc[a-zà-ÿ]*|rancor[a-zà-ÿ]*)'
          r'(?![a-zà-ÿ])');
  final paura =
      RegExp(r'(?<![a-zà-ÿ])(paur[a-zà-ÿ]*|timor[a-zà-ÿ]*|ansi[a-zà-ÿ]*|'
          r'angosc[a-zà-ÿ]*)(?![a-zà-ÿ])');
  final presenza = RegExp(r'insieme a (lui|lei)|a quattr.occhi|'
      r'(passeggiata|colazione|caffè|cena|pranzo|serata|uscita) '
      r'(insieme|con (lui|lei))|momento (sereno |piacevole )?da condividere|'
      r'guardando (in faccia|negli occhi)|un caffè');
  final lungo = RegExp(r'sette giorni|due settimane|tre settimane|'
      r'quindici giorni|ogni (domenica|lunedì)|un mese|tutti i giorni');

  List<IlPresagioComposto> componi(String domanda, {int semi = 8}) {
    final fuori = <IlPresagioComposto>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        fuori.add(IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: RuneCast.getta(g, random: Random(300 + seme)),
          domanda: domanda,
          persona: 'lettore-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
          lunga: seme.isOdd,
        ));
      }
    }
    return fuori;
  }

  test('1. NIENTE CONFLITTO O PAURA CHE LA DOMANDA NON PORTA', () {
    final colpe = <String>[];
    var testi = 0;
    for (final d in domande) {
      final lic = LeRisposteDirette.licenze(d);
      for (final p in componi(d)) {
        for (final r in [p.principale, ...p.schede]) {
          for (final t in [r.risposta, r.cosaFare]) {
            testi++;
            if (!lic.contains('conflitto') && conflitto.hasMatch(t)) {
              colpe.add('«$d»: conflitto non portato dalla domanda: «$t»');
            }
            if (!lic.contains('paura') && paura.hasMatch(t)) {
              colpe.add('«$d»: paura non portata dalla domanda: «$t»');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: testi letti $testi, che presuppongono '
        'un conflitto o una paura non portati ${colpe.length}');
    cardinaleMinimo(testi, 4000, cosa: 'testi delle schede letti');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('2. LA PERSONA NOMINATA PRENDE IL POSTO DI "CHI E\' COINVOLTO"', () {
    const conPersona = <String>[
      'Come gestisco il conflitto con il mio capo?',
      'Cosa prova davvero Marco per me?',
      'Come posso fare pace con mia sorella?',
      'Mio figlio sta attraversando un periodo difficile, come lo aiuto?',
      'Posso fidarmi del mio compagno?',
    ];
    final colpe = <String>[];
    var testi = 0;
    for (final d in conPersona) {
      for (final p in componi(d)) {
        for (final r in [p.principale, ...p.schede]) {
          for (final t in [r.risposta, r.cosaFare]) {
            testi++;
            if (RegExp(r'chi è coinvolt[oa]|persona coinvolta').hasMatch(t)) {
              colpe.add('«$d»: la persona c\'e\' ma il testo dice "coinvolto": '
                  '«$t»');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: testi con la persona nominata '
        '$testi, con "chi e\' coinvolto" ${colpe.length}');
    cardinaleMinimo(testi, 1200, cosa: 'testi con la persona nominata');
    // Una piccola parte non regge la sostituzione (il testo uscirebbe dalla
    // misura): la guardia pretende che siano meno di una su venti.
    expect(colpe.length * 20, lessThan(testi),
        reason: colpe.take(5).join('\n'));
  });

  test('3. UNA PERSONA CHE NON C\'E\' NON HA USCITE INSIEME', () {
    const assenti = <String>[
      'Lui tornerà da me dopo quello che è successo?',
      'Come faccio a dimenticarlo?',
      'La mia relazione può durare nonostante la distanza?',
    ];
    final colpe = <String>[];
    var testi = 0;
    for (final d in assenti) {
      expect(LeRisposteDirette.licenze(d), contains('assenza'), reason: d);
      for (final p in componi(d)) {
        for (final r in [p.principale, ...p.schede]) {
          for (final t in [r.risposta, r.cosaFare]) {
            testi++;
            if (presenza.hasMatch(t)) {
              colpe.add('«$d»: la persona non c\'e\' ma il testo la da per '
                  'vicina: «$t»');
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: testi sotto una persona assente '
        '$testi, che la danno per vicina ${colpe.length}');
    cardinaleMinimo(testi, 800, cosa: 'testi sotto una persona assente');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('4. UN EVENTO A PICCOLA SCADENZA NON HA UN TEMPO LUNGO', () {
    const eventi = <String>[
      'Il colloquio di giovedì andrà bene?',
      'La riunione di domani andrà bene?',
    ];
    final colpe = <String>[];
    var testi = 0;
    for (final d in eventi) {
      expect(LeRisposteDirette.licenze(d), contains('breve'), reason: d);
      for (final p in componi(d)) {
        for (final r in [p.principale, ...p.schede]) {
          testi++;
          if (lungo.hasMatch(r.cosaFare)) {
            colpe.add('«$d»: un cosa fare che comincia o dura oltre l\'evento: '
                '«${r.cosaFare}»');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: cosa fare sotto un evento breve '
        '$testi, con un tempo lungo ${colpe.length}');
    cardinaleMinimo(testi, 250, cosa: 'cosa fare sotto un evento breve');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('5. NESSUNA CUCITURA RIPETUTA E NESSUNA SCHEDA UGUALE A UN\'ALTRA', () {
    final colpe = <String>[];
    var gettate7 = 0;
    for (final d in [
      ...domande,
      'Devo lasciare il lavoro per tornare a studiare?'
    ]) {
      for (final p in componi(d)) {
        final s = p.schede;
        if (s.length < 4) continue;
        gettate7++;
        final risposte = {for (final x in s) x.risposta};
        final azioni = {for (final x in s) x.cosaFare};
        if (risposte.length != s.length) {
          colpe.add('«$d»: due schede con lo stesso paragrafo');
        }
        if (azioni.length != s.length) {
          colpe.add('«$d»: due schede con lo stesso cosa fare');
        }
        // La cosa della domanda ("per la tua relazione", "per tuo figlio")
        // non apre piu' di meta' delle schede: le dispari dicono "questa
        // situazione". Non vale per la persona (entra nel posto di "chi e'
        // coinvolto" e puo' stare in ogni scheda) ne' per il tema.
        final lettaQ = LaDomandaLetta.di(d);
        final tipoQ = LeRisposteDirette.tipoDelCorpus(lettaQ, d);
        final persona = tipoQ == null
            ? null
            : LeRisposteDirette.laPersona(lettaQ, d, tipoQ);
        for (final cosa in {
          ...LeRisposteDirette.valori(lettaQ, d, tipoQ ?? 'vaga')
        }) {
          if (cosa.split(' ').length < 2 ||
              cosa == persona ||
              cosa == lettaQ.tema ||
              const {'questo momento', 'il tuo momento'}.contains(cosa)) {
            continue;
          }
          final conteggio = s
              .where(
                  (x) => x.risposta.contains(cosa) || x.cosaFare.contains(cosa))
              .length;
          if (conteggio * 2 > s.length + 1) {
            colpe.add('«$d»: «$cosa» in $conteggio schede su ${s.length}');
          }
        }
        // Nessuna scheda ripete il riquadro del responso principale.
        for (final x in s) {
          if (x.cosaFare == p.principale.cosaFare) {
            colpe.add('«$d»: una scheda ripete il riquadro del principale');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: gettate con schede $gettate7, cuciture '
        'o schede uguali ${colpe.length}');
    cardinaleMinimo(gettate7, 250, cosa: 'gettate con schede');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });
}
