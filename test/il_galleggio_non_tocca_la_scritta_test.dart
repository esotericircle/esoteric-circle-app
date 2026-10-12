// IL GALLEGGIO NON TOCCA LA SCRITTA. Ordine FM, aggiunta 1, 12 ottobre 2026.
//
// Il fondatore: "vorrei che le carte fluttuassero leggermente quando sono in
// verticale, ma stai attento che non tocchino la propria didascalia subito
// sotto". Le carte in piedi fluttuano gia' (TiltListener.fluttuazioneDi,
// ordine BU) con un Transform.translate che sposta solo il disegno della
// carta, non la scritta sotto: un effetto di superficie. Qui si verifica che
// la distanza fra la carta e la sua scritta resti maggiore dell'ampiezza del
// galleggio anche nel punto piu' basso dell'oscillazione, con un margine.
//
// `distanzaDellaScritta` e' una costante privata (_Slot): la si legge dal
// sorgente, come fanno le altre guardie del progetto sulle costanti private.

import 'dart:io';

import 'package:esoteric_circle/features/tarot/stesa_senses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'la distanza fra la carta in piedi e la sua scritta resta positiva '
      'anche al punto piu\' basso del galleggio', () {
    final codice = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    final m = RegExp(r'distanzaDellaScritta\s*=\s*SpacingTokens\.(\w+);')
        .firstMatch(codice);
    expect(m, isNotNull,
        reason: 'distanzaDellaScritta non si trova piu\' nel sorgente');
    final token = m!.group(1)!;
    final valori = <String, double>{
      'xxs': 4,
      'xs': 8,
      'sm': 12,
      'md': 16,
      'lg': 24,
      'xl': 32,
    };
    final distanza = valori[token];
    expect(distanza, isNotNull,
        reason: 'il token SpacingTokens.$token non e\' nella mappa qui sopra: '
            'aggiungilo');
    final margine = distanza! - TiltListener.ampiezzaDelGalleggio;
    // ignore: avoid_print
    print('ORDINE FM AGGIUNTA 1: distanza carta-scritta $distanza punti, '
        'galleggio ${TiltListener.ampiezzaDelGalleggio} punti, margine '
        '$margine punti');
    expect(margine, greaterThan(0.5),
        reason: 'la carta che galleggia puo\' toccare o quasi la sua '
            'scritta: distanza $distanza, galleggio '
            '${TiltListener.ampiezzaDelGalleggio}, margine $margine');
  });
}
