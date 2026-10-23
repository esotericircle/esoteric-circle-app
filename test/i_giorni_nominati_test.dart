import 'package:esoteric_circle/core/astro/i_giorni_nominati.dart';
import 'package:esoteric_circle/services/ai/le_funzioni_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CIELO DEL GIORNO SCRITTO NELLA DOMANDA ARRIVA CON LA DOMANDA.**
/// Ordine EX Aggiunta 4, voce EX.07: al banco della qualita' (giro fine4) le
/// domande sul cielo di un altro giorno costavano una chiamata in piu' per
/// la funzione del cielo. Il giorno si legge dalla domanda e il suo cielo
/// sta nella richiesta.
void main() {
  // Venerdì 2 ottobre 2026.
  final oggi = DateTime(2026, 10, 2, 19, 30);

  test('i giorni che la domanda nomina', () {
    final attesi = <String, List<DateTime>>{
      'Com\'è il cielo domani?': [DateTime(2026, 10, 3)],
      'E dopodomani?': [DateTime(2026, 10, 4)],
      'Com\'era il cielo ieri?': [DateTime(2026, 10, 1)],
      'Il 15 novembre è un buon giorno per firmare un contratto?': [
        DateTime(2026, 11, 15)
      ],
      'In che segno sarà Giove il primo gennaio 2028?': [DateTime(2028, 1, 1)],
      'Che fase aveva la Luna il 20 luglio 1969?': [DateTime(1969, 7, 20)],
      // Senza anno, il prossimo: il 20 luglio detto a ottobre e' del 2027.
      'Che cielo c\'è il 20 luglio?': [DateTime(2027, 7, 20)],
      'Firmo il 15/11/2026?': [DateTime(2026, 11, 15)],
      'Lunedì ho il colloquio: come mi preparo?': [DateTime(2026, 10, 5)],
      'Ci vediamo sabato o domenica?': [
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 4)
      ],
      // Oggi stesso non conta: il suo cielo c'e' gia'.
      'Mi conviene firmare il contratto venerdì?': [],
      'Dov\'è Venere oggi?': [],
      'Il 31 aprile che Luna c\'era?': [],
      'Lui tornerà da me?': [],
    };
    for (final e in attesi.entries) {
      expect(IGiorniNominati.in_(e.key, oggi), e.value, reason: e.key);
    }
    cardinaleMinimo(attesi.length, 14, cosa: 'domande guardate');
  });

  test('il cielo del giorno nominato si calcola e si segna come chiesto', () {
    final prima = LeFunzioniDelCielo.giorniChiesti.length;
    final blocco = LeFunzioniDelCielo.cieloDeiGiorniNominati(
        'Com\'è il cielo domani?',
        adesso: oggi);
    expect(blocco, contains('IL CIELO DEL (2026-10-03)'));
    expect(blocco, contains('non chiamarla'));
    expect(LeFunzioniDelCielo.giorniDa(prima), [DateTime(2026, 10, 3, 12)]);
    expect(
        LeFunzioniDelCielo.cieloDeiGiorniNominati('Lui tornerà da me?',
            adesso: oggi),
        isEmpty);
  });
}
