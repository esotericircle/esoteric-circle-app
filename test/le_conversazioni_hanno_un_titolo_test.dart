import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/le_conversazioni_passate.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE CONVERSAZIONI HANNO UN TITOLO, E IL MENU' NE MOSTRA CINQUE.** Ordine
/// DZ voci 03 e 04: le regole pure, senza chat e senza modello.
void main() {
  ChatMessage m(String conv, String testo, int minuto,
          {bool persona = true}) =>
      ChatMessage(
        role: persona ? ChatRole.user : ChatRole.maestro,
        text: testo,
        at: DateTime(2026, 9, 18, 10, minuto),
        conversazione: conv,
      );

  test('le ultime cinque, dalla piu\' recente, senza quella aperta', () {
    final messaggi = [
      for (var i = 0; i < 7; i++) ...[
        m('c$i', 'Domanda $i', i * 2),
        m('c$i', 'Risposta $i', i * 2 + 1, persona: false),
      ],
    ];
    final passate = LeConversazioniPassate.raccogli(messaggi,
        titoli: const {'c5': 'Il titolo scritto'}, corrente: 'c6');
    expect([for (final c in passate) c.id], ['c5', 'c4', 'c3', 'c2', 'c1'],
        reason: 'cinque, dalla piu\' recente, e la aperta non c\'e\'');
    expect(passate.first.titolo, 'Il titolo scritto');
    expect(passate[1].titolo, 'Domanda 4',
        reason: 'senza titolo scritto vale la prima domanda');
  });

  test('una conversazione senza domande non si mostra', () {
    final passate = LeConversazioniPassate.raccogli(
        [m('c1', 'Solo il saluto del Maestro', 0, persona: false)],
        titoli: const {},
        corrente: null);
    expect(passate, isEmpty);
  });

  test('il titolo di ripiego tiene sei parole e i puntini', () {
    expect(
        LeConversazioniPassate.titoloDiRipiego(
            'Quale energia porto nelle relazioni questa settimana?'),
        'Quale energia porto nelle relazioni questa…');
    expect(LeConversazioniPassate.titoloDiRipiego('Il mio lavoro?'),
        'Il mio lavoro?');
  });

  test('il titolo del modello si ripulisce', () {
    expect(LeConversazioniPassate.pulisci('"Il lavoro e la luna."'),
        'Il lavoro e la luna');
    expect(LeConversazioniPassate.pulisci('«Amore»\nseconda riga'), 'Amore');
    expect(LeConversazioniPassate.pulisci('   '), isNull);
    expect(LeConversazioniPassate.pulisci(null), isNull);
  });

  test('il giorno si dice oggi, ieri, o con la data', () {
    final adesso = DateTime(2026, 9, 18, 22);
    expect(LeConversazioniPassate.quando(DateTime(2026, 9, 18, 8), adesso),
        'Oggi');
    expect(LeConversazioniPassate.quando(DateTime(2026, 9, 17, 23), adesso),
        'Ieri');
    expect(LeConversazioniPassate.quando(DateTime(2026, 9, 2), adesso),
        '2 settembre');
  });
}
