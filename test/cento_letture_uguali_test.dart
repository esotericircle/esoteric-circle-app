// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'motore_della_ripetizione.dart';

/// **CENTO LETTURE CON LA STESSA DOMANDA, E NESSUNA UGUALE.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **IL FATTO CHE APRE L'ORDINE.** Il fondatore ha fatto quattro Stese
/// consecutive sulla build 2245 con la stessa domanda, *denaro e fortuna*. Le
/// carte sono uscite **tutte diverse** in tutte e quattro. I primi due paragrafi
/// del Consiglio di Medora erano **identici al carattere**.
///
/// **LA CAUSA, verificata sul ramo e non dedotta.** In
/// `lib/core/tarot/tarot_reading.dart` la funzione `consiglioDi` compone il
/// primo paragrafo cosi':
///
///     '${topic.lente}, ${topic.group.risposta}',
///     topic.group.consiglio,
///
/// `topic.lente` ha **sedici** valori, uno per argomento. `group.risposta` e
/// `group.consiglio` hanno **tre** valori, uno per gruppo. **Nessuno dei tre
/// guarda le carte.** A parita' di argomento quei due paragrafi sono una
/// costante, e nessuna estrazione al mondo puo' cambiarli.
///
/// **QUESTA PROVA NASCE ROSSA**, ed e' il modo di dimostrare che misura la cosa
/// giusta.
void main() {
  /// L'ingresso identico: la domanda del fondatore, lo stesso argomento, lo
  /// stesso giorno, lo stesso Maestro.
  const argomento = TarotTopic.denaro;
  const domanda = 'denaro e fortuna';

  /// **CENTO ESTRAZIONI VERE, non cento semi finti.** Il caso lo fa la stessa
  /// classe che lo fa nell'app, cioe' `TarotSpread.draw()` senza seme, che e'
  /// esattamente cio' che la schermata chiama in produzione.
  ///
  /// **Il seme del giro e' fisso a quaranta** perche' una prova che cade a
  /// giorni alterni non e' una prova: quello che cambia fra le cento letture
  /// deve essere **l'estrazione**, non il generatore.
  List<TarotSpread> centoStese({int seme = 40}) {
    final caso = Random(seme);
    return [
      for (var i = 0; i < MotoreDellaRipetizione.quante; i++)
        TarotSpread.draw(seed: caso.nextInt(1 << 31)),
    ];
  }

  /// I nomi propri di una stesa: i nomi delle carte con e senza la parola del
  /// rovescio, e le loro sintesi brevi.
  List<String> nomiDi(TarotSpread stesa) => [
        for (final c in stesa.cards) ...[
          c.displayName,
          c.card.name,
          c.summary,
          c.meaning,
          c.card.uprightSummary,
          c.card.reversedSummary,
        ],
      ];

  /// **IL TESTO CHE LA PERSONA VEDE A SCHERMO**, e non una sola bolla.
  ///
  /// **Regola CINQUE dell'ordine DF**: *"una prova che misura un testo deve
  /// leggere il testo che la persona vede a schermo, non la stringa che lo
  /// genera"*. A schermo, nella Stesa, si legge **il titolo, il Consiglio di
  /// Medora e le tre posizioni** Passato Presente Futuro col loro testo
  /// ricco. E' quello il testo di cui il fondatore dice che non deve
  /// ripetersi, perche' e' quello che scorre sotto il dito.
  ///
  /// **E la misura sul solo Consiglio si riporta lo stesso**, piu' avanti,
  /// perche' e' la bolla che ha aperto l'ordine e non ci si nasconde dietro
  /// alla media di tutta la schermata.
  String testoAVideo(TarotReading lettura) => [
        VoceDellaStesa.titolo(lettura.spread),
        lettura.consiglio,
        for (final p in lettura.posizioni)
          '${p.drawn.position.label}. ${p.drawn.displayName}. '
              '${p.apertura}, ${p.testo}',
      ].join('\n\n');

  EsitoDellaRipetizione misuraLaStesa({bool soloIlConsiglio = false}) {
    final stese = centoStese();
    final testi = <String>[];
    final composti = <String>[];
    final nomi = <List<String>>[];
    for (final s in stese) {
      final lettura = TarotReading.of(s, argomento, domandaScritta: domanda);
      testi.add(soloIlConsiglio ? lettura.consiglio : testoAVideo(lettura));
      composti.add(lettura.consiglio);
      nomi.add(nomiDi(s));
    }
    return MotoreDellaRipetizione.misura(
      funzione: soloIlConsiglio
          ? 'Stesa di Tarocchi, il solo Consiglio di Medora'
          : 'Stesa di Tarocchi, il testo intero che si legge a schermo',
      testi: testi,
      nomiPerTesto: nomi,
      // **LA MISURA D CONTA SOLO I PARAGRAFI CHE COMPONE L APP.** Vedi
      // MotoreDellaRipetizione.misura: il testo di corpus di una carta uscita
      // due volte DEVE essere lo stesso, e su cento estrazioni da settantotto
      // carte quella ripetizione e matematica.
      testiComposti: composti,
    );
  }

  test('LE CENTO ESTRAZIONI SONO DAVVERO CENTO DIVERSE', () {
    // **PRIMA DI MISURARE IL TESTO SI MISURA L'INGRESSO.** Se le cento stese
    // fossero le stesse carte, questa prova misurerebbe la propria pigrizia e
    // non il compositore.
    final stese = centoStese();
    final firme = <String>{
      for (final s in stese)
        s.cards.map((c) => '${c.card.name}${c.reversed}').join('|'),
    };
    print('ORDINE DF VOCE 02: su ${stese.length} estrazioni le combinazioni '
        'distinte di carte e versi sono ${firme.length}');
    expect(firme.length, MotoreDellaRipetizione.quante,
        reason: 'due delle cento estrazioni hanno dato le stesse tre carte '
            'nello stesso verso: la prova sul testo non direbbe niente');
  });

  test('CENTO CONSULTAZIONI CON LA STESSA DOMANDA, LE QUATTRO MISURE', () {
    // **Il referto del solo Consiglio si stampa comunque**, perche' e' la
    // bolla che ha aperto l'ordine: i suoi numeri stanno nel rapporto accanto
    // a quelli della schermata intera, e nessuno dei due si nasconde.
    print(misuraLaStesa(soloIlConsiglio: true).referto);
    final esito = misuraLaStesa();
    print(esito.refertoLungo);
    expect(esito.passaA, isTrue,
        reason: 'MISURA A: ${esito.testiDistinti} testi distinti su '
            '${esito.quante}. Due letture danno lo stesso identico testo.');
    expect(esito.passaB, isTrue,
        reason: 'MISURA B: ${esito.scheletriDistinti} scheletri distinti su '
            '${esito.quante}, e il piu ripetuto compare '
            '${esito.quanteVolteLoScheletro} volte. Il testo e uno stampo con '
            'i nomi delle carte infilati dentro: la persona lo riconosce alla '
            'seconda lettura.');
    expect(esito.passaC, isTrue,
        reason: 'MISURA C: la coppia peggiore si somiglia al '
            '${(esito.somiglianzaMassima * 100).toStringAsFixed(1)} per cento, '
            'oltre la soglia del '
            '${(MotoreDellaRipetizione.sogliaSomiglianza * 100).toStringAsFixed(0)}.');
    expect(esito.passaD, isTrue,
        reason: 'MISURA D: lo stesso paragrafo compare '
            '${esito.quanteVolteIlParagrafo} volte su ${esito.quante}. '
            'Eccolo: "${esito.paragrafoPiuRipetuto}"');
  });

  test('IL CASO DEL FONDATORE: quattro letture, quanti scheletri', () {
    // **Le quattro stese vere**, ricostruite carta per carta dagli screenshot
    // che il fondatore ha mandato. Non sono estrazioni nuove: sono **le sue**.
    TarotSpread stesaDi(List<(String, bool)> tre) {
      TarotCard carta(String nome) =>
          TarotDeck.cards.firstWhere((c) => c.name == nome);
      return TarotSpread([
        for (var i = 0; i < 3; i++)
          DrawnCard(
            card: carta(tre[i].$1),
            position: SpreadPosition.values[i],
            reversed: tre[i].$2,
          ),
      ]);
    }

    final sue = [
      stesaDi([('Dieci di Denari', true), ('Re di Bastoni', false), ('Il Mondo', false)]),
      stesaDi([('La Temperanza', false), ('Il Mondo', false), ('L\'Appeso', false)]),
      stesaDi([('Il Mago', false), ('La Giustizia', true), ('Il Mondo', false)]),
      stesaDi([('Sette di Denari', false), ('Otto di Spade', false), ('Due di Spade', false)]),
    ];
    final testi = [
      for (final s in sue)
        testoAVideo(TarotReading.of(s, argomento, domandaScritta: domanda)),
    ];
    final esito = MotoreDellaRipetizione.misura(
      funzione: 'Le quattro letture vere del fondatore',
      testi: testi,
      nomiPerTesto: [for (final s in sue) nomiDi(s)],
    );
    print(esito.refertoLungo);
    print('ORDINE DF VOCE 02: sulle QUATTRO letture vere del fondatore gli '
        'scheletri distinti sono ${esito.scheletriDistinti} su 4, il '
        'paragrafo piu ripetuto compare ${esito.quanteVolteIlParagrafo} volte '
        'e la coppia peggiore si somiglia al '
        '${(esito.somiglianzaMassima * 100).toStringAsFixed(1)} per cento');

    // **DIFFERENZA DICHIARATA, sotto la Regola ZERO.** L'ordine DF dice che
    // *"sui quattro responsi veri del fondatore la misura B deve dare 1
    // scheletro su 4"*. Misurato: la B ne dava **quattro su quattro** anche
    // prima della riparazione, perche' la coda dei versi e dei Maggiori
    // cambiava con il conto delle rovesciate. **La misura che coglieva il
    // difetto era la D**, il paragrafo ripetuto: prima quattro volte su
    // quattro, e la C, la somiglianza a coppie, all 84,6 per cento.
    expect(esito.quanteVolteIlParagrafo, lessThanOrEqualTo(1),
        reason: 'nelle quattro letture del fondatore uno stesso paragrafo '
            'compare ancora ${esito.quanteVolteIlParagrafo} volte: e '
            'esattamente quello che ha visto lui');
    expect(esito.somiglianzaMassima,
        lessThan(MotoreDellaRipetizione.sogliaSomiglianza),
        reason: 'due delle quattro letture del fondatore si somigliano ancora '
            'al ${(esito.somiglianzaMassima * 100).toStringAsFixed(1)} per '
            'cento');
  });
}
