import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I NOMI DEL MENU' E DEL DIARIO. Ordine FE voce 22.1, 22.2 e 22.3**, le
/// prove a) e b) dell'aggiunta del fondatore del 6 ottobre 2026.
///
/// Nessun testo mostrato all'utente dice piu' "I giorni prima", "Parlami a
/// voce", "Cosmic Journal" o il gesto "Custodisci". Si leggono le stringhe
/// del codice di `lib`, fuori dai commenti. "Custodisci" resta come verbo
/// nei testi di contenuto (una carta, un presagio: "Custodisci la tua
/// sensibilita'") e nel nome della custodia dell'account ("Custodisci il tuo
/// cielo"), che sono altre cose: si colpisce il gesto, cioe' la stringa che
/// e' solo "Custodisci" o "Custodito", o che comincia con "Custodisci:".
void main() {
  final stringhe = <(String, String)>[];
  final file = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
  for (final f in file) {
    for (final riga in f.readAsLinesSync()) {
      final t = riga.trimLeft();
      if (t.startsWith('//')) continue;
      for (final m in RegExp(r"'((?:[^'\\]|\\.)*)'|" r'"((?:[^"\\]|\\.)*)"')
          .allMatches(riga)) {
        stringhe.add((f.path, m.group(1) ?? m.group(2) ?? ''));
      }
    }
  }

  test('a) i nomi vecchi non restano in un testo mostrato', () {
    cardinaleMinimo(file.length, 500, cosa: 'file di lib');
    cardinaleMinimo(stringhe.length, 10000, cosa: 'stringhe di lib');
    final colpe = <String>[
      for (final (dove, s) in stringhe)
        if (s.contains('I giorni prima') ||
            s.contains('Parlami a voce') ||
            s.contains('Cosmic Journal') ||
            s.trim() == 'Custodisci' ||
            s.trim() == 'Custodito' ||
            s.startsWith('Custodisci:'))
          '$dove: «$s»',
    ];
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('a) i quattro nomi nuovi ci sono, carattere per carattere', () {
    final tutte = stringhe.map((x) => x.$2).toSet();
    for (final nome in const [
      'Nuova chat',
      'Chat precedenti',
      'Diario Cosmico',
      'Segna nel Diario',
    ]) {
      expect(tutte, contains(nome), reason: 'manca «$nome»');
    }
  });

  test('b) "LIVE con" porta il nome del Maestro aperto, per tutti e tre', () {
    expect(IlNomeDelLive.di(Maestro.medora), 'LIVE con Medora');
    expect(IlNomeDelLive.di(Maestro.aura), 'LIVE con Aura');
    expect(IlNomeDelLive.di(Maestro.caligo), 'LIVE con Calìgo');
  });
}
