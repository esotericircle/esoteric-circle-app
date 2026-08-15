import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/sigilli/pittore_della_festa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE NOVE ANTEPRIME DELLE TRE FESTE. Ordine U voce 02.
///
/// **Tre fotogrammi per Maestro, all'inizio, a meta' e alla fine.** Alla
/// larghezza vera del telefono di Mauro, 360 per 797. Sono le immagini su cui
/// dira' se e' una festa o no, quindi vanno guardate prima di consegnarle.
///
/// Si lancia a mano:
///
///     flutter test tool/anteprime_delle_feste.dart
void main() {
  const larghezza = 360.0;
  const altezza = 797.0;

  /// I TRE MOMENTI. Non a caso: l'inizio e' quando il fronte e' appena partito,
  /// la meta' e' quando riempie la scena, la fine e' quando ha scoperto cio' che
  /// c'era sotto.
  const momenti = {'inizio': 0.18, 'meta': 0.5, 'fine': 0.92};

  setUpAll(() async {
    final font = FontLoader('Cinzel')
      ..addFont(File('assets/fonts/Cinzel-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await font.load();
  });

  testWidgets('le nove anteprime delle feste', (tester) async {
    tester.view.physicalSize = const Size(larghezza * 2, altezza * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    var scattate = 0;
    for (final maestro in Maestro.values) {
      final palette = switch (maestro) {
        Maestro.medora => MaestroPalette.medora,
        Maestro.caligo => MaestroPalette.caligo,
        Maestro.aura => MaestroPalette.aura,
      };
      for (final momento in momenti.entries) {
        final chiave = GlobalKey();
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: chiave,
            child: Container(
              width: larghezza,
              height: altezza,
              color: const Color(0xFF0B0D1A),
              child: Stack(
                children: [
                  // Cio' che la festa scopre: il nome e il premio, come nella
                  // scena vera. Senza, non si vedrebbe se la festa copre o apre.
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Hai gettato le prime rune',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 26,
                                color: palette.gold)),
                        const SizedBox(height: 12),
                        Text('+20 Eos',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 18,
                                color: palette.goldSoft)),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PittoreDellaFesta(
                        maestro: maestro,
                        avanzamento: momento.value,
                        oro: palette.gold,
                        oroTenue: palette.goldSoft,
                        eGrande: false,
                        effettiPieni: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
        await tester.pump();
        final scatola =
            chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final immagine = await scatola.toImage(pixelRatio: 2.0);
        final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
        final dove =
            File('docs/preview/festa_${maestro.id}_${momento.key}.png');
        dove.parent.createSync(recursive: true);
        dove.writeAsBytesSync(png!.buffer.asUint8List());
        scattate++;
        // ignore: avoid_print
        print('anteprima: ${dove.path}');
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 02: anteprime scattate $scattate');
    expect(scattate, 9);
  });
}
