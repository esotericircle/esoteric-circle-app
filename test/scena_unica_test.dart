import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Un solo sistema di scena.
///
/// Nel codice convivevano sette modi di disegnare il cielo di fondo: tre
/// leggevano il sensore e quattro no, nel Santuario due si sovrapponevano
/// leggendo lo stesso controller con coefficienti diversi, e la stessa
/// costellazione si riconosceva in tre schermate. Questo test tiene chiusa la
/// porta: se uno dei painter morti ricompare, la suite cade.
void main() {
  /// Tutto il sorgente di lib/, letto una volta.
  final sorgenti = <String, String>{};
  for (final f in Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    sorgenti[f.path.replaceAll('\\', '/')] = f.readAsStringSync();
  }

  test('I painter del cielo eliminati non esistono piu\'', () {
    // I nomi dei sistemi morti il 29 luglio. SkyPostcard resta per scelta
    // dell'ordine (e' la condivisione, non una scena viva), _SkyFieldPainter
    // resta perche' e' la volta VERA del cielo, adottata anche dalla nascita.
    const morti = [
      '_SkyAccentsPainter',
      '_BackdropPainter',
      '_ProceduralBackdrop',
      '_PortalSkyPainter',
      'BirthSkyHero',
    ];
    final trovati = <String>[];
    for (final e in sorgenti.entries) {
      for (final m in morti) {
        if (e.value.contains(m)) trovati.add('$m in ${e.key}');
      }
    }
    expect(trovati, isEmpty,
        reason: 'un painter morto e\' ricomparso:\n${trovati.join('\n')}');
  });

  test('Una sola iscrizione all\'accelerometro per la parallasse', () {
    // Le iscrizioni legittime: quella del ParallaxController, unica per la
    // parallasse, e quelle dello SCUOTIMENTO nei riti, che sono un'altra
    // funzione con la loro soglia. Il ripiego del cosmo per i montaggi senza
    // provider crea al piu' UN controller condiviso, quindi non e' una
    // seconda iscrizione.
    final consentite = {
      'lib/core/motion/parallax_controller.dart',
      'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
      'lib/features/rituals/ritual_view.dart',
      'lib/features/rituals/sunset_rune_screen.dart',
      'lib/features/tarot/stesa_choreography.dart',
    };
    final fuori = <String>[];
    for (final e in sorgenti.entries) {
      if (e.value.contains('accelerometerEventStream') &&
          !consentite.contains(e.key)) {
        fuori.add(e.key);
      }
    }
    expect(fuori, isEmpty,
        reason: 'iscrizione al sensore fuori posto:\n${fuori.join('\n')}');
    // E i controller privati non tornano: uno solo, nel provider dell'app,
    // piu' il ripiego pigro del cosmo.
    final privati = <String>[];
    for (final e in sorgenti.entries) {
      if (e.key.endsWith('parallax_controller.dart')) continue;
      if (e.key.endsWith('cosmos_background.dart')) continue;
      if (e.key.endsWith('app.dart')) continue;
      if (RegExp(r'ParallaxController\(\)').hasMatch(e.value)) {
        privati.add(e.key);
      }
    }
    expect(privati, isEmpty,
        reason: 'controller privato della parallasse:\n${privati.join('\n')}');
  });

  test('Almeno quattro schermate hanno quattro semi di fondale diversi', () {
    final semi = <int>{};
    final re = RegExp(r'seed:\s*(\d+)\s*,');
    for (final e in sorgenti.entries) {
      if (!e.key.startsWith('lib/features/')) continue;
      for (final m in re.allMatches(e.value)) {
        semi.add(int.parse(m.group(1)!));
      }
    }
    expect(semi.length, greaterThanOrEqualTo(4),
        reason: 'semi distinti trovati: $semi');
  });

  test('Il motore mescola il seme in ogni generatore', () {
    final motore = sorgenti['lib/design_system/components/cosmos_background.dart']!;
    final generatori = RegExp(r'math\.Random\(([^)]*)\)').allMatches(motore);
    expect(generatori, isNotEmpty);
    for (final g in generatori) {
      expect(g.group(1), contains('seed'),
          reason: 'un generatore ignora il seme: Random(${g.group(1)})');
    }
  });
}
