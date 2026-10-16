// LE ANTEPRIME DELL'ORDINE FI, voce 45: la schermata dei selettori prima e
// dopo, a 360 per 797 punti logici con rapporto di pixel 3, per il Viandante,
// con la tendina delle stese aperta e con quella delle chiavi.
//
// La "prima" si fa girando questa prova sul codice di prima dell'ordine (il
// commit 8b113c79) con --dart-define=STATO=prima, la "dopo" sul codice di
// adesso con STATO=dopo. Senza STATO la prova monta, apre e non scrive niente.
// Il pannello si rende da solo: e' il pannello dei selettori, non la stesa.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _stato = String.fromEnvironment('STATO');

void main() {
  Future<void> caratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  for (final tendina in const ['stesa_tipo', 'stesa_chiave']) {
    testWidgets('I selettori, tendina $tendina', (tester) async {
      await caratteri();
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.reset);
      final radice = GlobalKey();
      final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
      // Il confine sta sopra il Navigator: la tendina aperta vive nel suo
      // overlay, e dentro la sola schermata non si vedrebbe.
      await tester.pumpWidget(MaterialApp(
        builder: (context, figlio) =>
            RepaintBoundary(key: radice, child: figlio),
        home: Builder(
          builder: (context) => Scaffold(
            backgroundColor: palette.deepest,
            body: SafeArea(
              child: SingleChildScrollView(
                child: TarotSetupPanel(
                  setup: const TarotSetup(),
                  palette: palette,
                  aperto: true,
                  piano: Tier.free,
                  onChanged: (_) {},
                  onLocked: (_) {},
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(tendina)));
      await tester.pumpAndSettle();
      if (_stato.isEmpty) return;
      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/fi_selettori_${tendina.substring(6)}_$_stato.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    });
  }
}
