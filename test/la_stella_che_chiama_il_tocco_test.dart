import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/stelle_da_unire.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA STELLA CHE ASPETTA IL TOCCO E' L'UNICA ACCESA, ordine L voce 3b.
///
/// Misurata SUI PIXEL, non sulle intenzioni: si rende il componente su fondo
/// scuro, si campiona la luminanza attorno alla stella che chiama e attorno
/// alle stelle che aspettano il loro turno, e la prima deve valere almeno
/// [StelleDaUnire.kRisaltoMinimo] volte le altre. Chi guarda non deve
/// indovinare dove toccare.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const figura = FiguraDaUnire(punti: [
    PuntoDaUnire('prima', Offset(0.2, 0.3)),
    PuntoDaUnire('seconda', Offset(0.8, 0.3)),
    PuntoDaUnire('terza', Offset(0.5, 0.8)),
  ], fili: [
    (0, 1),
    (1, 2),
  ]);

  testWidgets('la stella che chiama e\' visibilmente piu\' luminosa',
      (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final radice = GlobalKey();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: radice,
        child: Container(
          color: const Color(0xFF14060A),
          child: StelleDaUnire(
            figura: figura,
            palette: palette,
            mappa: (p) => Offset(p.dx * 400, p.dy * 400),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    // Si tocca la prima: adesso chiama la SECONDA, e la terza aspetta.
    await tester.tap(find.byKey(const Key('stella_0')));
    // Al culmine della pulsazione, cosi' si misura il momento vero.
    await tester.pump(const Duration(milliseconds: 800));

    // Immagine e byte si leggono DENTRO runAsync, come ogni prova a pixel
    // di questo repo: fuori, l'attesa del motore non si completa mai.
    late ui.Image immagine;
    late ByteData dati;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      immagine = await rb.toImage();
      dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });

    double luminanzaAttorno(Offset centro) {
      var somma = 0.0;
      var quanti = 0;
      for (var dy = -14; dy <= 14; dy += 2) {
        for (var dx = -14; dx <= 14; dx += 2) {
          final x = (centro.dx + dx).round();
          final y = (centro.dy + dy).round();
          if (x < 0 || y < 0 || x >= immagine.width || y >= immagine.height) {
            continue;
          }
          final i = (y * immagine.width + x) * 4;
          final r = dati.getUint8(i);
          final g = dati.getUint8(i + 1);
          final b = dati.getUint8(i + 2);
          somma += 0.2126 * r + 0.7152 * g + 0.0722 * b;
          quanti++;
        }
      }
      return somma / quanti;
    }

    final fondo = luminanzaAttorno(const Offset(200, 120));
    final chiama = luminanzaAttorno(const Offset(0.8 * 400, 0.3 * 400));
    final aspetta = luminanzaAttorno(const Offset(0.5 * 400, 0.8 * 400));
    // ignore: avoid_print
    print('luminanze: fondo ${fondo.toStringAsFixed(1)}, chiama '
        '${chiama.toStringAsFixed(1)}, in attesa '
        '${aspetta.toStringAsFixed(1)}');

    expect(chiama - fondo,
        greaterThan((aspetta - fondo) * StelleDaUnire.kRisaltoMinimo),
        reason: 'La stella che chiama il tocco non spicca: il suo bagliore '
            'sopra il fondo vale meno di '
            '${StelleDaUnire.kRisaltoMinimo} volte quello delle stelle in '
            'attesa, e chi guarda deve indovinare dove toccare.');
    expect(chiama - fondo, greaterThan(20),
        reason: 'La stella che chiama non si stacca nemmeno dal fondo: '
            'non e\' accesa.');
  });

  testWidgets(
      'con Riduci Movimento la stella che chiama resta accesa e '
      'ferma', (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final radice = GlobalKey();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: RepaintBoundary(
        key: radice,
        child: Container(
          color: const Color(0xFF14060A),
          child: StelleDaUnire(
            figura: figura,
            palette: palette,
            mappa: (p) => Offset(p.dx * 400, p.dy * 400),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    late ByteData bytesPrima;
    late ByteData bytesDopo;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      bytesPrima = (await (await rb.toImage())
          .toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });
    await tester.pump(const Duration(milliseconds: 700));
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      bytesDopo = (await (await rb.toImage())
          .toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });
    var diversi = 0;
    for (var i = 0; i < bytesPrima.lengthInBytes; i += 16) {
      if (bytesPrima.getUint8(i) != bytesDopo.getUint8(i)) diversi++;
    }
    expect(diversi, 0,
        reason: 'Con Riduci Movimento la scena pulsa ancora: lo stato deve '
            'essere acceso e fermo.');
  });
}
