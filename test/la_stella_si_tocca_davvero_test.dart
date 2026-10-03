import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA STELLA SI TOCCA DAVVERO, A SCHERMO MONTATO.** Ordine CQ voce 6.05,
/// 4 settembre 2026.
///
/// **Parole del fondatore, ed e' la seconda volta**: *"ancora i punti delle
/// stelle da cliccare sono sotto il testo e non si possono cliccare per
/// rivelare la costellazione."*
///
/// **PERCHE' LA GUARDIA DELLA VOCE CQ 1.07 LO AVEVA DICHIARATO CHIUSO.**
/// Quella misura `doveVaLaStella`, cioe' **la funzione matematica** che decide
/// la quota della stella: 693 posizioni calcolate a ogni inclinazione, zero
/// sotto il testo. La funzione e' giusta e resta giusta. **Non monta mai la
/// schermata**, quindi non puo' vedere cosa c'e' sopra la stella una volta
/// disegnata: nella pila il blocco del testo viene dopo la costellazione, e
/// nella pila chi viene dopo sta sopra.
///
/// E' la stessa distinzione che l'ordine CQ ha gia' incontrato due volte oggi:
/// **una guardia che legge un calcolo vede il calcolo, non cosa si vede a
/// video.**
///
/// **La grandezza nuova**: si monta il Sigillo, si prende il rettangolo vero
/// di ogni stella e quello vero del blocco di testo, e si guarda se si
/// sovrappongono. Poi si tocca la stella e si pretende che il conto salga.
void main() {
  final quando = DateTime(2026, 7, 13, 22, 40);

  void silenzia(WidgetTester tester) {
    final m = tester.binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> monta(WidgetTester tester) async {
    silenzia(tester);
    // **LA FINESTRA E' QUELLA DI UN TELEFONO.** Con la finestra di prova,
    // 800 per 600, la fascia di cielo e il blocco di testo cadono altrove e
    // la misura non dice niente di cio' che la persona vede.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: DreamRiteScreen(now: quando),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Porta il rito dalla nebbia al cielo, che e' dove vivono le stelle.
  Future<void> apriIlCielo(WidgetTester tester) async {
    final pulsante = find.text('Dirada la nebbia');
    if (pulsante.evaluate().isNotEmpty) {
      await tester.tap(pulsante, warnIfMissed: false);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
  }

  testWidgets('nessuna stella finisce sotto il blocco del testo', (tester) async {
    await monta(tester);
    await apriIlCielo(tester);

    final testo = find.byKey(const Key('dream_rite'));
    expect(testo, findsOneWidget,
        reason: 'il blocco del testo non e a schermo: la prova non puo dire '
            'se copre qualcosa');
    final rTesto = tester.getRect(testo);

    final coperte = <String>[];
    var guardate = 0;
    for (var i = 0; i < 12; i++) {
      final stella = find.byKey(Key('dream_star_$i'));
      if (stella.evaluate().isEmpty) continue;
      guardate++;
      final r = tester.getRect(stella);
      // **SI CONFRONTANO I RETTANGOLI DIPINTI**, non le quote calcolate: e'
      // esattamente cio' che la guardia della voce 1.07 non poteva fare.
      // ignore: avoid_print
      print('  stella $i: ${r.width.toStringAsFixed(0)} per '
          '${r.height.toStringAsFixed(0)} punti, in alto a '
          '${r.top.toStringAsFixed(0)}');
      if (r.overlaps(rTesto)) {
        coperte.add('stella $i in ${r.top.toStringAsFixed(0)}-'
            '${r.bottom.toStringAsFixed(0)}, il testo comincia a '
            '${rTesto.top.toStringAsFixed(0)}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.05: stelle a schermo $guardate, coperte dal blocco '
        'del testo ${coperte.length}; il testo comincia a '
        '${rTesto.top.toStringAsFixed(0)} su ${tester.getRect(find.byType(MaterialApp)).height.toStringAsFixed(0)} punti');
    cardinaleMinimo(guardate, 3,
        cosa: 'stelle davvero disegnate a schermo',
        perche: 'Senza stelle a schermo la prova direbbe che nessuna e '
            'coperta per non averne trovata nessuna, ed e la prima specie di '
            'cecita.');
    expect(coperte, isEmpty,
        reason: 'queste stelle stanno sotto il blocco del testo, che nella '
            'pila viene dopo e quindi mangia il tocco:'
            '${String.fromCharCode(10)}${coperte.join(String.fromCharCode(10))}');
  });

  testWidgets('e toccando una stella il conto sale', (tester) async {
    await monta(tester);
    await apriIlCielo(tester);

    final prima = find.byKey(const Key('dream_conteggio'));
    expect(prima, findsOneWidget,
        reason: 'il conto delle stelle unite non e a schermo');
    final testoPrima = tester.widget<Text>(prima).data ?? '';

    // Si tocca la stella che chiama, come la tocca una persona.
    var toccata = false;
    for (var i = 0; i < 12 && !toccata; i++) {
      final stella = find.byKey(Key('dream_star_$i'));
      if (stella.evaluate().isEmpty) continue;
      await tester.tap(stella, warnIfMissed: false);
      for (var g = 0; g < 6; g++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      final dopo = tester.widget<Text>(prima).data ?? '';
      if (dopo != testoPrima) toccata = true;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.05: prima "$testoPrima", dopo il tocco '
        '"${tester.widget<Text>(prima).data}"');
    expect(toccata, isTrue,
        reason: 'toccando le stelle il conto non cambia mai: il tocco non '
            'arriva alla stella, e la costellazione non si puo unire');
  });

  test('e le stelle vengono dopo il testo nella pila', () {
    // **NELLA PILA CHI VIENE DOPO STA SOPRA**, e questa e' la cura di questa
    // voce: non insegue una causa che non ho misurato, rende il tocco della
    // stella prioritario per costruzione. Se i due si sovrappongono, per
    // qualunque ragione, vince la stella.
    final schermata =
        File('lib/features/rituals/dream_rite_screen.dart').readAsStringSync();
    final doveTesto = schermata.indexOf("key: const Key('dream_rite')");
    final doveStelle = schermata.indexOf('..._costellazione(w, h)');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.05: nella pila il testo sta al carattere '
        '$doveTesto, le stelle al $doveStelle');
    expect(doveTesto, greaterThanOrEqualTo(0),
        reason: 'il blocco del testo non ha piu la sua chiave');
    expect(doveStelle, greaterThan(doveTesto),
        reason: 'le stelle si montano PRIMA del blocco del testo, quindi gli '
            'stanno sotto: qualunque cosa il testo copra, copre anche il '
            'tocco della stella');
  });
}
