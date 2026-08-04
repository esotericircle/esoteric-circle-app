import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'EMBLEMA SI ACCENDE, E SI VEDE CHE SI ACCENDE.
///
/// **I numeri che hanno fatto nascere questo file, misurati.** La scena agiva
/// solo sulla saturazione, e la saturazione dell'arte del busto arriva al
/// massimo a 0,4263: fra il 57 per cento e il 100 per cento ballavano 0,17,
/// troppo poco perche' un occhio distingua due fotogrammi. E la curva lineare
/// consumava quel poco subito, quindi il grigio, che e' il segnale, durava un
/// istante.
///
/// **La misura non e' a occhio.** Una differenza di peso fra due file non prova
/// che due immagini si distinguano: prova solo che sono due file diversi, ed e'
/// l'errore gia' visto sulle due anteprime da 105.481 byte. Qui si contano i
/// pixel.
void main() {
  const natal = NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');

  /// LE SOGLIE, e da dove vengono.
  ///
  /// A colorazione piena la saturazione media del busto misura 0,4263 e la
  /// luminosita' 0,3932. Le soglie stanno nei vuoti fra i tre istanti, non al
  /// filo di nessuno.
  const sogliaGrigio = 0.06; // sopra questa non e' piu' grigio
  const sogliaSpento = 0.25; // sopra questa non e' piu' spento
  const sogliaAcceso = 0.30; // sotto questa non e' ancora acceso

  /// Il fondo cosmico piu' SCURO dei tre, che e' il caso peggiore per il
  /// contrasto: se il Maestro si legge su questo, si legge su tutti.
  double luminanza(Color c) =>
      (0.2126 * ((c.r * 255).round()) +
          0.7152 * ((c.g * 255).round()) +
          0.0722 * ((c.b * 255).round())) /
      255.0;

  Widget host(Widget figlio, {bool fermo = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: fermo),
              child: MaestroScope(
                child: Scaffold(
                  backgroundColor: ColorTokens.caligoDeepest,
                  body: figlio,
                ),
              ),
            ),
          ),
        ),
      );

  /// Saturazione e luminosita' medie dei pixel del busto, contate davvero.
  Future<({double sat, double lum})> misura(
      WidgetTester tester, GlobalKey radice) async {
    var sat = 0.0, lum = 0.0;
    var n = 0;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final d = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      for (var i = 0; i < d.lengthInBytes; i += 4) {
        final r = d.getUint8(i), g = d.getUint8(i + 1), b = d.getUint8(i + 2);
        if (d.getUint8(i + 3) < 250) continue;
        final mx = [r, g, b].reduce((x, y) => x > y ? x : y);
        final mn = [r, g, b].reduce((x, y) => x < y ? x : y);
        // Il nero puro attorno al busto non e' immagine: non entra nel conto.
        if (mx < 12) continue;
        sat += (mx - mn) / mx;
        lum += (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
        n++;
      }
      img.dispose();
    });
    expect(n, greaterThan(1000), reason: 'il busto non e\' stato dipinto');
    return (sat: sat / n, lum: lum / n);
  }

  Future<GlobalKey> monta(WidgetTester tester, {bool fermo = false}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final radice = GlobalKey();
    await tester.pumpWidget(host(
      Center(
        child: RepaintBoundary(
          key: radice,
          child: const ConsultoDelCieloView(
              natal: natal, maestro: Maestro.medora),
        ),
      ),
      fermo: fermo,
    ));
    await tester.pump();
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      await precacheImage(AssetImage(Maestro.medora.avatarAsset), ctx);
    });
    await tester.pump();
    return radice;
  }

  testWidgets('A zero e\' grigio E spento', (tester) async {
    final radice = await monta(tester);
    final m = await misura(tester, radice);
    expect(m.sat, lessThan(sogliaGrigio),
        reason: 'la saturazione iniziale e\' ${m.sat}, quindi non e\' grigio');
    expect(m.lum, lessThan(sogliaSpento),
        reason: 'la luminosita\' iniziale e\' ${m.lum}, quindi non e\' spento: '
            'un\'immagine che parte gia\' luminosa non sembra accendersi');
  });

  test('I tempi dichiarati sono quelli che l\'ordine chiede', () {
    // **GLI ISTANTI SONO LETTERALI, e non presi dalle costanti sotto esame.**
    // Le prime stesure pompavano `grigioPrimaDiSalire` e
    // `colorazioneDellEmblema`: accorciando la costante si accorciava anche la
    // misura, quindi la prova restava VERDE su un difetto che c'era. Una prova
    // che calcola dal numero che deve sorvegliare verifica se stessa.
    expect(TempiDellAttesa.grigioPrimaDiSalire,
        const Duration(milliseconds: 1000));
    expect(TempiDellAttesa.colorazioneDellEmblema,
        const Duration(milliseconds: 3000));
  });

  testWidgets('A 1000 millisecondi e\' ANCORA grigio', (tester) async {
    // E' la riga che rende leggibile il segnale: senza, il grigio dura un
    // istante e sembra un'immagine venuta male invece di una che si accende.
    final radice = await monta(tester);
    await tester.pump(const Duration(milliseconds: 970));
    final m = await misura(tester, radice);
    expect(m.sat, lessThan(sogliaGrigio),
        reason: 'a un secondo la saturazione e\' gia\' ${m.sat}: il grigio non '
            'dura abbastanza da essere letto');
  });

  testWidgets('A tre secondi e\' pieno, di colore E di luce', (tester) async {
    final radice = await monta(tester);
    await tester.pump(const Duration(milliseconds: 3100));
    final m = await misura(tester, radice);
    expect(m.sat, greaterThan(sogliaAcceso),
        reason: 'a tre secondi la saturazione e\' solo ${m.sat}');
    expect(m.lum, greaterThan(sogliaSpento),
        reason: 'a tre secondi la luminosita\' e\' solo ${m.lum}');
  });

  testWidgets('Arrivato pieno resta pieno, e non riparte', (tester) async {
    final radice = await monta(tester);
    await tester.pump(const Duration(milliseconds: 3100));
    final pieno = await misura(tester, radice);
    // **PRIMA SI VERIFICA CHE SIA ARRIVATO PIENO.** Senza questa riga la prova
    // confrontava uno stato rotto con un altro stato rotto: con l'accensione
    // che riparte a ogni frase, a 3100 millisecondi il timer aveva gia'
    // rimesso tutto a zero, quindi `pieno` misurava 0,0005 e il confronto con
    // `dopo` tornava vero. Due misure sbagliate uguali non sono una prova.
    expect(pieno.sat, greaterThan(sogliaAcceso),
        reason: 'non e mai arrivato pieno: ${pieno.sat}');
    // Passa una frase, poi si guarda POCO DOPO il cambio: se l'accensione
    // ripartisse, li' sarebbe ancora dentro il secondo di grigio, cioe' a
    // zero. Misurare dopo un giro intero avrebbe potuto ritrovarla piena per
    // caso, ed e' il motivo per cui la prima stesura restava verde.
    await tester.pump(TempiDellAttesa.durataBattuta);
    await tester.pump(const Duration(milliseconds: 200));
    final dopo = await misura(tester, radice);
    expect(dopo.sat, closeTo(pieno.sat, 0.01),
        reason: 'l\'emblema si e\' scolorito: da ${pieno.sat} a ${dopo.sat}');
    expect(dopo.lum, closeTo(pieno.lum, 0.01),
        reason: 'l\'emblema si e\' spento di nuovo');
  });

  testWidgets('Con Riduci Movimento parte gia\' pieno', (tester) async {
    final radice = await monta(tester, fermo: true);
    final m = await misura(tester, radice);
    expect(m.sat, greaterThan(sogliaAcceso),
        reason: 'con Riduci Movimento l\'emblema parte grigio: si spegne il '
            'moto, non l\'immagine');
    expect(m.lum, greaterThan(sogliaSpento),
        reason: 'con Riduci Movimento l\'emblema parte spento');
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'resta registrato un ticker');
  });

  testWidgets('Anche spento, il busto si stacca dal fondo', (tester) async {
    // LA SOGLIA DI CONTRASTO, e il metodo con cui e' presa.
    //
    // Rapporto di contrasto nella forma di WCAG, `(L1 + 0,05) / (L2 + 0,05)`,
    // fra la luminanza media del busto all'istante zero e quella del fondo
    // cosmico piu' SCURO dei tre, che e' il caso peggiore. La soglia e' 2,0:
    // al 45 per cento di luce il rapporto misura circa 2,4, e sotto il 30 per
    // cento scenderebbe a 1,8, cioe' il Maestro comincerebbe a sparire nel
    // fondo. Sparire sarebbe peggio del difetto da cui siamo partiti.
    const sogliaContrasto = 2.0;
    final radice = await monta(tester);
    final m = await misura(tester, radice);
    final fondo = luminanza(ColorTokens.caligoDeepest);
    final rapporto = (m.lum + 0.05) / (fondo + 0.05);
    expect(rapporto, greaterThan(sogliaContrasto),
        reason: 'il busto spento ha contrasto $rapporto sul fondo piu\' '
            'scuro: sotto $sogliaContrasto il Maestro sparisce nello sfondo');
  });
}
