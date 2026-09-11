// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'motore_della_ripetizione.dart';

/// **LA GUARDIA DELLA DIVERSITA'.** Ordine DF voce 06.1, 11 settembre 2026.
///
/// *"Esegue le quattro misure della voce 02 su tutte le funzioni censite, non
/// su un campione, e fallisce se una qualsiasi scende sotto una qualsiasi delle
/// quattro soglie. Quando fallisce nomina la funzione, quale delle quattro
/// misure ha ceduto, il numero misurato, la soglia e i due testi della coppia
/// peggiore."*
///
/// **QUALI FUNZIONI, e perche' queste.** Tutte le arti in cui **la persona pone
/// una domanda**, che e' il confine dichiarato in testa all'ordine DF: la
/// regola della giornata stabile *"riguarda e riguardava solo l'oroscopo
/// perche' non c'e' domanda da parte dell'utente"*. Dove la domanda c'e', ogni
/// consultazione e' un evento nuovo.
///
/// Il censimento completo, con i pezzi fissi e quelli variabili di **ogni**
/// funzione che produce testo, sta in `docs/DF_censimento_delle_risposte.md`.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Raccoglie gli esiti e li stampa tutti, poi fa cadere la prova una volta
  /// sola con l'elenco di cio' che ha ceduto: **un rapporto che si legge in
  /// blocco vale piu' di quattro cadute separate**.
  final esiti = <EsitoDellaRipetizione>[];

  test('TAROCCHI, la Stesa a tre carte con la stessa domanda', () {
    final caso = Random(40);
    final testi = <String>[];
    final composti = <String>[];
    final nomi = <List<String>>[];
    final simboli = <Set<String>>[];
    for (var i = 0; i < MotoreDellaRipetizione.quante; i++) {
      final stesa = TarotSpread.draw(seed: caso.nextInt(1 << 31));
      // **I SIMBOLI DI QUESTA CONSULTAZIONE**: la carta con la sua posizione,
      // perche' la stessa carta nel Passato e nel Futuro non dice lo stesso.
      simboli.add({
        for (final c in stesa.cards) '${c.position.name}:${c.card.name}',
      });
      final lettura = TarotReading.of(stesa, TarotTopic.denaro,
          domandaScritta: 'denaro e fortuna');
      testi.add([
        VoceDellaStesa.titolo(stesa),
        lettura.consiglio,
        for (final p in lettura.posizioni)
          '${p.drawn.position.label}. ${p.drawn.displayName}. '
              '${p.apertura}, ${p.testo}',
      ].join('\n\n'));
      composti.add(lettura.consiglio);
      nomi.add([
        for (final c in stesa.cards) ...[
          c.displayName,
          c.card.name,
          c.summary,
          c.meaning,
        ],
      ]);
    }
    final esito = MotoreDellaRipetizione.misura(
      funzione: 'Stesa di Tarocchi',
      testi: testi,
      nomiPerTesto: nomi,
      testiComposti: composti,
      simboliPerTesto: simboli,
    );
    esiti.add(esito);
    print(esito.refertoLungo);
    expect(esito.passa, isTrue,
        reason: 'Stesa di Tarocchi: hanno ceduto ${esito.cedute.join("; ")}');
  });

  test('RUNE, la gettata delle tre Norne con la stessa domanda', () {
    final caso = Random(51);
    final testi = <String>[];
    final nomi = <List<String>>[];
    final simboli = <Set<String>>[];
    const domanda = 'Che cosa mi aspetta sul lavoro';
    for (var i = 0; i < MotoreDellaRipetizione.quante; i++) {
      final esito =
          RuneCast.getta(gettataNorne, random: Random(caso.nextInt(1 << 31)));
      simboli.add({
        for (final r in esito.rune) '${r.posizione.glossa}:${r.rune.name}',
      });
      final responso =
          RunePresagio.componiIlResponso(esito, domanda: domanda);
      testi.add([
        responso.risposta,
        if (responso.cosaPuoiFare.trim().isNotEmpty) responso.cosaPuoiFare,
        responso.daDoveViene,
      ].join('\n\n'));
      nomi.add([
        for (final r in esito.rune) ...[
          r.rune.name,
          r.rune.meaning,
        ],
      ]);
    }
    final esito = MotoreDellaRipetizione.misura(
      funzione: 'Gettata di Rune, le tre Norne',
      testi: testi,
      nomiPerTesto: nomi,
      simboliPerTesto: simboli,
    );
    esiti.add(esito);
    print(esito.refertoLungo);
    expect(esito.passa, isTrue,
        reason: 'Gettata di Rune: hanno ceduto ${esito.cedute.join("; ")}');
  });

  test('VIAGGIO DELLO SCIAMANO, la scena che si riporta su', () {
    // **La domanda e il giorno sono gli stessi in tutte e cento**, che e' il
    // caso dell'ordine: *"stessa domanda, stesso utente, stesso giorno, stesso
    // Maestro"*.
    const domanda = 'Che cosa devo lasciare andare';
    final giorno = DateTime(2026, 9, 11);
    final testi = <String>[];
    final nomi = <List<String>>[];
    final simboli = <Set<String>>[];
    for (var i = 0; i < MotoreDellaRipetizione.quante; i++) {
      final scena = ScenaSenzaModello.componi(
        domanda: domanda,
        giorno: giorno,
        nitidezza: 1.0,
        discesa: i,
      );
      testi.add(scena.testo);
      simboli.add(scena.idDeiPezzi.toSet());
      nomi.add([
        scena.luogo.nome,
        scena.cosa.nome,
        scena.gesto.nome,
        scena.momento.nome,
      ]);
    }
    final esito = MotoreDellaRipetizione.misura(
      funzione: 'Viaggio dello Sciamano, la scena del ritorno',
      testi: testi,
      nomiPerTesto: nomi,
      simboliPerTesto: simboli,
    );
    esiti.add(esito);
    print(esito.refertoLungo);
    expect(esito.passa, isTrue,
        reason: 'Viaggio dello Sciamano: hanno ceduto '
            '${esito.cedute.join("; ")}');
  });

  tearDownAll(() {
    print('');
    print('=== ORDINE DF VOCE 06.1, IL QUADRO DELLE FUNZIONI CENSITE ===');
    for (final e in esiti) {
      print('${e.passa ? "PASSA" : "CADE "}  ${e.funzione}: '
          'A ${e.testiDistinti}/${e.quante}, '
          'B ${e.scheletriDistinti}/${e.quante} (max ripetuto '
          '${e.quanteVolteLoScheletro}), '
          'C ${(e.somiglianzaFraDiverse * 100).toStringAsFixed(1)} per cento '
          'fra le ${e.quanteCoppieDiverse} coppie senza simboli in comune '
          '(su tutte le ${e.quanteCoppie}: '
          '${(e.somiglianzaMassima * 100).toStringAsFixed(1)}), '
          'D ${e.quanteVolteIlParagrafo}');
    }
  });
}
