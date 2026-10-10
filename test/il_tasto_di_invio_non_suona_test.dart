// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL TASTO DI INVIO NON SUONA.** Ordine EU voce 03, 1 ottobre 2026.
///
/// Il fondatore: *"Quando premo sul tasto di invio per avere la risposta
/// (interroga la luna, ecc) parte immediatamente un suono fastidioso che deve
/// essere eliminato, invece il suono orchestrale che gli ho caricato va
/// bene."* Il suono era la soglia (`soglia.mp3`), messa sul tocco di
/// "Interroga il cielo" dall'ordine BK voce 04 e sull'avvio della stesa dei
/// tarocchi dall'ordine CO voce 07.
///
/// Si pretende che nessun sorgente di `lib` faccia suonare la soglia: era il
/// suono dei tasti di invio, e il catalogo non ha altri momenti per lei. Un
/// suono nuovo alla pressione di un invio passerebbe di qui solo se qualcuno
/// lo scrivesse col nome della soglia; per gli altri suoni vale la prova
/// dell'Oroscopo, che pretende zero suoni al tocco.
void main() {
  test('nessun sorgente fa suonare la soglia alla pressione di un invio', () {
    final fuori = <String>[];
    var guardati = 0;
    for (final f in righeDiLib()) {
      if (f.percorso.replaceAll('\\', '/').endsWith('catalogo_suoni.dart')) {
        continue;
      }
      guardati++;
      final testo = senzaCommenti(f.righe.join('\n'));
      if (testo.contains('SuonoDelCerchio.soglia')) fuori.add(f.percorso);
    }
    print('EU.03: sorgenti guardati $guardati, che suonano la soglia '
        '${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'questi sorgenti fanno suonare la soglia, il suono '
            'dell\'invio che il fondatore ha chiesto di togliere: $fuori');
  });
}
