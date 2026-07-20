import 'dart:io';

import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'accordo della parola del rovescio, verificato contro il corpus.
///
/// "La Papessa rovesciato" e' un errore che si legge subito. Il corpus
/// `docs/corpus/tarocchi.md` scrive gia' l'accordo giusto nelle intestazioni
/// rovesciate: qui si controlla che il catalogo dica la stessa parola, carta
/// per carta, su tutte e settantotto.
void main() {
  /// La parola del rovescio di ogni carta, letta dalle intestazioni del corpus.
  Map<String, String> paroleDalCorpus() {
    final testo = File('docs/corpus/tarocchi.md').readAsStringSync();
    final rovescio = RegExp(r'\s+(rovesciat[oaie])$');
    final numerale = RegExp(r'^(?:0|[IVXL]+)\s+');
    final parole = <String, String>{};
    for (final riga in testo.split('\n')) {
      if (!riga.startsWith('- ') || !riga.contains(' · ')) continue;
      final etichetta = riga.substring(2).split(' · ').first.trim();
      final m = rovescio.firstMatch(etichetta);
      if (m == null) continue;
      final nome =
          etichetta.replaceAll(rovescio, '').replaceAll(numerale, '').trim();
      parole[nome] = m.group(1)!;
    }
    return parole;
  }

  test('Il corpus copre tutte e settantotto le carte', () {
    final parole = paroleDalCorpus();
    expect(parole.length, 78,
        reason: 'il corpus non ha un rovescio per ogni carta');
  });

  test('La parola del catalogo coincide con quella del corpus', () {
    final parole = paroleDalCorpus();
    for (final card in TarotDeck.cards) {
      final attesa = parole[card.name];
      expect(attesa, isNotNull,
          reason: '${card.name} non si trova nel corpus');
      expect(card.reversedWord, attesa,
          reason: 'il corpus scrive "${card.name} $attesa", il catalogo dice '
              '"${card.name} ${card.reversedWord}"');
    }
  });

  test('Le femminili e il plurale sono quelli attesi, e solo quelli', () {
    const femminili = {
      'La Papessa', 'L\'Imperatrice', 'La Giustizia', 'La Ruota della Fortuna',
      'La Forza', 'La Morte', 'La Temperanza', 'La Torre', 'La Stella',
      'La Luna', 'Regina di Bastoni', 'Regina di Coppe', 'Regina di Denari',
      'Regina di Spade',
    };
    for (final card in TarotDeck.cards) {
      if (card.name == 'Gli Amanti') {
        expect(card.reversedAgreement, ReversedAgreement.maschilePlurale);
        expect(card.reversedWord, 'rovesciati');
      } else if (femminili.contains(card.name)) {
        expect(card.reversedAgreement, ReversedAgreement.femminile,
            reason: '${card.name} dovrebbe essere femminile');
        expect(card.reversedWord, 'rovesciata');
      } else {
        expect(card.reversedAgreement, ReversedAgreement.maschile,
            reason: '${card.name} non dovrebbe essere accordata');
        expect(card.reversedWord, 'rovesciato');
      }
    }
    // Il conto torna: quattordici femminili, una plurale, il resto maschili.
    expect(
        TarotDeck.cards
            .where((c) => c.reversedAgreement == ReversedAgreement.femminile)
            .length,
        14);
    expect(
        TarotDeck.cards
            .where((c) =>
                c.reversedAgreement == ReversedAgreement.maschilePlurale)
            .length,
        1);
  });

  test('Il nome col verso passa sempre dalla parola accordata', () {
    for (final card in TarotDeck.cards) {
      final rovesciata = DrawnCard(
          card: card, position: SpreadPosition.presente, reversed: true);
      final dritta = DrawnCard(
          card: card, position: SpreadPosition.presente, reversed: false);
      expect(rovesciata.displayName, '${card.name} ${card.reversedWord}');
      expect(rovesciata.versoLabel, card.reversedWord);
      // Sulla carta dritta non compare nessuna parola di verso.
      expect(dritta.displayName, card.name);
      expect(dritta.versoLabel, isEmpty);
    }
  });

  test('Nessuna schermata dei tarocchi scrive la parola a mano', () {
    // Se qualcuno reintroducesse il maschile fisso in una schermata, il
    // controllo cadrebbe qui invece che sotto gli occhi di chi legge. Si
    // guardano i soli file dei tarocchi, saltando il catalogo che e' la
    // sorgente, e si ignorano i commenti: la parola nel commento che spiega
    // la regola e' legittima.
    final colpevoli = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart')) continue;
      if (!path.contains('/tarot')) continue;
      if (path.endsWith('tarot_card.dart')) continue;

      var riga = 0;
      for (final linea in f.readAsLinesSync()) {
        riga++;
        final codice = linea.trim();
        if (codice.startsWith('//')) continue;
        // La parola dentro una stringa letterale, non in un commento a fine
        // riga: si taglia via tutto quello che segue una doppia barra.
        final senzaCommento = codice.split('//').first;
        // Solo le tre parole del verso. "Includi carte rovesciate" e'
        // l'etichetta di un interruttore, non l'accordo di una carta.
        if (RegExp("'[^']*rovesciat[oai](?![a-z])").hasMatch(senzaCommento)) {
          colpevoli.add('$path:$riga');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'la parola del rovescio va presa da TarotCard.reversedWord, '
            'non scritta a mano in ${colpevoli.join(", ")}');
  });
}
