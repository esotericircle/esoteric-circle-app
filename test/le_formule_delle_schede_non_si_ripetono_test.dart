// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.g.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE FORMULE DELLE SCHEDE NON SI RIPETONO, E I PRESUPPOSTI DEL LETTORE
/// SONO FUORI.** Ordine GA voce GA.06, riapertura delle Rune di Caligo,
/// ultimo giro, 21 ottobre 2026.
///
/// Il lettore cieco indipendente sulle dodici gettate varie: "Per questa
/// situazione" apriva 15 testi, "Una voce lieve:" 10 titoli, "per questo
/// momento" era infilato a forza nel paragrafo e nel riquadro di una domanda
/// vaga, "un giorno alla volta" chiudeva tutte e cinque le schede di
/// un'operazione al ginocchio; e voci scritte per ogni domanda davano per
/// presenti cose che la domanda non porta ("le tre persone che contano" sotto
/// una dichiarazione d'amore, "il compito che ti preoccupa", "stai vedendo
/// conferme in ogni coincidenza", "arriva il freddo"). Padri: `diretta.md` e
/// `azione.md` del secondo giro (la cosa che apre il testo, le persone care
/// nelle decisioni di Wunjo), `pietra.md` e `consiglio.md` dell'ordine EX
/// voce 03 (le voci neutre), `titoloDellaScheda` della prima riapertura.
void main() {
  const domande = <String>[
    'Come gestisco il conflitto con il mio capo?',
    'Devo lasciare Roma, e se lo faccio la mia famiglia capirà?',
    'Devo accettare l’offerta della nuova azienda?',
    'Come posso fare pace con mia sorella?',
    'Devo dirle che sono innamorato di lei?',
    'Il colloquio di giovedì andrà bene?',
    'Quando finirà questo periodo di stallo?',
    'Passerò l’esame di stato a dicembre?',
  ];

  List<IlPresagioComposto> componi(String domanda, {int semi = 24}) {
    final fuori = <IlPresagioComposto>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        fuori.add(IlPresagioDalCorpus.componi(
          corpus: corpusDelPresagio,
          esito: RuneCast.getta(g, random: Random(1500 + seme)),
          domanda: domanda,
          persona: 'formule-$seme',
          oggi: DateTime(2026, 10, 21),
          memoria: LaMemoriaDelPresagio(),
        ));
      }
    }
    return fuori;
  }

  test('1. UNA COSA GENERICA NON APRE IL TESTO DELLE SCHEDE', () {
    final apre = RegExp(r'^Per (questa|questo) (situazione|decisione|scelta|'
        r'legame|momento)\b');
    var schede = 0;
    var aperte = 0;
    final esempi = <String>[];
    for (final d in domande) {
      for (final p in componi(d)) {
        for (final s in p.schede) {
          for (final t in [s.risposta, s.cosaFare]) {
            schede++;
            if (apre.hasMatch(t)) {
              aperte++;
              if (esempi.length < 4) esempi.add(t);
            }
          }
        }
      }
    }
    final quota = aperte / schede;
    print('ORDINE GA VOCE GA.06, RUNE: testi di schede $schede, aperti da '
        '"Per questa situazione" e simili $aperte '
        '(${(quota * 100).toStringAsFixed(1)} per cento)');
    cardinaleMinimo(schede, 5000, cosa: 'testi di schede letti');
    expect(quota, lessThan(0.03), reason: esempi.join('\n'));
  });

  test('2. "PER QUESTO MOMENTO" NON STA NEL PARAGRAFO E NEL RIQUADRO', () {
    var vaghe = 0;
    final colpe = <String>[];
    for (final d in const [
      'Andrà tutto bene?',
      'Che cosa mi aspetta?',
      'Dimmi qualcosa.',
      'Come sarà il mio futuro?'
    ]) {
      for (final p in componi(d, semi: 12)) {
        vaghe++;
        if (p.principale.risposta.contains('per questo momento') &&
            p.principale.cosaFare.contains('per questo momento')) {
          colpe.add('«$d»: ${p.principale.risposta}\n${p.principale.cosaFare}');
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: responsi di domande vaghe $vaghe, con '
        '"per questo momento" due volte ${colpe.length}');
    cardinaleMinimo(vaghe, 150, cosa: 'responsi di domande vaghe');
    expect(colpe, isEmpty, reason: colpe.take(3).join('\n'));
  });

  test('3. "UNA VOCE LIEVE" NON APRE PIU\' DI UN TITOLO SU DUE AI MARGINI', () {
    var margini = 0;
    var lievi = 0;
    final titoli = <String>{};
    for (final d in domande) {
      for (final p in componi(d, semi: 8)) {
        for (final s in p.schede) {
          final t = s.titolo;
          final ruolo = t.split(':').first;
          if (LaRispostaDellaGettata.ruoliAiMargini.contains(ruolo)) {
            margini++;
            titoli.add(ruolo);
            if (ruolo == 'Una voce lieve') lievi++;
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: schede ai margini $margini, '
        '"Una voce lieve" $lievi, titoli diversi ${titoli.length}');
    cardinaleMinimo(margini, 250, cosa: 'schede ai margini');
    expect(titoli.length, greaterThanOrEqualTo(5));
    expect(lievi / margini, lessThan(0.4));
  });

  test(
      '4. LE VOCI NEUTRE NON DANNO PER PRESENTE CIO\' CHE UN LETTORE HA CONTATO',
      () {
    final presupposti =
        RegExp(r'stai vedendo conferme in ogni coincidenza|arriva il freddo|'
            r'applicazioni che ti mostrano|il compito che ti preoccupa|'
            r'il blocco che hai davanti|le tue carte migliori|'
            r'qualcosa più grande di te|ciò che hai perso');
    var voci = 0;
    final colpe = <String>[];
    for (final campo in corpusDelPresagio.voci.entries) {
      for (final gruppo in campo.value.entries) {
        for (var i = 0; i < gruppo.value.length; i++) {
          voci++;
          if (presupposti.hasMatch(gruppo.value[i])) {
            colpe
                .add('${campo.key}/${gruppo.key}/${i + 1}: ${gruppo.value[i]}');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: voci del corpus del presagio lette '
        '$voci, con un presupposto contato dal lettore ${colpe.length}');
    cardinaleMinimo(voci, 7000, cosa: 'voci del corpus lette');
    expect(colpe, isEmpty, reason: colpe.take(5).join('\n'));
  });

  test('5. NIENTE PERSONE CARE CHE LA DOMANDA NON NOMINA', () {
    // "le tre persone che contano di piu'" sotto "Devo dirle che sono
    // innamorato di lei?": una dichiarazione si legge come una dichiarazione.
    final terzi = RegExp(r'persone che contano|tre persone|persone care|'
        r'stare meglio con le persone');
    var testi = 0;
    final colpe = <String>[];
    for (final d in const [
      'Devo dirle che sono innamorato di lei?',
      'Devo accettare l’offerta della nuova azienda?',
      'Come gestisco il conflitto con il mio capo?',
      'Devo trasferirmi a Milano o restare a Bari?',
    ]) {
      for (final p in componi(d, semi: 16)) {
        for (final r in [p.principale, ...p.schede]) {
          for (final t in [r.risposta, r.cosaFare]) {
            testi++;
            if (terzi.hasMatch(t)) colpe.add('«$d»: $t');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: testi letti $testi, con persone care '
        'non nominate dalla domanda ${colpe.length}');
    cardinaleMinimo(testi, 2000, cosa: 'testi letti');
    expect(colpe, isEmpty, reason: colpe.take(5).join('\n'));
  });

  test(
      '6. IL FILTRO ESCLUDE OGNI VOCE CHE NOMINA PERSONE CHE LA DOMANDA NON '
      'NOMINA', () {
    // La proprieta' del filtro, non di un campione di gettate: ogni voce del
    // corpus che parla di "persone che contano" o "persone care" non regge con
    // una domanda senza terzi, e regge con una che li porta.
    final terzi = RegExp(r'persone che contano|tre persone|persone care|'
        r'stare meglio con le persone');
    var conTerzi = 0;
    final colpe = <String>[];
    for (final campo in leRisposteDirette.entries) {
      for (final gruppo in campo.value.entries) {
        for (final voce in gruppo.value) {
          if (!terzi.hasMatch(voce)) continue;
          conTerzi++;
          if (LeRisposteDirette.regge(voce, 'questa decisione',
              chiude: true,
              licenze: const {'controparte', 'paura', 'conflitto'})) {
            colpe.add('regge senza terzi: $voce');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: voci che nominano persone care '
        '$conTerzi, che reggono con una domanda senza terzi ${colpe.length}');
    cardinaleMinimo(conTerzi, 15, cosa: 'voci con persone care');
    expect(colpe, isEmpty, reason: colpe.take(4).join('\n'));
  });
}
