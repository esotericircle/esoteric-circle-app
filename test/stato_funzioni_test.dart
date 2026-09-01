import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

/// Anello di coerenza dello stato: lo stato dichiarato deve seguire il codice.
///
/// `docs/stato_funzioni.json` e' la fonte macchina delle funzioni dello scaffale
/// del Santuario e del loro stato live; STATO_VIVO.md la cita. Questo test entra
/// nel verde della CI (gira con `flutter test`) e FALLISCE se il manifest e il
/// codice reale in `lib/core/santuario/function_shelf.dart` divergono: una
/// funzione aggiunta o tolta, oppure un flag `live` cambiato in un solo posto.
/// Cosi' la spunta verde cade quando lo stato dichiarato mente sul codice.
void main() {
  test('il manifest stato_funzioni.json coincide col function_shelf reale', () {
    final raw = File('docs/stato_funzioni.json').readAsStringSync();
    final manifest = jsonDecode(raw) as Map<String, dynamic>;

    // Verita' dichiarata: id -> live, dal manifest.
    final dichiarato = <String, bool>{
      for (final e in (manifest['funzioni'] as Map<String, dynamic>).entries)
        e.key: e.value as bool,
    };

    // Verita' reale: id -> live, dal codice.
    final reale = <String, bool>{
      for (final f in FunctionShelf.functions) f.id: f.live,
    };

    // Il manifest deve puntare al file di codice giusto.
    expect(manifest['fonte_codice'], 'lib/core/santuario/function_shelf.dart');

    // Stesso insieme di funzioni, nessuna in piu' ne in meno.
    expect(dichiarato.keys.toSet(), reale.keys.toSet(),
        reason: 'Le funzioni nel manifest e nel function_shelf non coincidono. '
            'Allinea docs/stato_funzioni.json a function_shelf.dart.');

    // Stesso stato live per ciascuna funzione.
    expect(dichiarato, reale,
        reason: 'Uno stato live diverge fra il manifest e il codice. '
            'Aggiorna docs/stato_funzioni.json (e STATO_VIVO.md) col codice.');
  });
}
