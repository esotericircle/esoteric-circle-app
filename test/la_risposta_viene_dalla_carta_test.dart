// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' as campioni;

/// **LA RISPOSTA DI CASA VIENE DALLA CARTA CHIAVE E DALLA DOMANDA.** Ordine GA
/// voce GA.06, 21 ottobre 2026. Il fondatore, 19 ottobre 2026: *"ogni
/// risposta deve essere coerente con i simboli o carte o segni altro da
/// interpretare e coerente con la domanda posta dall'utente"*.
///
/// **I DIFETTI DI SISTEMA che il lettore cieco ha trovato** (`docs/collaudo/
/// GA/lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`), uno per prova:
/// 1. una carta di dolore dentro una frase di esito favorevole: *"Con Nove di
///    Spade le carte [...] indicano una situazione che gira a tuo favore"*;
/// 2. la carta nominata nella risposta non e' la carta chiave ma quella della
///    prima posizione, in 19 stese su 30;
/// 3. su salute, legge e denaro nessun limite e un esito previsto: *"indicano
///    una situazione che gira a tuo favore"* sull'operazione al ginocchio;
/// 4. frasi fisse che tornano identiche sotto carte diverse: *"Su questa
///    questione il tempo lavora dalla tua parte, a patto di cominciare"* sette
///    volte su quaranta.
///
/// **SI MISURA IL RESPONSO VERO**, `TarotReading.of` senza modello, cioe' il
/// responso principale di casa e il ripiego quando il modello non risponde,
/// sulle domande del campione dei lettori ciechi (`campioni.domande`), in
/// tutte e quattro le stese.

/// **LE CARTE DI DOLORE**, dal loro significato documentato (la sintesi del
/// verso in `TarotDeck.cards`, cioe' `docs/corpus/tarocchi.md`), scritte qui
/// per nome e non lette dalla tavola dei toni del compositore: una guardia
/// che leggesse la stessa tavola che sorveglia misurerebbe se stessa.
const Map<String, String> carteDiDolore = {
  'Tre di Spade|dritta': 'Il cuore trafitto',
  'Cinque di Spade|dritta': 'La vittoria amara',
  'Otto di Spade|dritta': 'La prigione dei pensieri',
  'Nove di Spade|dritta': 'L\'angoscia della notte',
  'Dieci di Spade|dritta': 'La fine e la resa',
  'La Torre|dritta': 'Il crollo che rivela',
  'Il Diavolo|dritta': 'L\'ombra da guardare',
  'Cinque di Coppe|dritta': 'Le coppe versate',
  'Cinque di Denari|dritta': 'Il freddo fuori dalla porta',
  'Dieci di Bastoni|dritta': 'Il peso portato',
  'Il Carro|capovolta': 'Le redini allentate',
  'La Temperanza|capovolta': 'La misura perduta',
  'Dieci di Coppe|capovolta': 'La casa divisa',
  'Due di Coppe|capovolta': 'L\'armonia incrinata',
  'Il Mago|capovolta': 'Il potere sprecato',
};

/// Le parole di un esito favorevole dentro la frase del verdetto.
final RegExp _favorevole = RegExp(
    r'(favorevol|a tuo favore|\bfavore\b|risposta è buona|vantaggio|'
    r'fattibile|positiva|compimento|riuscire|una notizia buona)',
    caseSensitive: false);

/// Il verdetto che dice si'.
final RegExp _si = RegExp(r'^(Sì|La risposta delle carte è sì|In generale sì)');

List<String> _frasi(String p) => p
    .split(RegExp(r'(?<=[.!?])\s+'))
    .where((f) => f.trim().isNotEmpty)
    .toList();

/// Le frasi che portano il verdetto: la prima, dopo l'avviso della domanda
/// doppia; e la seguente quando la prima non nomina nessuna carta (la
/// domanda sul modo risponde col gesto e nomina la carta subito dopo).
String _verdetto(String risposta, TarotSpread s) {
  final f = _frasi(risposta);
  final i = f.first.startsWith('Le domande sono due') && f.length > 1 ? 1 : 0;
  final v = f[i];
  if (!s.cards.any((c) => v.contains(c.card.name)) && i + 1 < f.length) {
    return '$v ${f[i + 1]}';
  }
  return v;
}

bool _distacco(String domanda) =>
    RegExp(r'(lasciar|chiuder|trasferir|andare a vivere|andarmene)',
            caseSensitive: false)
        .hasMatch(domanda);

DrawnCard _carta(String nome, SpreadPosition p, bool rovesciata) => DrawnCard(
    card: TarotDeck.cards.firstWhere((c) => c.name == nome),
    position: p,
    reversed: rovesciata);

void main() {
  final domande = [
    for (final d in campioni.domande)
      if (!d.$3.contains('salute') &&
          !d.$3.contains('denaro') &&
          !d.$3.contains('legale'))
        d,
  ];

  test('1. una carta di dolore non sta mai in un verdetto favorevole', () {
    final caso = Random(61);
    final guasti = <String>[];
    var quante = 0;
    for (final MapEntry(key: chiave) in carteDiDolore.entries) {
      final [nome, verso] = chiave.split('|');
      final rovesciata = verso == 'capovolta';
      for (final tipo in TarotSpreadType.values) {
        for (final (domanda, gruppo, _) in domande) {
          // La carta di dolore regge la stesa ed e' la carta chiave: le
          // altre sono Minori, cosi' nessun Maggiore le ruba la chiave.
          final altre = TarotDeck.cards
              .where((c) => c.arcana == TarotArcana.minore && c.name != nome)
              .toList()
            ..shuffle(caso);
          final posti = tipo.posizioni;
          final iCuore = posti.indexWhere((p) => const [
                SpreadPosition.presente,
                SpreadPosition.cartaSola,
                SpreadPosition.consultante,
                SpreadPosition.copre,
              ].contains(p));
          var a = 0;
          final s = TarotSpread([
            for (var i = 0; i < posti.length; i++)
              i == iCuore
                  ? _carta(nome, posti[i], rovesciata)
                  : DrawnCard(
                      card: altre[a++],
                      position: posti[i],
                      reversed: caso.nextDouble() < 0.3),
          ]);
          final r = TarotReading.of(s, TarotTopic.of(gruppo).first,
              domandaScritta: domanda);
          if (r.chiave.drawn.card.name != nome) continue;
          quante++;
          final v = _verdetto(r.principale.risposta, s);
          if (_favorevole.hasMatch(v) ||
              (_si.hasMatch(v) && !_distacco(domanda))) {
            guasti.add('${tipo.name}, $nome $verso, "$domanda": "$v"');
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: verdetti con una carta di dolore come chiave '
        '$quante, letti come esito favorevole ${guasti.length}');
    cardinaleMinimo(quante, carteDiDolore.length * 4 * 20,
        cosa: 'verdetti con una carta di dolore come chiave');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('2. la carta nominata nel verdetto e\' la carta chiave', () {
    final guasti = <String>[];
    var quante = 0;
    var diverse = 0;
    for (final tipo in TarotSpreadType.values) {
      for (var seme = 0; seme < 60; seme++) {
        final s =
            TarotSpread.draw(seed: 6060 + seme, posizioni: tipo.posizioni);
        final (domanda, gruppo, _) = domande[seme % domande.length];
        final r = TarotReading.of(s, TarotTopic.of(gruppo).first,
            domandaScritta: domanda);
        quante++;
        final chiave = r.chiave.drawn;
        if (!identical(chiave, s.cuore)) diverse++;
        final v = _verdetto(r.principale.risposta, s);
        final altra = !v.contains(chiave.displayName) ||
            s.cards.any((c) =>
                !identical(c, chiave) &&
                c.displayName != chiave.displayName &&
                RegExp('(?<![A-Za-zÀ-ÿ])${RegExp.escape(c.displayName)}'
                        r'(?![A-Za-zÀ-ÿ])')
                    .hasMatch(v));
        if (altra) {
          guasti.add('${tipo.name} seme $seme, chiave ${chiave.displayName}: '
              '"$v"');
        }
      }
    }
    print('ORDINE GA VOCE 06: verdetti guardati $quante, con la chiave diversa '
        'dal cuore della stesa $diverse, che nominano una carta che non e\' la '
        'chiave ${guasti.length}');
    cardinaleMinimo(diverse, 40,
        cosa: 'stese con la carta chiave diversa dal cuore',
        perche: 'Se la chiave coincide sempre col cuore, la prova non vede la '
            'carta sbagliata.');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('3. su salute, legge e denaro le carte non decidono e lo dicono', () {
    final sensibili = {
      for (final d in campioni.domande)
        if (d.$3.contains('salute'))
          d: 'medic'
        else if (d.$3.contains('legale'))
          d: 'avvocat|legale'
        else if (d.$3.contains('denaro'))
          d: 'consulent',
    };
    final esito = RegExp(
        r'(favorevol|a tuo favore|\bfavore\b|\bsì\b|riesc|vincer(à|ò|ai)|andrà bene|'
        r'conviene investire|fattibile|positiv)',
        caseSensitive: false);
    final guasti = <String>[];
    var quante = 0;
    for (final MapEntry(key: (domanda, gruppo, _), value: chi)
        in sensibili.entries) {
      for (final tipo in TarotSpreadType.values) {
        for (var seme = 0; seme < 30; seme++) {
          final s =
              TarotSpread.draw(seed: 707 + seme, posizioni: tipo.posizioni);
          final r = TarotReading.of(s, TarotTopic.of(gruppo).first,
              domandaScritta: domanda);
          quante++;
          final prima = _frasi(r.principale.risposta).first;
          if (!prima.toLowerCase().contains('le carte non') ||
              !RegExp(chi).hasMatch(prima.toLowerCase())) {
            guasti.add('"$domanda": la prima frase non dice il limite e chi '
                'decide: "$prima"');
          }
          final tutto = '${r.titolo} ${r.principale.risposta}';
          if (esito.hasMatch(tutto)) {
            guasti.add('"$domanda": un esito previsto, '
                '"${esito.firstMatch(tutto)![0]}" in "$tutto"');
          }
          if (!RegExp(chi).hasMatch(r.principale.cosaFare.toLowerCase())) {
            guasti.add('"$domanda": il cosa fare non rimanda a chi e\' '
                'competente: "${r.principale.cosaFare}"');
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: responsi su salute, legge e denaro $quante, '
        'guasti ${guasti.length}');
    cardinaleMinimo(quante, 3 * 4 * 30, cosa: 'responsi sui temi sensibili');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('4. nessuna frase della risposta torna in piu\' del 5 per cento', () {
    // **La frase fissa si conta col nome delle carte tolto**: *"Con Nove di
    // Spade le carte [...] gira a tuo favore"* e *"Con Cinque di Spade [...]
    // gira a tuo favore"* sono la stessa frase. Fanno eccezione le frasi di
    // servizio, uguali per scelta: il limite sui temi sensibili e gli avvisi
    // della domanda doppia e della vaga, scritte qui alla lettera.
    const diServizio = [
      'Le domande sono due',
      'Le carte non dicono',
      'Nessuna carta sostituisce',
    ];
    final nomi = [
      for (final c in TarotDeck.cards) ...[
        '${c.name} ${c.reversedWord}',
        c.name,
      ],
    ]..sort((a, b) => b.length.compareTo(a.length));
    String senzaNomi(String f) {
      var t = f;
      for (final n in nomi) {
        t = t.replaceAll(n, '§');
      }
      return t;
    }

    final conto = <String, int>{};
    var quante = 0;
    for (final tipo in TarotSpreadType.values) {
      for (var seme = 0; seme < 100; seme++) {
        final s =
            TarotSpread.draw(seed: 5050 + seme, posizioni: tipo.posizioni);
        final (domanda, gruppo, _) =
            campioni.domande[seme % campioni.domande.length];
        final r = TarotReading.of(
            s, TarotTopic.of(gruppo)[seme % TarotTopic.of(gruppo).length],
            domandaScritta: domanda);
        quante++;
        for (final f in {..._frasi(r.principale.risposta).map(senzaNomi)}) {
          if (diServizio.any(f.startsWith)) continue;
          conto[f] = (conto[f] ?? 0) + 1;
        }
      }
    }
    final ordinate = conto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final soglia = (quante * 0.05).floor();
    final troppe = [
      for (final e in ordinate)
        if (e.value > soglia) '${e.value} volte su $quante: "${e.key}"',
    ];
    print('ORDINE GA VOCE 06: responsi $quante, frasi distinte '
        '${conto.length}, la piu\' ripetuta ${ordinate.first.value} volte '
        '(soglia $soglia): "${ordinate.first.key}"');
    cardinaleMinimo(quante, 400, cosa: 'responsi guardati');
    expect(troppe, isEmpty, reason: troppe.take(8).join('\n'));
  });
}
