import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'interpretazione a sette strati della Stesa a Tre Carte, dalle regole di
/// `docs/corpus/stesa_interpretazione.md`. Tutto deterministico e cacheabile:
/// a parita' di carte e di argomento il testo e' sempre lo stesso.
void main() {
  DrawnCard di(String nome, SpreadPosition pos, {bool reversed = false}) =>
      DrawnCard(
        card: TarotDeck.cards.firstWhere((c) => c.name == nome),
        position: pos,
        reversed: reversed,
      );

  TarotSpread stesa(String a, String b, String c,
          {List<bool> versi = const [false, false, false]}) =>
      TarotSpread([
        di(a, SpreadPosition.passato, reversed: versi[0]),
        di(b, SpreadPosition.presente, reversed: versi[1]),
        di(c, SpreadPosition.futuro, reversed: versi[2]),
      ]);

  group('Catalogo dal corpus', () {
    test('Le 78 carte hanno il testo ricco nei due versi', () {
      expect(TarotDeck.cards.length, 78);
      for (final c in TarotDeck.cards) {
        for (final coppia in [
          [c.upright, 'dritto'],
          [c.reversed, 'rovescio'],
        ]) {
          final testo = coppia[0];
          // Testo ricco vuol dire piu' di una frase: due o tre, non una riga.
          expect(testo.length, greaterThan(120),
              reason: '${c.name} ${coppia[1]} e troppo corto');
          expect('.'.allMatches(testo).length, greaterThanOrEqualTo(2),
              reason: '${c.name} ${coppia[1]} ha una frase sola');
        }
        expect(c.uprightSummary.length, lessThan(60));
        expect(c.reversedSummary.length, lessThan(60));
      }
    });

    test('La legatura all\'arte segue il nome, non il numero', () {
      final forza = TarotDeck.cards.firstWhere((c) => c.name == 'La Forza');
      final giustizia =
          TarotDeck.cards.firstWhere((c) => c.name == 'La Giustizia');
      // Nei file d'arte l'ordine e' Rider-Waite: Forza 08, Giustizia 11.
      expect(forza.stem, 'tar_rw_08_la-forza_v1');
      expect(giustizia.stem, 'tar_rw_11_la-giustizia_v1');
      // Il Papa sta nel file che si chiama ierofante.
      final papa = TarotDeck.cards.firstWhere((c) => c.name == 'Il Papa');
      expect(papa.stem, 'tar_rw_05_l-ierofante_v1');
    });
  });

  group('Scegli argomento', () {
    test('Sedici voci in tre gruppi', () {
      expect(TarotTopic.values.length, 16);
      expect(TarotTopic.of(TarotTopicGroup.amore).length, 6);
      expect(TarotTopic.of(TarotTopicGroup.lavoro).length, 4);
      expect(TarotTopic.of(TarotTopicGroup.vita).length, 6);
    });

    test('Salute e legale non esistono proprio', () {
      // Per etica quelle letture non si fanno: non sono voci bloccate, non ci
      // sono affatto.
      const vietate = [
        'salute', 'medic', 'malatt', 'guarig', 'diagnos', 'legale', //
        'avvocat', 'causa', 'processo', 'tribunal', 'morir', 'morte',
      ];
      for (final t in TarotTopic.values) {
        final l = t.label.toLowerCase();
        for (final v in vietate) {
          expect(l.contains(v), isFalse,
              reason: 'l\'argomento "${t.label}" tocca un tema escluso');
        }
      }
    });

    test('Ogni gruppo ha il suo consiglio, azionabile', () {
      for (final g in TarotTopicGroup.values) {
        expect(g.consiglio.length, greaterThan(80));
        expect(g.consiglio, isNot(contains('sicuramente')));
      }
      expect(TarotTopicGroup.values.map((g) => g.consiglio).toSet().length, 3);
    });
  });

  // IL GRUPPO "LE CARTE CHE DIALOGANO" NON ESISTE PIU', ordine P voce 08.
  //
  // Erano cinque prove sulle nove regole di priorita' di quella riga. La bolla
  // e' stata eliminata e con lei la generazione: prove su un codice che non
  // c'e' piu' non si aggiornano, si togliono. Cio' che di quel testo era vero,
  // i Maggiori e i versi, e' entrato nel consiglio ed e' sorvegliato da
  // `test/la_stesa_si_capisce_test.dart`.

  group('La carta chiave', () {
    test('Di default e il Presente', () {
      final s = stesa('Asso di Spade', 'La Morte', 'Due di Coppe');
      expect(TarotReading.chiaveDi(s).drawn.card.name, 'La Morte');
    });

    test('Col Presente Minore passa al Maggiore piu alto', () {
      final s = stesa('Il Matto', 'Due di Coppe', 'Il Mondo');
      final chiave = TarotReading.chiaveDi(s);
      // Il Mondo e' XXI, Il Matto e' 0.
      expect(chiave.drawn.card.name, 'Il Mondo');
      expect(chiave.perche, contains('più alto'));
    });

    test('Senza Maggiori resta il Presente', () {
      final s = stesa('Asso di Spade', 'Due di Coppe', 'Tre di Bastoni');
      expect(TarotReading.chiaveDi(s).drawn.card.name, 'Due di Coppe');
    });
  });

  group('La lettura intera', () {
    test('Ha tutti e sette gli strati', () {
      final s = TarotSpread.draw(seed: 7);
      final r = TarotReading.of(s, TarotTopic.carriera);
      expect(r.sintesi, s.presente.summary);
      expect(r.posizioni.length, 3);
      for (final p in r.posizioni) {
        expect(p.apertura, isNotEmpty);
        expect(p.testo, p.drawn.meaning);
      }
      expect(r.chiave.perche, isNotEmpty);
      // IL CONSIGLIO NON E' PIU' IL SOLO MODELLO DEL GRUPPO, voce 09: lo
      // contiene, ma poggia sulle tre carte e le nomina.
      expect(r.consiglio, contains(TarotTopicGroup.lavoro.consiglio));
      expect(r.consiglio, contains(s.presente.card.name));
      expect(TarotReading.domande, contains(r.domanda));
    });

    test('Il consiglio parte dalla lente e finisce con la domanda', () {
      // ORDINE P VOCE 09: il consiglio non e' piu' il solo modello del gruppo.
      // Lo CONTIENE, e poi poggia sulle tre carte nominandole, e finisce con la
      // domanda dopo una riga di stacco.
      //
      // **QUESTA RIGA E' STATA RISCRITTA DALLA VOCE S.26 DELL'ORDINE S.** Diceva
      // che il consiglio COMINCIA col modello del gruppo, ed era vero: il gruppo
      // porta l'AZIONE, e la bolla apriva con l'azione. L'anatomia della voce S.16
      // dice che prima viene la RISPOSTA, e l'allegato C ha portato le tre risposte
      // che mancavano. Adesso la bolla apre con la lente dell'argomento e la
      // risposta del gruppo, e l'azione viene dopo: la riga non e' stata tolta ma
      // cambiata di grandezza, e l'ordine delle due parti lo presidia
      // `il_consiglio_dei_tarocchi_e_la_sua_anatomia_test`.
      final s = TarotSpread.draw(seed: 3);
      for (final t in TarotTopic.values) {
        final r = TarotReading.of(s, t);
        expect(r.consiglio, startsWith('${t.lente}, ${t.group.risposta}'));
        expect(r.consiglio, contains(t.group.consiglio));
        expect(r.consiglio.split('\n\n').last.trim(), r.domanda);
      }
    });

    test('E deterministica a parita di carte, argomento e seme', () {
      for (final seme in [0, 1, 2, 42, 300]) {
        for (final t in [TarotTopic.amoreQuadro, TarotTopic.denaro]) {
          final a = TarotReading.of(TarotSpread.draw(seed: seme), t);
          final b = TarotReading.of(TarotSpread.draw(seed: seme), t);
          expect(a.sintesi, b.sintesi);
          expect(a.chiave.drawn.card.stem, b.chiave.drawn.card.stem);
          expect(a.consiglio, b.consiglio);
          expect(a.domanda, b.domanda);
        }
      }
    });

    test('La lente dell\'argomento entra in ogni posizione', () {
      final s = TarotSpread.draw(seed: 11);
      final r = TarotReading.of(s, TarotTopic.famiglia);
      for (final p in r.posizioni) {
        expect(p.apertura, startsWith(TarotTopic.famiglia.lente));
      }
    });
  });
}
