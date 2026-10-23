import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// I COLLAUDI SONO REGISTRATI, IN DUE COPIE UGUALI. Ordine FD voce 05 b).
///
/// Il registro leggibile, `docs/collaudo/registro_dei_collaudi.md`, e quello
/// che il server usa per separare la presenza dei collaudi da quella degli
/// utenti, `functions/src/i_collaudi.ts`, devono dire gli stessi account. E
/// i due account del giro del Cerchio popolato ci devono essere tutti e due.
void main() {
  final uid = RegExp(r'[A-Za-z0-9]{28}');

  Set<String> nelServer() {
    final s = File('functions/src/i_collaudi.ts').readAsStringSync();
    final inizio = s.indexOf('ACCOUNT_DI_COLLAUDO');
    final fine = s.indexOf('};', inizio);
    return RegExp(r'"([A-Za-z0-9]{28})"')
        .allMatches(s.substring(inizio, fine))
        .map((m) => m.group(1)!)
        .toSet();
  }

  Set<String> nelRegistro() {
    final righe = File('docs/collaudo/registro_dei_collaudi.md')
        .readAsLinesSync()
        .where((r) => r.startsWith('| `'));
    return {
      for (final r in righe)
        if (uid.firstMatch(r) case final m?) m.group(0)!,
    };
  }

  test('il registro e il server dicono gli stessi account di collaudo', () {
    final server = nelServer();
    final registro = nelRegistro();
    cardinaleMinimo(server.length, 1, cosa: 'account di collaudo nel server');
    expect(registro, server,
        reason: 'il registro leggibile e quello del server non coincidono');
  });

  test('b) i due account del giro del Cerchio sono registrati come collaudi',
      () {
    expect(nelRegistro().length, greaterThanOrEqualTo(2),
        reason: 'il giro del Cerchio popolato vuole due account di collaudo');
    expect(nelServer().length, greaterThanOrEqualTo(2));
  });
}
