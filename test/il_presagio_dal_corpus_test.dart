// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE RUNE DAL CORPUS, SENZA RIPETIZIONI PER SESSANTA GIORNI.** Ordine EX
/// voce 03.
///
/// Le prove che leggeranno il corpus dell'Architetto. Finche' il corpus non
/// e' entrato si provano col **corpus di prova**: per ogni gruppo tante voci
/// quante la specifica ne chiede (`docs/corpus/rune/le_voci_che_servono.txt`),
/// ognuna fatta solo del suo identificativo e degli spazi da riempire. Non e'
/// un testo: e' la forma che il testo dell'Architetto dovra' avere.
///
/// **LA FORMA DELL'ORDINE GA, voci GA.03, GA.05 e GA.07, 20 ottobre 2026.**
/// Il presagio non e' piu' un `Responso` in tre parti (la risposta, il cosa
/// puoi fare, il da dove viene con una PIETRA per pietra e il LEGAME): e' un
/// `IlPresagioComposto`, col responso principale nella forma comune (la
/// risposta RISPOSTA piu' VERDETTO, il riquadro col GESTO, nella Lunga il
/// LEGAME e il galdr) e una scheda per pietra (PIETRA e il campo nuovo
/// CONSIGLIO) quando le pietre sono piu' di una. Il corpus di prova porta i
/// sei campi e gli spazi dell'ordine GA: `{cosa}` in PIETRA, niente
/// `{glossa}`. Le prove qui sotto pretendono le stesse cose di prima nella
/// forma nuova, e i sessanta giorni si contano nella Lunga, che e' il caso
/// che legge piu' voci.
void main() {
  /// Le voci che servono, gruppo per gruppo, dal file della specifica.
  Map<String, Map<String, int>> leVociCheServono() {
    final righe =
        File('docs/corpus/rune/le_voci_che_servono.txt').readAsLinesSync();
    final out = <String, Map<String, int>>{};
    String? campo;
    for (final r in righe) {
      final testa = RegExp(r'^([A-Z]+): \d+ gruppi').firstMatch(r);
      if (testa != null) {
        campo = testa.group(1)!.toLowerCase();
        out[campo] = {};
        continue;
      }
      final voce = RegExp(r'^  (\S+) / (\S+): (\d+)$').firstMatch(r);
      if (voce != null && campo != null) {
        out[campo]!['${voce.group(1)}/${voce.group(2)}'] =
            int.parse(voce.group(3)!);
      }
    }
    return out;
  }

  /// Il corpus di prova: identificativi e spazi, nessun testo.
  CorpusDelPresagio corpusDiProva(Map<String, Map<String, int>> quante) =>
      CorpusDelPresagio({
        for (final campo in CampiDelPresagio.tutti)
          campo: {
            for (final gruppo in IlPresagioDalCorpus.gruppiDi(campo))
              gruppo: [
                for (var i = 1; i <= quante[campo]![gruppo]!; i++)
                  // Dall'ordine GA: PIETRA porta solo {cosa}, CONSIGLIO e
                  // VERDETTO nessuno spazio (SPECIFICA.md, sezione 2).
                  campo == CampiDelPresagio.legame
                      ? '[$campo/$gruppo/$i] {gettata}'
                      : campo == CampiDelPresagio.consiglio ||
                              campo == CampiDelPresagio.verdetto
                          ? '[$campo/$gruppo/$i]'
                          : '[$campo/$gruppo/$i] {cosa}',
              ]
          }
      });

  test('i gruppi della specifica sono quelli del codice', () {
    final quante = leVociCheServono();
    for (final campo in CampiDelPresagio.tutti) {
      final dalCodice = IlPresagioDalCorpus.gruppiDi(campo).toSet();
      final dallaSpecifica = quante[campo]!.keys.toSet();
      expect(dalCodice, dallaSpecifica, reason: campo);
    }
    final totale =
        quante.values.expand((g) => g.values).fold<int>(0, (a, b) => a + b);
    cardinaleMinimo(totale, 4000, cosa: 'voci che servono al corpus');
    print('ORDINE EX VOCE 03: gruppi '
        '${quante.values.fold<int>(0, (a, g) => a + g.length)}, voci che '
        'servono $totale');
  });

  test('un corpus vuoto non e\' completo: la lettura resta quella del modello',
      () {
    expect(CorpusDelPresagio.vuoto.completo, isFalse);
    expect(CorpusDelPresagio.vuoto.quante, 0);
  });

  test('il presagio ha la forma nuova, con gli spazi riempiti', () {
    final corpus = corpusDiProva(leVociCheServono());
    expect(corpus.completo, isTrue);
    for (final g in gettate) {
      final esito = RuneCast.getta(g, random: Random(7));
      for (final lunga in const [false, true]) {
        final p = IlPresagioDalCorpus.componi(
          corpus: corpus,
          esito: esito,
          domanda: 'In amore, dove sto andando?',
          persona: 'persona-di-prova',
          oggi: DateTime(2026, 10, 2),
          memoria: LaMemoriaDelPresagio(),
          lunga: lunga,
        );
        final r = p.principale;
        // **DALL'ORDINE GA VOCE GA.06** il paragrafo e' la prima frase che
        // risponde alla domanda (`LaRispostaDellaGettata`) piu' RISPOSTA, e
        // il riquadro di una domanda e' scritto per la domanda: il VERDETTO
        // non si mostra piu', il GESTO resta per chi getta senza domanda
        // (prova qui sotto). Qui c'erano le attese di prima, `[verdetto/` nel
        // paragrafo e `[gesto/` nel riquadro.
        // Il corpus di prova ha voci di due parole, che nessuna prima frase
        // porta fra 40 e 50: qui il paragrafo prende la riserva (RISPOSTA piu'
        // VERDETTO). Sul corpus vero la riserva non si usa mai: lo pretende
        // `la_risposta_della_gettata_test.dart`, prova 3.
        expect(r.risposta, contains('[risposta/'));
        // "In amore, dove sto andando?" e' una domanda aperta del Cerchio:
        // dal secondo giro della voce GA.06 il suo riquadro e' il GESTO della
        // pietra (le domande con un tipo hanno il riquadro scritto per loro,
        // `azione.md`, e lo sorveglia `le_risposte_dirette_delle_rune_test`).
        expect(r.cosaFare, contains('[gesto/'));
        expect(r.cosaFare, contains('l’amore'));
        final senzaDomanda = IlPresagioDalCorpus.componi(
          corpus: corpus,
          esito: esito,
          domanda: '',
          persona: 'persona-di-prova',
          oggi: DateTime(2026, 10, 2),
          memoria: LaMemoriaDelPresagio(),
          lunga: lunga,
        );
        expect(senzaDomanda.principale.cosaFare, contains('[gesto/'));
        expect(r.daDoveViene, isNotEmpty);
        for (final parte in [...r.paragrafi, r.daDoveViene!]) {
          expect(parte.contains('{'), isFalse, reason: parte);
        }
        expect(r.risposta, contains('l’amore'));
        if (lunga) {
          // Il legame della gettata e il galdr della pietra che decide.
          expect(r.approfondimento, contains('[legame/${g.id}/'));
          expect(r.rito, isNotNull);
        } else {
          expect(r.approfondimento, isNull);
          expect(r.rito, isNull);
        }
        // Una scheda per pietra, con PIETRA e CONSIGLIO; nessuna con una
        // pietra sola.
        expect(p.schede.length, esito.rune.length > 1 ? esito.rune.length : 0);
        for (final s in p.schede) {
          expect(s.risposta, contains('[pietra/'));
          expect(s.cosaFare, contains('[consiglio/'));
        }
      }
    }
  });

  test('stessa gettata e stessa domanda nello stesso giorno: stesso presagio',
      () {
    final corpus = corpusDiProva(leVociCheServono());
    final memoria = LaMemoriaDelPresagio();
    final esito = RuneCast.getta(gettate[1], random: Random(3));
    List<String> una() {
      final p = IlPresagioDalCorpus.componi(
        corpus: corpus,
        esito: esito,
        domanda: 'Nel lavoro, quale passo fare?',
        persona: 'p',
        oggi: DateTime(2026, 10, 2, 9),
        memoria: memoria,
        lunga: true,
      );
      return [p.inParole, for (final s in p.schede) ...s.paragrafi];
    }

    expect(una(), una());
  });

  test(
      'SESSANTA GIORNI AL MASSIMO DELL\'ILLUMINATO: nessuna voce torna alla '
      'stessa persona', () {
    final quante = leVociCheServono();
    final corpus = corpusDiProva(quante);
    var ripetute = 0;
    var lette = 0;
    for (final peggiore in [false, true]) {
      for (var persona = 0; persona < 150; persona++) {
        final caso = Random(1000 * (peggiore ? 2 : 1) + persona);
        final memoria = LaMemoriaDelPresagio();
        final ultimaLettura = <String, int>{};
        for (var giorno = 0; giorno < 60; giorno++) {
          final oggi = DateTime(2026, 10, 2).add(Duration(days: giorno));
          for (var g = 0; g < 3; g++) {
            final gettata =
                peggiore ? gettate.last : gettate[caso.nextInt(gettate.length)];
            final esito = RuneCast.getta(gettata, random: caso);
            // Domande diverse a ogni gettata: la stessa firma lo stesso giorno
            // ridarebbe lo stesso presagio, ed e' voluto.
            final domanda = 'domanda $giorno $g';
            IlPresagioDalCorpus.componi(
              corpus: corpus,
              esito: esito,
              domanda: domanda,
              persona: 'persona-$persona',
              oggi: oggi,
              memoria: memoria,
              lunga: true,
            );
            // Le voci del presagio appena composto: ognuna gia' letta nei
            // sessanta giorni (anche oggi, in un'altra gettata) e' una
            // ripetizione.
            final nuove = memoria
                .diOggi[IlPresagioDalCorpus.firma(esito, domanda)]!.values;
            for (final id in nuove) {
              final prima = ultimaLettura[id];
              if (prima != null && giorno - prima < 60) ripetute++;
              ultimaLettura[id] = giorno;
            }
            lette++;
          }
        }
      }
    }
    print('ORDINE EX VOCE 03: gettate simulate $lette, voci ripetute in 60 '
        'giorni $ripetute');
    cardinaleMinimo(lette, 50000, cosa: 'gettate simulate');
    expect(ripetute, 0);
  }, timeout: const Timeout(Duration(minutes: 10)));
}
