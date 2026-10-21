// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' as campioni;
import 'la_carta_nella_risposta_test.dart' as carta;

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
final RegExp _si = RegExp(
    r'^(Sì|La risposta delle carte è sì|In generale sì|Le carte inclinano al sì|'
    r'Può andare)');

List<String> _frasi(String p) => p
    .split(RegExp(r'(?<=[.!?])\s+'))
    .where((f) => f.trim().isNotEmpty)
    .toList();

/// Le frasi che portano il verdetto: la prima, dopo l'avviso della domanda
/// doppia; e la seguente quando la prima non nomina nessuna carta (la
/// domanda sul modo risponde col gesto e nomina la carta subito dopo).
String _verdetto(String risposta, TarotSpread s) {
  final f = _frasi(risposta);
  final i = f.first.startsWith('Le carte rispondono alla prima') && f.length > 1
      ? 1
      : 0;
  final v = f[i];
  if (!s.cards
          .any((c) => v.toLowerCase().contains(c.card.name.toLowerCase())) &&
      i + 1 < f.length) {
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
          // La carta di dolore sta dove la domanda prende la risposta
          // (ordine GA voce GA.06: l'esito per un si' o un no, il cuore per
          // il modo), ed e' la carta chiave: le altre sono Minori, cosi'
          // nessun Maggiore le ruba la chiave.
          final altre = TarotDeck.cards
              .where((c) => c.arcana == TarotArcana.minore && c.name != nome)
              .toList()
            ..shuffle(caso);
          final posti = tipo.posizioni;
          var a = 0;
          final prova = TarotSpread([
            for (var i = 0; i < posti.length; i++)
              DrawnCard(
                  card: altre[a++],
                  position: posti[i],
                  reversed: caso.nextDouble() < 0.3),
          ]);
          final iChiave = prova.cards.indexOf(
              TarotReading.chiaveDi(prova, domandaScritta: domanda).drawn);
          final s = TarotSpread([
            for (var i = 0; i < posti.length; i++)
              i == iChiave
                  ? _carta(nome, posti[i], rovesciata)
                  : prova.cards[i],
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
        // Dentro la frase i Maggiori hanno l'articolo in minuscolo (*"la
        // Torre"*): il nome si cerca senza badare alle maiuscole.
        final altra =
            !v.toLowerCase().contains(chiave.displayName.toLowerCase()) ||
                s.cards.any((c) =>
                    !identical(c, chiave) &&
                    c.displayName != chiave.displayName &&
                    RegExp(
                            '(?<![A-Za-zÀ-ÿ])${RegExp.escape(c.displayName)}'
                            r'(?![A-Za-zÀ-ÿ])',
                            caseSensitive: false)
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
      'Le carte rispondono alla prima',
      'Le carte aiutano',
      'Le carte possono aiutarti',
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

  // --- I DIFETTI DEL LETTORE CIECO INDIPENDENTE, 21 ottobre 2026 ---
  //
  // Dopo la prima cura (commit 9b2d2d29) il lettore cieco indipendente ha
  // riletto i quaranta responsi e ha dato 34, 28 e 15 su 40. Le prove qui
  // sotto sorvegliano i difetti di sistema che ha trovato.

  /// I responsi veri sulle domande del campione, in tutte le stese.
  List<(String, TarotSpread, TarotReading)> responsi(int quanti, int seme0) => [
        for (final tipo in TarotSpreadType.values)
          for (var seme = 0; seme < quanti; seme++)
            () {
              final s = TarotSpread.draw(
                  seed: seme0 + seme, posizioni: tipo.posizioni);
              final (domanda, gruppo, _) =
                  campioni.domande[seme % campioni.domande.length];
              return (
                domanda,
                s,
                TarotReading.of(s, TarotTopic.of(gruppo).first,
                    domandaScritta: domanda)
              );
            }(),
      ];

  test('5. la carta chiave sta dove si legge l\'adesso o l\'esito', () {
    // *"L'Eremita dice che e' tempo di ritiro"*, con L'Eremita nel Passato
    // (tarocchi-2): il Maggiore piu' alto diventava la chiave in qualunque
    // posizione, e la risposta lo leggeva al presente. E a un si' o un no
    // risponde l'esito: *"si', la tendenza e' favorevole"* col Due di Coppe
    // rovesciato nel Futuro (tarocchi-12).
    final guasti = <String>[];
    var quante = 0;
    var dallEsito = 0;
    for (final (domanda, s, r) in responsi(60, 9090)) {
      quante++;
      final chiave = r.chiave.drawn;
      final ruolo = VoceDellaStesa.ruoloDi(chiave.position);
      if (ruolo != RuoloDellaPosizione.ora &&
          ruolo != RuoloDellaPosizione.esito) {
        guasti.add('"$domanda": la chiave ${chiave.displayName} sta in '
            '${chiave.position.name}');
      }
      final d = LaDomandaLetta.di(domanda);
      if (d.forma == FormaDellaDomanda.siNo && s.approdo != null) {
        dallEsito++;
        if (!identical(chiave, s.approdo)) {
          guasti.add('"$domanda": a un si\' o no risponde '
              '${chiave.displayName} e non l\'esito '
              '${s.approdo!.displayName}');
        }
      }
    }
    print('ORDINE GA VOCE 06: chiavi guardate $quante, risposte dall\'esito '
        '$dallEsito, guasti ${guasti.length}');
    cardinaleMinimo(dallEsito, 60, cosa: 'domande si\' o no con un esito');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('6. nessuna formula cucita nella risposta e nel cosa fare', () {
    // Le formule che il lettore cieco indipendente ha contato: *"aggiunge un
    // gesto"* 27 volte su 40, *"cioe'"* 24, *"la tendenza e' favorevole"*
    // 10, *"Al centro c'e'"* 5, *"da questo dipende la risposta"* 4, *"e'
    // li' che la cosa puo' arrivare"* 4, *"un rischio da guardare adesso,
    // non una meta"* 4, *"Lo conferma"* e *"Lo attenua"* 4.
    final formule = RegExp(
        r"(aggiunge(?:ono)? un gesto|cioè|tendenza|Al centro c'è|"
        r"da questo dipende la risposta|è questo che decide la risposta|"
        r"è lì che la cosa può arrivare|un rischio da guardare|"
        r"un esito che chiede ancora un impegno|Lo conferma|Lo attenua|"
        r"Lo contrasta|Per sostenere questa|Il suo consiglio è chiaro)",
        caseSensitive: false);
    final guasti = <String>[];
    var quante = 0;
    for (final (domanda, _, r) in responsi(40, 7171)) {
      quante++;
      final testo = '${r.principale.risposta} ${r.principale.cosaFare}';
      final m = formule.firstMatch(testo);
      if (m != null) guasti.add('"$domanda": "${m[0]}" in "$testo"');
    }
    print('ORDINE GA VOCE 06: responsi $quante, con una formula cucita '
        '${guasti.length}');
    cardinaleMinimo(quante, 160, cosa: 'responsi guardati');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test(
      '7. il cosa fare non da\' per scontata una persona che la domanda '
      'non nomina', () {
    // *"Proponi una sera senza telefoni, solo voi due"* a una coppia a
    // distanza (tarocchi-37), *"Mantieni una promessa fatta al partner"* a
    // chi parla di un ex, *"Non partecipare alle chiacchiere sui colleghi"*
    // a chi apre un'attivita' sua.
    final guasti = <String>[];
    var quante = 0;
    for (final (domanda, _, r) in responsi(40, 8282)) {
      quante++;
      final nomina = domanda.toLowerCase();
      for (final m in carta.presupposti.allMatches(r.principale.cosaFare)) {
        final chi = m[1]!.toLowerCase();
        final radice = chi.length > 3 ? chi.substring(0, chi.length - 1) : chi;
        if (nomina.contains(radice)) continue;
        guasti.add('"$domanda": "$chi" in "${r.principale.cosaFare}"');
      }
    }
    print('ORDINE GA VOCE 06: cosa fare guardati $quante, con una persona '
        'data per scontata ${guasti.length}');
    cardinaleMinimo(quante, 160, cosa: 'cosa fare guardati');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('8. una carta di tono contrario al centro o all\'esito non si tace', () {
    // *"Nove di Spade (presente, angoscia) taciuto"* (tarocchi-2), *"la
    // carta della rottura e' taciuta"* (tarocchi-12): il verdetto puo'
    // poggiare su una carta, ma quella che dice il contrario al centro o in
    // fondo alla stesa si nomina.
    final guasti = <String>[];
    var contrarie = 0;
    for (final (domanda, s, r) in responsi(60, 6363)) {
      if (LaDomandaLetta.di(domanda).sensibile != null) continue;
      final tono = LaCartaNellaRisposta.di(r.chiave.drawn).tono;
      for (final c in [s.cuore, s.approdo]) {
        if (c == null || identical(c, r.chiave.drawn)) continue;
        final t = LaCartaNellaRisposta.di(c).tono;
        final contraria = (tono == TonoDellaCarta.favorevole &&
                t == TonoDellaCarta.sfavorevole) ||
            (tono == TonoDellaCarta.sfavorevole &&
                t == TonoDellaCarta.favorevole);
        if (!contraria) continue;
        contrarie++;
        if (!r.principale.risposta
            .toLowerCase()
            .contains(c.displayName.toLowerCase())) {
          guasti.add('"$domanda": ${c.displayName} (${c.position.name}) '
              'taciuta: "${r.principale.risposta}"');
        }
      }
    }
    print('ORDINE GA VOCE 06: carte contrarie al centro o all\'esito '
        '$contrarie, taciute ${guasti.length}');
    cardinaleMinimo(contrarie, 40,
        cosa: 'carte contrarie al centro o all\'esito');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('9. la domanda doppia dice qual e\' la prima', () {
    // *"doppie (3, 34, 38) con la formula corretta, mai detto quale sia la
    // prima"*.
    final doppie = [
      for (final d in campioni.domande)
        if (LaDomandaLetta.di(d.$1).doppia) d,
    ];
    final guasti = <String>[];
    var quante = 0;
    for (final tipo in TarotSpreadType.values) {
      for (final (domanda, gruppo, _) in doppie) {
        final s = TarotSpread.draw(seed: 99, posizioni: tipo.posizioni);
        final r = TarotReading.of(s, TarotTopic.of(gruppo).first,
            domandaScritta: domanda);
        quante++;
        final prima = LaDomandaLetta.di(domanda).primaParte;
        if (prima == null || !r.principale.risposta.contains(prima)) {
          guasti.add('"$domanda": "${r.principale.risposta}"');
        }
      }
    }
    cardinaleMinimo(quante, 8, cosa: 'domande doppie guardate');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });
}
