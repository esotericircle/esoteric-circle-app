import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La carta natale aperta dal Passport ha la sua scaffalatura.
///
/// **Tre sintomi, una causa.** Aprendola dal Passport ogni testo compariva
/// sottolineato in giallo, il fondo era nero invece del cosmo, e la parallasse
/// spariva. Non era una scelta di stile: Flutter disegna quelle righe quando un
/// `Text` non trova un antenato `Material` da cui ereditare lo stile, e il fondo
/// nero e' il secondo sintomo della stessa mancanza.
///
/// La rotta l'avevo scritta io, in un ordine precedente, montando il widget
/// nudo dentro un `MaterialPageRoute` senza alcuno scaffale. La cura non e'
/// togliere la decorazione: e' dare alla schermata l'antenato che le manca.
void main() {
  final sorgente = File('lib/features/passport/cosmic_passport_screen.dart')
      .readAsStringSync();

  test('La rotta della carta natale monta uno scaffale immersivo', () {
    final da = sorgente.indexOf("Key('passport_natal_chart')");
    expect(da, greaterThan(0), reason: 'tessera della carta natale non trovata');
    final blocco = sorgente.substring(da, da + 1600);
    expect(blocco.contains('ImmersiveScaffold'), isTrue,
        reason: 'la carta natale si apre senza scaffale: senza un antenato '
            'Material ogni testo prende la riga gialla e il fondo resta nero');
  });

  test('Il pulsante in fondo riporta al Passport', () {
    final da = sorgente.indexOf("Key('passport_natal_chart')");
    final blocco = sorgente.substring(da, da + 1600);
    expect(blocco.contains('Torna al Passport'), isTrue,
        reason: 'la carta aperta dal Passport invita ancora alla Risonanza, che '
            'e\' gia\' avvenuta');
  });

  test('Nessuna rotta di lib monta un widget nudo senza scaffale', () {
    // La rete: la stessa causa non deve tornare da un\'altra porta.
    final sospette = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final t = f.readAsStringSync().replaceAll('\r\n', '\n');
      for (final m in RegExp(
              r'MaterialPageRoute<void>\(\s*(?:fullscreenDialog:[^,]+,\s*)?builder: \([^)]*\) =>\s*([\s\S]{0,220})')
          .allMatches(t)) {
        final blocco = m.group(1)!;
        final haScaffale =
            blocco.contains('Scaffold') || blocco.contains('ImmersiveScaffold');
        // Una schermata porta il proprio scaffale al suo interno: la rete
        // guarda solo chi monta widget che non sono schermate.
        final eSchermata =
            blocco.contains('Screen(') || blocco.contains('Journey(');
        if (!haScaffale && !eSchermata) {
          sospette.add('${f.path}: ${blocco.split('\n').first.trim()}');
        }
      }
    }
    expect(sospette, isEmpty,
        reason: 'queste rotte montano un widget senza scaffale, quindi i loro '
            'testi prenderanno la riga gialla:\n${sospette.join('\n')}');
  });
}
