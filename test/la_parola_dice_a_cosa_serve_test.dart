import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA PAROLA DEL GIORNO DICE A COSA SERVE.** Ordine CQ voci 2.04 e 2.09,
/// 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** la parola del giorno non dice a cosa
/// serve, e la sua domanda non riceve una risposta vera.
///
/// **La causa, e viene da questo stesso ordine.** L'etichetta diceva "Parola
/// del giorno", che e' il nome di una casella: dice dove sei, non cosa te ne
/// fai. Cio' che lo diceva stava in `cosaTiResta` del Dono dell'Alba, e
/// arrivava a schermo dentro le tre righe del rito: **la voce 2.03 le ha tolte
/// da tutti e cinque i Doni**, e senza di loro la parola e' rimasta un titolo
/// senza scopo. E' un difetto che questo ordine ha creato mentre ne curava un
/// altro, e si dichiara.
///
/// **E la sera il giro non si chiudeva.** Il richiamo diceva "Stamattina la
/// tua parola era X." e finiva li': un fatto, non una risposta.
void main() {
  final scheda =
      File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();

  test('l etichetta della parola dice a cosa serve, non che casella e', () {
    // **LA GRANDEZZA E' LA FORMA DELLA FRASE.** Un nome di casella e' un
    // sostantivo con un complemento, "Parola del giorno"; una frase che dice a
    // cosa serve porta un verbo o una preposizione di scopo. Si misura che
    // l'etichetta vecchia non sia tornata e che la nuova nomini il portarsela
    // dietro, che e' il suo scopo dichiarato nel dato.
    expect(scheda.contains("'Parola del giorno'"), isFalse,
        reason: 'l etichetta e tornata a essere il nome di una casella: dice '
            'dove sei, non cosa te ne fai');
    expect(scheda.contains('PORTARTI DIETRO'), isTrue,
        reason: 'l etichetta non dice piu a cosa serve la parola');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.04: la scheda dell Alba nomina il portarsela '
        'dietro ${'PORTARTI DIETRO'.allMatches(scheda).length} volte');
  });

  test('e dice anche dove va a finire, che e la seconda meta', () {
    expect(scheda.contains("Key('alba_dove_va_la_parola')"), isTrue,
        reason: 'la scheda non dice piu dove la parola va a finire: una '
            'parola che non torna da nessuna parte si dimentica prima di sera');
    // **E LA PROMESSA DEVE ESSERE VERA**: la sera il Sigillo del Sogno la
    // richiama davvero, e questa riga lo verifica sul dato invece di
    // fidarsi della frase.
    expect(DailyElement.dawn.cosaTiResta.contains('Sigillo del Sogno'), isTrue,
        reason: 'il Dono dell Alba non promette piu il richiamo della sera, e '
            'allora la riga della scheda promette una cosa che non succede');
  });

  test('la sera il richiamo chiude il giro invece di aprirlo', () {
    final riga = FiloDelGiorno.richiamoDellaParola('Adesso');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.09: il richiamo della sera dice "$riga"');
    cardinaleMinimo(riga.length, 40,
        cosa: 'caratteri del richiamo della sera',
        perche: 'Una riga di quattro parole non puo dire che cosa e successo '
            'alla parola, e la prova sarebbe verde su una frase che non dice '
            'niente.');
    expect(riga.contains('Adesso'), isTrue,
        reason: 'il richiamo non nomina piu la parola del mattino');
    expect(riga.contains('chiude'), isTrue,
        reason: 'il richiamo dice solo che parola era, e non che cosa ne e '
            'stato: e un fatto, non una risposta');
    // **E NON PROMETTE NIENTE**, che e' la legge dei testi di questa app.
    for (final promessa in const ['sara', 'porterà', 'otterrai', 'vedrai']) {
      expect(riga.toLowerCase().contains(promessa), isFalse,
          reason: 'il richiamo promette un esito con "$promessa"');
    }
  });
}
