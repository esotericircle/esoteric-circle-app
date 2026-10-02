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
                  campo == CampiDelPresagio.pietra
                      // L'Architetto usa per PIETRA solo {glossa}, mai
                      // {posizione} (EX Aggiunta 2).
                      ? '[$campo/$gruppo/$i] {glossa} {cosa}'
                      : campo == CampiDelPresagio.legame
                          ? '[$campo/$gruppo/$i] {gettata}'
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
    final totale = quante.values
        .expand((g) => g.values)
        .fold<int>(0, (a, b) => a + b);
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

  test('il presagio ha le tre parti, con gli spazi riempiti', () {
    final corpus = corpusDiProva(leVociCheServono());
    expect(corpus.completo, isTrue);
    for (final g in gettate) {
      final esito = RuneCast.getta(g, random: Random(7));
      final r = IlPresagioDalCorpus.componi(
        corpus: corpus,
        esito: esito,
        domanda: 'In amore, dove sto andando?',
        persona: 'persona-di-prova',
        oggi: DateTime(2026, 10, 2),
        memoria: LaMemoriaDelPresagio(),
      );
      expect(r.risposta, isNotEmpty);
      expect(r.cosaPuoiFare, isNotEmpty);
      expect(r.daDoveViene, isNotEmpty);
      for (final parte in [r.risposta, r.cosaPuoiFare, r.daDoveViene]) {
        expect(parte.contains('{'), isFalse, reason: parte);
      }
      expect(r.risposta, contains('l’amore'));
      // Una voce di PIETRA per ogni pietra letta, e il legame.
      expect('[pietra/'.allMatches(r.daDoveViene).length, esito.rune.length);
      expect(r.daDoveViene, contains('[legame/${g.id}/'));
    }
  });

  test('stessa gettata e stessa domanda nello stesso giorno: stesso presagio',
      () {
    final corpus = corpusDiProva(leVociCheServono());
    final memoria = LaMemoriaDelPresagio();
    final esito = RuneCast.getta(gettate[1], random: Random(3));
    Map<String, String> una() {
      final r = IlPresagioDalCorpus.componi(
        corpus: corpus,
        esito: esito,
        domanda: 'Nel lavoro, quale passo fare?',
        persona: 'p',
        oggi: DateTime(2026, 10, 2, 9),
        memoria: memoria,
      );
      return {'r': r.risposta, 'd': r.daDoveViene, 'c': r.cosaPuoiFare};
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
            );
            // Le voci del presagio appena composto: ognuna gia' letta nei
            // sessanta giorni (anche oggi, in un'altra gettata) e' una
            // ripetizione.
            final nuove =
                memoria.diOggi[IlPresagioDalCorpus.firma(esito, domanda)]!;
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
