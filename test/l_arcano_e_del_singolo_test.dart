import 'dart:math';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/diario_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ARCANO E' DEL SINGOLO, NON DI UN VENTIDUESIMO DEL MONDO.**
/// Ordine CQ voce 2.05, 3 settembre 2026, riscritta dall'ordine DT.
///
/// **Il fatto, parole del fondatore:** l'Arcano del Giorno non era
/// individuale: due persone con la stessa carta natale vedevano la stessa carta
/// tutti i giorni.
///
/// **Dall'ordine DT l'Arcano del Giorno non c'e' piu'**, e l'Arcano dell'Alba e'
/// del singolo per costruzione: ogni persona ha il suo sacchetto e lo consuma
/// col suo caso. **La grandezza resta quella giusta, la correlazione fra due
/// persone**: quanti giorni su un anno vedono lo stesso stato. Il caso
/// indipendente ne da' in media uno ogni quarantaquattro.
///
/// **La Runa del Tramonto si misura col metro di sempre.**
void main() {
  // Un anno di giorni, per misurare su un campione che non sia un caso.
  final anno = [
    for (var i = 0; i < 365; i++) DateTime(2026, 1, 1).add(Duration(days: i)),
  ];

  test('due persone non vedono lo stesso Arcano dell\'Alba', () {
    var uguali = 0;
    var a = DiarioDellAlba.nuovo(seme: 'persona-a');
    var b = DiarioDellAlba.nuovo(seme: 'persona-b');
    final casoA = Random(11), casoB = Random(29);
    for (final giorno in anno) {
      final ea = a.estrai(utente: a.seme, giorno: giorno, caso: casoA);
      final eb = b.estrai(utente: b.seme, giorno: giorno, caso: casoB);
      a = ea.dopo;
      b = eb.dopo;
      if (ea.responso.stato == eb.responso.stato) uguali++;
    }
    // ignore: avoid_print
    print('ORDINE DT: due persone vedono lo stesso stato $uguali giorni su '
        '365, attesi circa ${(365 / 44).toStringAsFixed(1)}');
    expect(uguali, lessThan(30),
        reason: 'due persone vedono lo stesso stato $uguali giorni su 365: '
            'l\'Arcano dell\'Alba non e del singolo');
  });

  test('la Runa del Tramonto e gia del singolo, e si misura uguale', () {
    // **LA VOCE 2.06 DICEVA "STESSO DIFETTO", E LA MISURA DICE DI NO.**
    // Il Tramonto compone la sua chiave con la nascita INTERA, ora e minuti
    // compresi, e non con un numero ridotto. Si misura con lo stesso metro
    // dell'Arcano, cosi' l'affermazione non resta un'opinione.
    final primaNascita = DateTime(1980, 3, 14, 9, 30);
    final altraNascita = DateTime(1993, 11, 2, 21, 5);
    final unaIdentita = SunsetRune.identitaPer(
        nascita: primaNascita, oraNota: true, deviceId: 'a');
    final altraIdentita = SunsetRune.identitaPer(
        nascita: altraNascita, oraNota: true, deviceId: 'a');
    var uguali = 0;
    for (final giorno in anno) {
      final una = SunsetRune.estrai(giorno.add(const Duration(hours: 20)),
          dataNascita: primaNascita, identita: unaIdentita);
      final altra = SunsetRune.estrai(giorno.add(const Duration(hours: 20)),
          dataNascita: altraNascita, identita: altraIdentita);
      if (una.rune.name == altra.rune.name && una.verso == altra.verso) {
        uguali++;
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.06: due nascite diverse vedono la stessa runa '
        '$uguali giorni su 365, attesi circa ${(365 / 24).toStringAsFixed(1)}');
    expect(uguali, lessThan(80),
        reason: 'due nascite diverse vedono la stessa runa $uguali giorni su '
            '365: allora anche il Tramonto non e del singolo');
  });
}
