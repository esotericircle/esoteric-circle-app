// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/services/ai/la_cache_del_contesto.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I PREFISSI DELLA CACHE.** Ordine EX Aggiunta 4, voce EX.05.
///
/// Scrive `functions/src/la_cache_prefissi.json`: per ogni variante (tre
/// Maestri, chat col seguito e senza) la parte comune dell'istruzione, che la
/// funzione `laCacheDelContesto` mette in cache, e l'impronta che il telefono
/// confronta con la sua. Si rifa' ogni volta che la parte comune cambia: la
/// guardia `test/i_prefissi_della_cache_sono_quelli_dell_app_test.dart`
/// diventa rossa finche' non si rifa'.
///
///     flutter test -r expanded tool/i_prefissi_della_cache.dart
void main() {
  test('i prefissi della cache', () {
    final dati = {
      'impronta': LaCacheDelContesto.impronta(),
      'varianti': LaCacheDelContesto.prefissi(),
    };
    File('functions/src/la_cache_prefissi.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(dati)}\n');
    print('PREFISSI: ${(dati['varianti'] as Map).length} varianti, impronta '
        '${dati['impronta']}');
  });
}
