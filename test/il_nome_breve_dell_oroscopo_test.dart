import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL NOME BREVE DELL'OROSCOPO IN HOME. Ordine BK voce 01.
///
/// **LAPIDE.** Dall'ordine BK all'ordine EN lo scaffale di casa chiamava
/// l'Oroscopo Personalizzato solo "Oroscopo", parole del fondatore: "cosi' il
/// font sara' piu' grande in home". La ragione era misurabile: il titolo della
/// bolla stava in un `FittedBox(scaleDown)` che rimpiccioliva "Oroscopo
/// Personalizzato", e questa prova ne misurava il fattore di scala.
///
/// **Dall'ordine EO voce 02** lo scaffale e' una riga di schede, e il titolo
/// sta sotto la scheda: `ArtEntry.title`, su al massimo due righe, **mai
/// rimpicciolito**. Il difetto che il nome breve curava non esiste piu', e la
/// guardia che lo sorveglia adesso e' `le_schede_dell_arte_test.dart`, che
/// conta su tutta la home i titoli rimpiccioliti e li vuole a zero. Qui resta
/// la sola pretesa che vale ancora: il nome dell'arte, nel catalogo.
void main() {
  test('il catalogo continua a dire "Oroscopo Personalizzato"', () {
    final arte = ArtCatalog.all.firstWhere((a) => a.id == 'horoscope');
    expect(arte.title, 'Oroscopo Personalizzato',
        reason:
            'il nome dell\'arte e\' quello lungo, e dall\'ordine EO voce 02 '
            'e\' anche quello scritto sotto la scheda');
  });
}
