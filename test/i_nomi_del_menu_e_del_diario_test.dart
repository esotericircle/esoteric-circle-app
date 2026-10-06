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
/// del codice di `lib`, fuori dai commenti. Fino al 6 ottobre 2026
/// "Custodisci" restava come verbo nei testi di contenuto e nella voce
/// dell'account ("Custodisci il tuo cielo"), e si colpiva solo il gesto; la
/// prova a) del fondatore dice "in un testo mostrato all'utente", quindi
/// adesso cade la parola ovunque stia (i quattro testi sono stati
/// riscritti: "Metti al sicuro il tuo cielo", "Abbi cura della tua
/// sensibilità", "Metti al sicuro ciò che hai", "Conserva quella
/// scintilla"). Il verbo minuscolo dentro una frase resta: non e' il nome
/// del gesto.
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
            // **La prova a) del fondatore alla lettera, ordine FE voce
            // 22.3**: "una prova cade se restano [...] «Custodisci» in un
            // testo mostrato all'utente". Fino al 6 ottobre 2026 qui
            // cadevano solo "Custodisci" da solo o in testa con i due
            // punti, e passavano quattro testi: la voce dell'account, una
            // carta, l'oroscopo cinese, un presagio. Adesso cade la parola,
            // ovunque stia.
            RegExp(r'(?<![A-Za-zÀ-ÿ])Custodisci(?![A-Za-zÀ-ÿ])').hasMatch(s) ||
            s.trim() == 'Custodito')
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
