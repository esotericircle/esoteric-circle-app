import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA STANZA DEL LIVE SI STACCA E SI LIBERA.** Ordine ET voce 04, 28
/// settembre 2026.
///
/// Nella prova della voce sul Realme, dieci secondi dopo la chiusura del LIVE
/// per silenzio, l'app e' morta con un aborto nativo di WebRTC nel thread
/// della segnalazione (`docs/collaudo/ET/trascrizione.txt`); lo stesso nella
/// sessione dell'ordine ER delle 02:19. La stanza si staccava soltanto
/// (`disconnect`), dall'ordine EG voce 04 (commit `1104da29`), e il motore
/// di WebRTC restava vivo sotto la pagina della fine: quando la strada
/// dell'audio del telefono cambiava, abortiva.
///
/// Il difetto vive nel codice nativo, dove una prova non arriva: qui si
/// guarda che la schermata liberi la stanza dopo averla staccata, alla
/// chiusura e quando si esce; la prova vera e' sul telefono.
void main() {
  final sorgente =
      File('lib/features/maestri/live/schermata_live.dart').readAsStringSync();

  String corpo(String firma) {
    final i = sorgente.indexOf(firma);
    expect(i, greaterThanOrEqualTo(0), reason: 'firma non trovata: $firma');
    var livello = 0;
    for (var k = sorgente.indexOf('{', i); k < sorgente.length; k++) {
      if (sorgente[k] == '{') livello++;
      if (sorgente[k] == '}' && --livello == 0) {
        return sorgente.substring(i, k + 1);
      }
    }
    fail('corpo non chiuso: $firma');
  }

  test('ET.04: staccata, la stanza si libera', () {
    final lascia = corpo('Future<void> _lasciaLaStanza()');
    expect(lascia, contains('.disconnect()'));
    expect(lascia, contains('.dispose()'),
        reason: 'la stanza si stacca e non si libera: il motore di WebRTC '
            'resta vivo sotto la pagina della fine');
    expect(lascia.indexOf('.disconnect()'),
        lessThan(lascia.indexOf('.dispose()')),
        reason: 'si libera prima di staccarla');
  });

  test('ET.04: alla chiusura e all\'uscita la stanza passa da li\'', () {
    expect(corpo('Future<void> _chiudi('), contains('_lasciaLaStanza()'));
    expect(corpo('void dispose()'), contains('_lasciaLaStanza()'));
    expect(RegExp(r'_stanza\?\.disconnect\(\)').hasMatch(sorgente), isFalse,
        reason: 'la stanza si stacca ancora da sola, senza liberarsi');
  });
}
