import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA NOTA DEL CIELO DICE COSA E' CALCOLATO E COSA NON C'E'.
///
/// Diceva "Orientato sul tuo luogo. La posizione esatta di ogni astro nel cielo
/// arriva col motore a effemeridi", ed era vera quando fu scritta. Da quando la
/// Luna e le costellazioni si posizionano da altezza e azimut reali era meta'
/// falsa: negava in blocco un calcolo che l'app fa davvero. Restava vera
/// sull'altra meta', perche' gli altri pianeti li' non si disegnano.
void main() {
  String schermataDelCielo() =>
      File('lib/features/santuario/sky_overview_screen.dart').readAsStringSync();

  test('La nota non nega piu in blocco il calcolo che l app fa', () {
    expect(schermataDelCielo(),
        isNot(contains('La posizione esatta di ogni astro')),
        reason: 'la nota dichiara ancora che nessuna posizione e calcolata, '
            'mentre Luna e costellazioni hanno altezza e azimut veri');
  });

  test('La nota distingue cio che e calcolato da cio che non c e', () {
    final t = schermataDelCielo();
    expect(t, contains('Gli altri pianeti non si disegnano'),
        reason: 'la nota non dice quale parte manca: negare tutto in blocco e '
            'dire tutto sono due modi di non essere precisi');
  });

  test('La nota vive in un punto solo, non due', () {
    // La schermata del cielo di nascita e' la stessa classe con `birth` vero:
    // se la nota fosse scritta due volte, i due testi divergerebbero al primo
    // cambio, ed e' la famiglia delle due porte.
    var punti = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final righe = f
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (righe.contains('Gli altri pianeti non si disegnano')) punti++;
    }
    expect(punti, 1,
        reason: 'la nota del cielo e scritta in $punti file: due testi che '
            'devono restare coerenti divergono al primo cambio');
  });
}
