// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **LE FRASI NON SI RIPETONO FRA I PERIODI.** Ordine EU voce 16, 1 ottobre
/// 2026.
///
/// Il fatto, nelle catture del fondatore: *"La giornata invita al
/// raccoglimento, quindi riduci gli impegni dove puoi e ascolta ciò che
/// emerge nel silenzio."* stava nel Generale del Giorno, della Settimana e
/// del Mese, perche' la Settimana e il Mese prendevano come "che cosa puoi
/// fare" la lettura del Giorno del giorno migliore. Il rilievo del fondatore:
/// *"evitare ripetizioni"*.
///
/// Si pretende che nessuna frase di paragrafo stia in due periodi della
/// stessa persona nello stesso giorno: per sei persone, in tre giorni, nelle
/// tre tradizioni, si raccolgono le frasi dei paragrafi del Giorno, della
/// Settimana, del Mese e dell'Anno, in Lunga, e si contano quelle che stanno
/// in due periodi.
void main() {
  test('nessuna frase di paragrafo sta in due periodi dello stesso giorno', () {
    final uguali = <String>[];
    var confronti = 0;
    final giorni = [
      DateTime(2026, 10, 1),
      DateTime(2026, 12, 15),
      DateTime(2027, 3, 3),
    ];
    for (final persona in dodiciPersone.take(6)) {
      for (final oggi in giorni) {
        for (final t in TradizioneEu.values) {
          if (!persona.legge(t)) continue;
          final periodi = <String, Set<String>>{
            'Giorno': {
              for (final c in persona.giorno(t, oggi)) ...frasiDelTesto(c.text),
            },
            'Settimana': {
              for (final d in persona.periodo(t, oggi, mese: false).domini)
                ...frasiDelTesto(d.voce.testo(lunga: true)),
            },
            'Mese': {
              for (final d in persona.periodo(t, oggi, mese: true).domini)
                ...frasiDelTesto(d.voce.testo(lunga: true)),
            },
            'Anno': {
              for (final c in persona.anno(t, oggi)) ...frasiDelTesto(c.text),
            },
          };
          final nomi = periodi.keys.toList();
          for (var i = 0; i < nomi.length; i++) {
            for (var j = i + 1; j < nomi.length; j++) {
              confronti++;
              for (final f in periodi[nomi[i]]!.intersection(periodi[nomi[j]]!)) {
                uguali.add('${persona.nome}, ${oggi.day}/${oggi.month}/'
                    '${oggi.year}, ${t.name}, ${nomi[i]} e ${nomi[j]}: "$f"');
              }
            }
          }
        }
      }
    }
    // L'Occidentale e la Cinese per tutti; la Vedica per chi ha la Luna di
    // nascita (senza l'ora non la ha chi e' nato in un giorno di cambio).
    cardinaleMinimo(confronti, 6 * 3 * 2 * 6, cosa: 'coppie di periodi');
    print('ORDINE EU VOCE 16: frasi uguali fra periodi dello stesso giorno '
        '${uguali.length} su $confronti coppie di periodi');
    expect(uguali, isEmpty, reason: uguali.take(8).join('\n'));
  });
}
