import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **IL CIELO DI NASCITA E QUELLO DI ADESSO.** Ordine FN, 13 ottobre 2026,
/// quattro correzioni chieste dal fondatore guardando l'onboarding e la home.
///
/// 1. La schermata raggiunta dall'onboarding, che prima diceva sempre "La
///    macchina del tempo", deve dire "Il tuo cielo di nascita" quando la
///    nascita e' nota.
/// 2. Deve aprirsi di default in modalita' bussola (`_colSensore = true`) col
///    cielo del luogo di nascita, non nel modo libero.
/// 3. "Viaggia nel tempo" e "Leggi la tua carta" non devono mai comparire
///    insieme: il secondo solo a corsa finita.
/// 4. Nella home, il cielo di adesso deve mostrare citta' e coordinate, sopra
///    il pulsante "Attiva macchina del tempo".
void main() {
  String senzaCommenti(String percorso) => File(percorso)
      .readAsStringSync()
      .split('\n')
      .where((r) =>
          !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
      .join('\n');

  final sorgente = senzaCommenti(
      'lib/features/real_time_cosmo/cielo_reale_screen.dart');

  group('FN.12, il titolo e la bussola di default', () {
    test('il titolo dice "Il tuo cielo di nascita" quando la nascita c\'e\'',
        () {
      expect(
          // Indifferente agli spazi: `dart format` puo' andare a capo
          // dopo la condizione (ordine FS).
          RegExp(r"widget\.nascita != null\s*\?\s*'Il tuo cielo di nascita'")
              .hasMatch(sorgente),
          isTrue,
          reason: 'il titolo del ritorno con nascita nota non e\' cambiato');
    });

    test('il modo ritorno apre in bussola quando la nascita e\' nota', () {
      expect(sorgente.contains('_colSensore = widget.nascita != null;'),
          isTrue,
          reason: 'il modo ritorno non lega piu\' la bussola alla nascita');
    });
  });

  group('FN.12, un solo pulsante alla volta', () {
    test('"Leggi la tua carta" aspetta la fine della corsa', () {
      expect(
          sorgente.contains(
              'if (fase != FaseDelRitorno.fermo || _fraseDArrivo.isEmpty) {'),
          isTrue,
          reason:
              'il pulsante del seguito non controlla piu\' la fine della '
              'corsa: puo\' tornare a comparire insieme a "Viaggia nel '
              'tempo"');
    });
  });

  group('FN.13, citta\' e coordinate sopra la macchina del tempo', () {
    test('la riga di citta\' e coordinate esiste nel cielo di adesso', () {
      expect(
          sorgente.contains("key: const Key('cielo_reale_citta_e_coordinate')"),
          isTrue,
          reason: 'la riga con la posizione rilevata e\' sparita');
    });

    test('la riga sta prima del pulsante della macchina, non dopo', () {
      final cittaECoordinate =
          sorgente.indexOf('cielo_reale_citta_e_coordinate');
      final pulsanteMacchina = sorgente
          .indexOf("righe.add(_pulsanteDellaMacchina());");
      expect(cittaECoordinate, greaterThan(-1));
      expect(pulsanteMacchina, greaterThan(-1));
      expect(cittaECoordinate, lessThan(pulsanteMacchina),
          reason: 'citta\' e coordinate devono stare SOPRA il pulsante '
              '"Attiva macchina del tempo", come nella vecchia schermata: '
              'qui vengono dopo');
    });
  });
}
