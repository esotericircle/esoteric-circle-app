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

  group('Le carte che dialogano', () {
    test('Tre Maggiori, un momento cardine', () {
      final d =
          TarotReading.dialogoDi(stesa('Il Matto', 'La Morte', 'Il Mondo'));
      expect(d.rule, DialogoRule.treMaggiori);
    });

    test('Due Maggiori, un tema del destino', () {
      final d = TarotReading.dialogoDi(
          stesa('Il Matto', 'La Morte', 'Asso di Coppe'));
      expect(d.rule, DialogoRule.dueMaggiori);
    });

    test('I Maggiori hanno la precedenza sulle altre regole', () {
      // Qui varrebbe anche la regola delle rovesciate, ma i Maggiori vincono.
      final d = TarotReading.dialogoDi(stesa(
          'Il Matto', 'La Morte', 'Asso di Coppe',
          versi: [true, true, false]));
      expect(d.rule, DialogoRule.dueMaggiori,
          reason: 'una regola minore ha superato i Maggiori');
    });

    test('Tre carte dello stesso seme, un filo unico', () {
      final d = TarotReading.dialogoDi(
          stesa('Asso di Spade', 'Tre di Spade', 'Re di Spade'));
      expect(d.rule, DialogoRule.stessoSeme);
      expect(d.text, contains('aria'));
    });

    test('Spade con Coppe, mente e cuore', () {
      final d = TarotReading.dialogoDi(
          stesa('Asso di Spade', 'Due di Coppe', 'Tre di Bastoni'));
      expect(d.rule, DialogoRule.spadeCoppe);
    });
  });

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
      expect(r.dialogo.text, isNotEmpty);
      expect(r.chiave.perche, isNotEmpty);
      expect(r.consiglio, TarotTopicGroup.lavoro.consiglio);
      expect(TarotReading.domande, contains(r.domanda));
    });

    test('Il consiglio segue il gruppo dell\'argomento', () {
      final s = TarotSpread.draw(seed: 3);
      for (final t in TarotTopic.values) {
        expect(TarotReading.of(s, t).consiglio, t.group.consiglio);
      }
    });

    test('E deterministica a parita di carte, argomento e seme', () {
      for (final seme in [0, 1, 2, 42, 300]) {
        for (final t in [TarotTopic.amoreQuadro, TarotTopic.denaro]) {
          final a = TarotReading.of(TarotSpread.draw(seed: seme), t);
          final b = TarotReading.of(TarotSpread.draw(seed: seme), t);
          expect(a.sintesi, b.sintesi);
          expect(a.dialogo.text, b.dialogo.text);
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
