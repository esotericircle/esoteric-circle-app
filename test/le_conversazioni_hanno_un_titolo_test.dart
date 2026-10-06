import 'package:esoteric_circle/core/chat/le_conversazioni_passate.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE CONVERSAZIONI HANNO UN TITOLO, E IL MENU' NE MOSTRA CINQUE.** Ordine
/// DZ voci 03 e 04: le regole pure, senza chat e senza modello.
///
/// **LAPIDE, ordine FE voci 22.14 e 22.16.** Qui stavano tre prove della
/// raccolta dai messaggi (le ultime cinque, la conversazione senza domande,
/// il titolo del modello ripulito). Dall'ordine FE l'elenco viene dal
/// Diario Cosmico e il titolo e' quello del Diario: le sorvegliano
/// `chat_initial_message_test` e `la_porta_delle_conversazioni_e_una_test`.
void main() {
  test('il titolo di ripiego tiene sei parole e i puntini', () {
    expect(
        LeConversazioniPassate.titoloDiRipiego(
            'Quale energia porto nelle relazioni questa settimana?'),
        'Quale energia porto nelle relazioni questa…');
    expect(LeConversazioniPassate.titoloDiRipiego('Il mio lavoro?'),
        'Il mio lavoro?');
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
