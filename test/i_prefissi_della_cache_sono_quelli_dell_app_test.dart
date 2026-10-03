import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/la_cache_del_contesto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA CACHE TIENE L'ISTRUZIONE DELL'APP, NON UNA VECCHIA.** Ordine EX
/// Aggiunta 4, voce EX.05.
///
/// La funzione `laCacheDelContesto` mette in cache i prefissi scritti in
/// `functions/src/la_cache_prefissi.json`, e il telefono usa la cache solo se
/// l'impronta scritta dalla funzione e' uguale alla sua. Se la parte comune
/// dell'istruzione cambia e il file no, la cache terrebbe l'istruzione di
/// ieri: qui si pretende che il file sia quello dell'app di oggi. Si rifa'
/// con `flutter test -r expanded tool/i_prefissi_della_cache.dart`.
void main() {
  test('il file dei prefissi e\' quello dell\'app', () {
    final file = jsonDecode(
            File('functions/src/la_cache_prefissi.json').readAsStringSync())
        as Map<String, dynamic>;
    final varianti = (file['varianti'] as Map).cast<String, String>();
    final dellApp = LaCacheDelContesto.prefissi();
    cardinaleMinimo(varianti.length, 6, cosa: 'varianti della cache');
    expect(varianti.keys.toSet(), dellApp.keys.toSet());
    for (final v in dellApp.keys) {
      expect(varianti[v], dellApp[v],
          reason: 'la parte comune di $v e\' cambiata: rifare il file con '
              'tool/i_prefissi_della_cache.dart');
    }
    expect(file['impronta'], LaCacheDelContesto.impronta());
  });

  test('ogni prefisso supera il minimo della cache esplicita', () {
    // Vertex vuole almeno 1.024 token per una cache di gemini-2.5-flash:
    // quattro caratteri a token sono una stima prudente per l'italiano.
    for (final e in LaCacheDelContesto.prefissi().entries) {
      expect(e.value.length ~/ 4, greaterThan(1024), reason: e.key);
    }
  });

  group('lo stato letto dal telefono', () {
    final ora = DateTime.utc(2026, 10, 2, 20);
    final variante =
        LaCacheDelContesto.variante(Maestro.medora, conSeguito: true);
    Map<String, Object?> stato(
            {bool accesa = true,
            String? impronta,
            Duration vita = const Duration(minutes: 15)}) =>
        {
          'accesa': accesa,
          'impronta': impronta ?? LaCacheDelContesto.impronta(),
          'scade': ora.add(vita).toIso8601String(),
          'cache': {
            variante: 'projects/p/locations/europe-west1/cachedContents/1'
          },
        };
    tearDown(() => LaCacheDelContesto.statoDiProva = null);

    test('accesa e viva: il nome della cache', () async {
      LaCacheDelContesto.statoDiProva = stato();
      expect(await LaCacheDelContesto.nomePer(variante, adesso: ora),
          endsWith('cachedContents/1'));
    });
    test('spenta: la via di sempre', () async {
      LaCacheDelContesto.statoDiProva = stato(accesa: false);
      expect(await LaCacheDelContesto.nomePer(variante, adesso: ora), isNull);
    });
    test('d\'un\'altra versione dell\'app: la via di sempre', () async {
      LaCacheDelContesto.statoDiProva = stato(impronta: '0000');
      expect(await LaCacheDelContesto.nomePer(variante, adesso: ora), isNull);
    });
    test('che scade fra meno di un minuto: la via di sempre', () async {
      LaCacheDelContesto.statoDiProva =
          stato(vita: const Duration(seconds: 30));
      expect(await LaCacheDelContesto.nomePer(variante, adesso: ora), isNull);
    });
  });
}
