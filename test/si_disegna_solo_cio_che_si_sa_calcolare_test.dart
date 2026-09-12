import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// SI DISEGNA SOLO CIO' CHE SI SA CALCOLARE.
///
/// **La segnalazione.** Sul cielo compare Ariete, disegnato, con la sua
/// etichetta. Lo si tocca, e la scheda risponde "Questa costellazione non sta
/// fra quelle che il motore segue". L'app disegna una cosa e poi dichiara di
/// non conoscerla.
///
/// **Erano DUE CATALOGHI.** Uno serve a disegnare le figure e le ha tutte e
/// dodici; l'altro, `bright_stars.json`, serve a rispondere e ne aveva sei.
/// Mancavano Ariete, Cancro, Bilancia, Capricorno, Acquario e Pesci: e' la
/// decima occorrenza della famiglia delle due porte.
///
/// **Questa prova non guarda Ariete: guarda la CLASSE.** Enumera tutte le
/// figure disegnabili e cade se anche una sola non ha voce nel catalogo che
/// risponde. Una prova su Ariete sarebbe verde il giorno in cui manca il Cancro.
void main() {
  /// I nomi italiani delle costellazioni che il catalogo sa calcolare.
  Set<String> catalogoCheRisponde() {
    final grezzo =
        jsonDecode(File('assets/data/bright_stars.json').readAsStringSync());
    final lista = (grezzo as Map<String, dynamic>)['constellations'] as List;
    return {
      for (final c in lista)
        ((c as Map<String, dynamic>)['name'] as String).toLowerCase(),
    };
  }

  test('Ogni figura disegnabile ha voce nel catalogo che risponde', () {
    final sa = catalogoCheRisponde();
    final mute = <String>[];
    for (final segno in Zodiac.values) {
      final nome = segno.italianName.toLowerCase();
      final trovata = sa.any((c) => c.contains(nome) || nome.contains(c));
      if (!trovata) mute.add(segno.italianName);
    }
    expect(mute, isEmpty,
        reason: 'queste costellazioni si disegnano e il motore non le conosce, '
            'quindi toccandole l\'app dichiara di non saperle calcolare: $mute');
  });

  test('Ogni voce del catalogo ha stelle vere e complete', () {
    // Un nome senza stelle sarebbe peggio del nome mancante: la prova sopra
    // sarebbe verde e la scheda risponderebbe lo stesso che non sa niente.
    final grezzo =
        jsonDecode(File('assets/data/bright_stars.json').readAsStringSync());
    final lista = (grezzo as Map<String, dynamic>)['constellations'] as List;
    for (final c in lista) {
      final m = c as Map<String, dynamic>;
      final nome = m['name'] as String;
      final stelle = m['stars'] as List;
      expect(stelle.length, greaterThanOrEqualTo(3),
          reason: '$nome ha ${stelle.length} stelle: non basta a disegnare ne '
              'a rispondere');
      for (final s in stelle) {
        final v = (s as List).cast<num>();
        expect(v.length, 3,
            reason: '$nome ha una stella senza i suoi tre numeri, ascensione '
                'retta, declinazione e magnitudine');
        expect(v[0], inInclusiveRange(0, 360),
            reason: '$nome ha un ascensione retta fuori scala: $v');
        expect(v[1], inInclusiveRange(-90, 90),
            reason: '$nome ha una declinazione fuori scala: $v');
        expect(v[2], inInclusiveRange(-2, 7),
            reason: '$nome ha una magnitudine implausibile: $v');
      }
    }
  });

  test('Il catalogo dichiara da dove vengono i numeri', () {
    // Coordinate senza fonte sono coordinate inventate finche' qualcuno non
    // dimostra il contrario, e nessuno lo dimostrera' mai.
    final grezzo =
        jsonDecode(File('assets/data/bright_stars.json').readAsStringSync());
    final nota =
        ((grezzo as Map<String, dynamic>)['note'] as String).toLowerCase();
    expect(nota, contains('hipparcos'),
        reason: 'il catalogo non dichiara da quale catalogo pubblico vengono '
            'le coordinate');
  });
}
