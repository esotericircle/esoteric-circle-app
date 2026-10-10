import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA STESA HA UNA RICHIESTA DI RISERVA.** Ordine EQ voce 04, 27 settembre
/// 2026.
///
/// Sul Realme, con la build di prova, una stesa su tre e' finita nella
/// lettura di casa a 10.001 millesimi: la chiamata non era tornata e si era
/// presa tutta la pazienza, mentre le altre due tornavano in circa quattro
/// secondi (`docs/collaudo/EQ/realme/eq04_build_eq_attesa_della_stesa.txt`).
/// Padre: la voce EQ.04 stessa, che ritentava solo dopo una lettura tornata.
///
/// Le prove girano a scala: un millesimo di qui vale un centesimo di secondo
/// del telefono.
void main() {
  const dopo = Duration(milliseconds: 45);

  test('la riserva parte in tempo per stare nella pazienza', () {
    expect(LaLetturaDellaStesa.riservaDopo + const Duration(seconds: 4),
        lessThan(LaLetturaDellaStesa.pazienza),
        reason: 'una riserva che parte dopo '
            '${LaLetturaDellaStesa.riservaDopo.inMilliseconds} ms e torna in '
            'quattro secondi non sta nei dieci della pazienza');
  });

  test('la lettura passa dalla riserva', () {
    final sorgente =
        File('lib/core/tarot/la_lettura_dal_modello.dart').readAsStringSync();
    final leggi = sorgente.substring(
        sorgente.indexOf('static Future<LetturaDelModello?> leggi('),
        sorgente
            .indexOf('static Future<LetturaDelModello?> _riscriviIlGenere('));
    expect(leggi, contains('await primaCheTorna('),
        reason: 'la lettura chiede il modello senza la richiesta di riserva');
  });

  test('una chiamata che non torna non si prende tutta la pazienza', () async {
    var chiamate = 0;
    LaLetturaDellaStesa.ultimeRiserve = 0;
    final testo = await LaLetturaDellaStesa.primaCheTorna(() {
      chiamate++;
      // La prima resta appesa, la riserva torna dopo "quattro secondi".
      if (chiamate == 1) return Completer<String?>().future;
      return Future<String?>.delayed(
          const Duration(milliseconds: 40), () => 'la lettura');
    }, dopo: dopo)
        .timeout(const Duration(milliseconds: 500));
    expect(testo, 'la lettura');
    expect(chiamate, 2);
    expect(LaLetturaDellaStesa.ultimeRiserve, 1);
  });

  test('una chiamata veloce non ne fa partire un\'altra', () async {
    var chiamate = 0;
    await LaLetturaDellaStesa.primaCheTorna(() {
      chiamate++;
      return Future<String?>.delayed(
          const Duration(milliseconds: 20), () => 'la lettura');
    }, dopo: dopo);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(chiamate, 1, reason: 'una chiamata in piu\' pagata per niente');
  });

  test('se la prima cade, vale la riserva', () async {
    var chiamate = 0;
    final testo = await LaLetturaDellaStesa.primaCheTorna(() {
      chiamate++;
      if (chiamate == 1) {
        return Future<String?>.delayed(
            const Duration(milliseconds: 60), () => throw StateError('rete'));
      }
      return Future<String?>.delayed(
          const Duration(milliseconds: 30), () => 'la lettura');
    }, dopo: dopo);
    expect(testo, 'la lettura');
  });
}
