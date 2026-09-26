import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// La scelta fra soffio e tocco resta a schermo finche' non si decide.
///
/// Nella schermata della rivelazione, dopo qualche secondo l'invito a soffiare
/// spariva e restava il solo "Tocca per svelare". La causa era un `else if`
/// esclusivo: quando il suggerimento del tocco si accendeva, prendeva il POSTO
/// del blocco che conteneva la richiesta del microfono, invece di aggiungersi.
/// Chi stava ancora decidendo si vedeva togliere una delle due strade sotto gli
/// occhi, e la correzione precedente non poteva bastare perche' riguardava il
/// tocco fuori dal foglio, non lo scadere del tempo.
///
/// Vale per tutti e tre i Maestri, perche' la schermata e' una sola: sfera di
/// cristallo per Medora, candela per Caligo, soffione per Aura.
void main() {
  // Solo il CODICE: il commento che spiega il difetto cita la riga di prima, e
  // cercarla anche li' farebbe fallire il test per la ragione opposta a quella
  // che deve misurare.
  final sorgente = File('lib/features/onboarding/maestro_reveal_screen.dart')
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join(' ');

  test('Il suggerimento del tocco non sostituisce la scelta', () {
    // Il difetto in una riga: `else if (_showSafetyTap)` come ramo alternativo
    // al blocco della scelta.
    expect(sorgente.contains('else if (_showSafetyTap)'), isFalse,
        reason:
            'il tocco e\' ancora un ramo ALTERNATIVO alla scelta: quando si '
            'accende, la richiesta del microfono sparisce');
  });

  test('Il tocco si aggiunge dentro il blocco della scelta', () {
    final da = sorgente.indexOf("_micAvailable && !_micAsked");
    expect(da, greaterThan(0), reason: 'blocco della scelta non trovato');
    final blocco = sorgente.substring(da, da + 700);
    expect(blocco.contains('_showSafetyTap'), isTrue,
        reason: 'il suggerimento del tocco non sta dentro il blocco della '
            'scelta, quindi non convive con essa');
    expect(blocco.contains('reveal_voice_invite'), isTrue,
        reason: 'l\'invito a soffiare non e\' identificabile a schermo');
  });

  test('Nessun timer nasconde la scelta', () {
    // La scelta non ha limite di tempo: nessuna sparizione programmata.
    final da = sorgente.indexOf("_micAvailable && !_micAsked");
    final blocco = sorgente.substring(da, da + 700);
    for (final sospetto in const ['Timer(', 'Future.delayed']) {
      expect(blocco.contains(sospetto), isFalse,
          reason: 'dentro il blocco della scelta c\'e\' un "$sospetto": la '
              'scelta non deve avere scadenza');
    }
  });
}
