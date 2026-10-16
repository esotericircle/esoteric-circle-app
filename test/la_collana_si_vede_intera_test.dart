import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/lunario/la_collana_delle_lune.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_dipinta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA COLLANA SI VEDE INTERA, COL SUO MARGINE.** Ordine FY voce FY.08, 16
/// ottobre 2026. Il fondatore: "La collana della luna è tagliata ai lati";
/// poi le pitture v2, "con l'ovale intero", e "La collana va mostrata intera
/// con il suo margine, senza tagli ai lati, e va provata con una cattura".
///
/// Due misure. (1) La pittura: sulle colonne di bordo del file non c'e'
/// argento chiaro, cioe' l'ovale sta tutto dentro l'immagine (la v1 ne aveva
/// fra 39 e 45 righe per lato). (2) A schermo: la pittura sta tutta dentro lo
/// schermo, nessun lato oltre il bordo, a 320, 360, 390 e 430 punti, e col
/// suo rapporto intero (1438 per 2576). Con `--dart-define=CATTURE_FY08=true`
/// ogni misura lascia la sua cattura in `docs/collaudo/FY/collana_v2/`.
const bool _scrivi = bool.fromEnvironment('CATTURE_FY08');

void main() {
  test('nella pittura l\'ovale sta tutto dentro: niente argento sui bordi',
      () async {
    final byte = File('assets/img/respiro_della_luna/collana/'
            'collana_nello_scrigno_spenta_v2.webp')
        .readAsBytesSync();
    final codec = await ui.instantiateImageCodec(byte);
    final img = (await codec.getNextFrame()).image;
    final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final w = img.width;
    final h = img.height;
    expect([w, h], [1438, 2576]);
    int argento(int x) {
      var n = 0;
      for (var y = 0; y < h; y++) {
        final i = (y * w + x) * 4;
        final luce = 0.299 * dati.getUint8(i) +
            0.587 * dati.getUint8(i + 1) +
            0.114 * dati.getUint8(i + 2);
        if (luce > 110) n++;
      }
      return n;
    }

    final bordi = [argento(0), argento(1), argento(w - 2), argento(w - 1)];
    expect(bordi, everyElement(0),
        reason: 'l\'ovale d\'argento esce dai bordi della pittura: righe '
            'con argento sulle colonne di bordo $bordi');
  });

  for (final larghezza in const [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('a schermo la collana sta intera, $larghezza punti',
        (tester) async {
      // Cinque perle accese, per vedere anche i ritagli sulla pittura.
      SharedPreferences.setMockInitialValues({});
      final oggi = DateTime(2026, 10, 16, 9);
      final r = IlRespiroDellaLuna();
      await r.leggi();
      final ciclo = LaCollanaDelleLune(respiro: r).cicloDi(oggi);
      SharedPreferences.setMockInitialValues({
        'respiro.giorniRespirati': jsonEncode([
          for (var i = 0; i < 5; i++)
            IlRespiroDellaLuna.data(ciclo.inizio.add(Duration(days: i))),
        ]),
      });
      final radice = GlobalKey();
      tester.view.physicalSize = Size(larghezza, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController())
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: LaCollanaDelleLuneScreen(now: oggi)),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final pittura = tester.getRect(find.byType(LaCollanaDipinta).first);
      expect(pittura.left, greaterThanOrEqualTo(-0.5),
          reason: 'la collana esce dal bordo sinistro: $pittura');
      expect(pittura.right, lessThanOrEqualTo(larghezza + 0.5),
          reason: 'la collana esce dal bordo destro: $pittura');
      expect(pittura.width / pittura.height, closeTo(1438 / 2576, 0.01),
          reason: 'la pittura non ha il suo rapporto intero: e\' deformata');
      // L'OVALE TUTTO NELLA PARTE VISIBILE. Si mostra una finestra sulla
      // pittura (righe 400-2172): l'ovale d'argento (righe 501-2071,
      // colonne 111-1325) deve starci tutto dentro, col suo margine.
      final finestra = tester.getRect(find.byKey(const Key('collana_finestra')));
      final s = pittura.width / 1438;
      final ovale = Rect.fromLTRB(pittura.left + 111 * s, pittura.top + 501 * s,
          pittura.left + 1325 * s, pittura.top + 2071 * s);
      expect(ovale.top, greaterThan(finestra.top),
          reason: 'l\'ovale e\' tagliato in alto: $ovale in $finestra');
      expect(ovale.bottom, lessThan(finestra.bottom),
          reason: 'l\'ovale e\' tagliato in basso: $ovale in $finestra');
      expect(ovale.left, greaterThan(finestra.left));
      expect(ovale.right, lessThan(finestra.right));
      expect(finestra.left, greaterThanOrEqualTo(-0.5));
      expect(finestra.right, lessThanOrEqualTo(larghezza + 0.5));
      // ignore: avoid_print
      print('FY.08, $larghezza punti: ovale largo '
          '${ovale.width.toStringAsFixed(0)} punti a schermo');

      if (_scrivi) {
        await tester.runAsync(() async {
          for (final e in find.byType(Image).evaluate()) {
            try {
              await precacheImage((e.widget as Image).image, e);
            } catch (_) {
              // Un'immagine che manca la gestisce gia' l'errorBuilder.
            }
          }
        });
        await tester.pump(const Duration(milliseconds: 200));
        await tester.runAsync(() async {
          final rb = radice.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final img = await rb.toImage(pixelRatio: 1.0);
          final png = await img.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('docs/collaudo/FY/collana_v2');
          if (!dir.existsSync()) dir.createSync(recursive: true);
          File('${dir.path}/fy08_collana_intera_${larghezza.toInt()}.png')
              .writeAsBytesSync(png!.buffer.asUint8List());
          img.dispose();
        });
      }
    });
  }
}
