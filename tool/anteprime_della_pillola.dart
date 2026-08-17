import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE DUE VESTI DELLA PILLOLA, A TRE SALDI. Ordine AI voce 01.
///
/// Un quadro solo per gli occhi di Mauro: le vesti VELO e ORO, ciascuna a 0,
/// 1.000 e 10.000 Eos, sui fondi delle tre palette. La voce e' FERMATA IN
/// ATTESA DI DECISIONE su quale delle due vestire.
///
/// Si lancia a mano:
///
///     flutter test tool/anteprime_della_pillola.dart
void main() {
  setUpAll(() async {
    final font = FontLoader('EBGaramond')
      ..addFont(File('assets/fonts/EBGaramond-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await font.load();
    final titoli = FontLoader('Cinzel')
      ..addFont(File('assets/fonts/Cinzel-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await titoli.load();
  });

  testWidgets('le due vesti a tre saldi', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(720, 1960);
    addTearDown(tester.view.reset);

    final chiave = GlobalKey();
    Widget riga(VesteDellaPillola veste, int saldo) {
      final borsa = QuestionAllowance();
      // Il saldo si applica prima del montaggio: il conto animato parte dal
      // numero stesso e il fotogramma e' subito quello vero.
      borsa.applicaSaldo(saldo);
      return ChangeNotifierProvider<QuestionAllowance>.value(
        value: borsa,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${veste.name} a $saldo',
                  style: TypographyTokens.corpo()
                      .copyWith(color: const Color(0xFFB7B0A0))),
              SegnoDelBorsellino(veste: veste),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
        key: chiave,
        child: Container(
          color: const Color(0xFF0B0D1A),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final maestro in Maestro.values)
                MaestroScope(
                    maestro: maestro,
                    child: Builder(
                      builder: (ctx) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ctx.palette.deepest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(maestro.displayName,
                                style: TypographyTokens.display(size: 15)
                                    .copyWith(color: ctx.palette.goldSoft)),
                            for (final veste in VesteDellaPillola.values)
                              for (final saldo in const [0, 1000, 10000])
                                riga(veste, saldo),
                          ],
                        ),
                      ),
                    ),
                ),
            ],
          ),
        ),
      ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(() async {
      final scatola =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await scatola.toImage(pixelRatio: 2.0);
      final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
      final dove = File('docs/preview/pillola_due_vesti.png');
      dove.writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('anteprima: ${dove.path}');
    });
  });
}
