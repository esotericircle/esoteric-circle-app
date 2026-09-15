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

  /// I TRE MOMENTI DELLA VESTE MISTA: riposo, oro all'atterraggio, ritorno.
  /// Coda all'ordine AI, decisione di Mauro del 17 agosto.
  testWidgets('i tre momenti della veste mista', (tester) async {
    // ignore: invalid_use_of_visible_for_testing_member, questo strumento gira sotto flutter test
      SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(720, 560);
    addTearDown(tester.view.reset);
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(120);
    final chiave = GlobalKey();
    Widget scena(String etichetta, {required bool accesa}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(etichetta,
                  style: TypographyTokens.corpo()
                      .copyWith(color: const Color(0xFFB7B0A0))),
              // I momenti si mostrano con le due vesti pure: il riposo e il
              // ritorno sono il velo, l'atterraggio e' l'oro. La meccanica
              // vera del passaggio vive nel componente ed e' provata da
              // test/la_pillola_si_accende_quando_arrivano_test.dart.
              SegnoDelBorsellino(
                  veste: accesa
                      ? VesteDellaPillola.oro
                      : VesteDellaPillola.velo),
            ],
          ),
        );
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
          key: chiave,
          child: Container(
            color: const Color(0xFF0B0D1A),
            padding: const EdgeInsets.all(24),
            child: ChangeNotifierProvider<QuestionAllowance>.value(
              value: borsa,
              child: MaestroScope(
                maestro: Maestro.medora,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    scena('1. riposo (velo)', accesa: false),
                    scena('2. gli Eos atterrano (oro)', accesa: true),
                    scena('3. ritorno al velo', accesa: false),
                  ],
                ),
              ),
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
      File('docs/preview/pillola_tre_momenti.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('anteprima: docs/preview/pillola_tre_momenti.png');
    });
  });

  testWidgets('le due vesti a tre saldi', (tester) async {
    // ignore: invalid_use_of_visible_for_testing_member, questo strumento gira sotto flutter test
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
