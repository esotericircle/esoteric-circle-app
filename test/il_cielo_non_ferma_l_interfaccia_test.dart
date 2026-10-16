// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/services/ai/le_funzioni_del_cielo.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CIELO NON FERMA L'INTERFACCIA, ordine FE voce 01.**
///
/// Il crash del tester sul Redmi Note 14 Pro 5G, build 2298: un ANR col filo
/// principale dentro `cos`, sotto 143 passi di codice Dart. Il cielo di un
/// periodo che il modello chiede costa col motore di Meeus 2,3 secondi sul PC
/// per 400 giorni, e Flutter fa girare il codice Dart sul filo principale di
/// Android: oltre cinque secondi Android chiude l'app.
///
/// Questa guardia chiama ogni funzione del cielo che il Maestro puo' chiamare,
/// come la chiama la libreria del modello, e misura quanto tempo resta fermo
/// il filo di chi chiama prima di riavere il controllo: col periodo piu'
/// lungo, sotto i 50 millisecondi. E il risultato e' lo stesso del calcolo
/// diretto.
void main() {
  const tetto = Duration(milliseconds: 50);

  Future<(Duration, Map<String, Object?>)> chiama(
      AutoFunctionDeclaration f, Map<String, Object?> args) async {
    final w = Stopwatch()..start();
    final esito = f.callable(args);
    final fermo = w.elapsed;
    return (fermo, await esito);
  }

  test('ogni funzione del cielo lascia libero il filo dell\'interfaccia',
      () async {
    final dichiarate = LeFunzioniDelCielo.dichiarazioni();
    cardinaleMinimo(dichiarate.length, 2,
        cosa: 'funzioni del cielo date al Maestro');
    final fermi = <String, int>{};
    for (final f in dichiarate) {
      final args = f.name == LeFunzioniDelCielo.cieloDelPeriodo
          ? {'dal': '2026-10-05', 'al': '2027-12-31'}
          : {'data': '2027-06-21'};
      final (fermo, esito) = await chiama(f, args);
      fermi[f.name] = fermo.inMilliseconds;
      final diretto = f.name == LeFunzioniDelCielo.cieloDelPeriodo
          ? LeFunzioniDelCielo.periodo(args)
          : LeFunzioniDelCielo.giorno(args);
      expect(esito.toString(), diretto.toString(),
          reason: '${f.name}: fuori dal filo non dice lo stesso cielo');
    }
    print('ORDINE FE VOCE 01: millisecondi di filo fermo per funzione $fermi '
        '(tetto ${tetto.inMilliseconds})');
    for (final e in fermi.entries) {
      expect(e.value, lessThan(tetto.inMilliseconds),
          reason: '${e.key} ferma il filo per ${e.value} ms');
    }
  });

  test('il cielo dei giorni nominati si calcola fuori dal filo', () async {
    const domanda = 'Che cielo ci sarà il 21 giugno 2027 e il 3 marzo 2027?';
    final w = Stopwatch()..start();
    final esito = LeFunzioniDelCielo.cieloDeiGiorniNominatiFuoriDalFilo(domanda,
        adesso: DateTime(2026, 10, 5));
    final fermo = w.elapsedMilliseconds;
    final testo = await esito;
    print('ORDINE FE VOCE 01: giorni nominati, filo fermo $fermo ms, '
        '${testo.length} caratteri');
    expect(testo, contains('IL CIELO DEL'));
    expect(fermo, lessThan(tetto.inMilliseconds));
    expect(
        testo,
        LeFunzioniDelCielo.cieloDeiGiorniNominati(domanda,
            adesso: DateTime(2026, 10, 5)));
  });

  test('il cielo dei giorni nominati passa dalla porta fuori dal filo', () {
    // Tre giorni al massimo pesano poco in tempo: la prova guarda il corpo
    // del metodo che il turno usa, che deve calcolare dentro [fuoriDalFilo].
    final f = File('lib/services/ai/le_funzioni_del_cielo.dart')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    final inizio = f.indexOf('cieloDeiGiorniNominatiFuoriDalFilo(String');
    expect(inizio, greaterThan(0));
    final corpo = f.substring(inizio, f.indexOf('\n  }\n', inizio));
    expect(corpo, contains('fuoriDalFilo(() => _cieloDeiGiorni('),
        reason: 'il cielo dei giorni nominati si calcola sul filo');
  });

  test('il turno del Maestro usa il cielo dei giorni fuori dal filo', () {
    final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(provider, contains('cieloDeiGiorniNominatiFuoriDalFilo('));
    expect(
        RegExp(r'LeFunzioniDelCielo\.cieloDeiGiorniNominati\(')
            .hasMatch(provider),
        isFalse,
        reason: 'il turno calcola il cielo dei giorni sul filo '
            'dell\'interfaccia');
  });
}
