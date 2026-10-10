// LE ANTEPRIME DELL'ORDINE FG, il Real Time Cosmo.
//
// Sul telefono di 360 per 797 punti con rapporto di pixel 3 (regola R6),
// catture dentro tester.runAsync e solo pump (regola R10). Le immagini si
// scrivono in docs/preview/FG/ solo con AGGIORNA_ANTEPRIME=1; senza, la prova
// gira lo stesso e misura.
//
// L'adesso e' l'8 ottobre 2026 alle 20 UTC; la persona e' nata a Napoli il 14
// maggio 1988 alle 8:40 ora italiana, segno del Toro. Nessuna posizione
// concessa: il cielo di adesso e' calcolato sul luogo di nascita e lo dice.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_riavvolgimento.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:esoteric_circle/features/real_time_cosmo/pittore_del_cielo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/real_time_cosmo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final radice = GlobalKey();
final scrivi = Platform.environment['AGGIORNA_ANTEPRIME'] == '1';

void finestra(WidgetTester tester) {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1080, 2391);
  addTearDown(tester.view.reset);
}

void silenzia() {
  final messaggero =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messaggero.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (_) async => null);
  for (final c in const [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
  ]) {
    messaggero.setMockStreamHandler(
        EventChannel(c), MockStreamHandler.inline(onListen: (_, __) {}));
  }
}

Future<void> scatta(WidgetTester tester, String nome) async {
  if (!scrivi) return;
  await tester.runAsync(() async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 3.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/preview/FG');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

final DateTime adesso = DateTime.utc(2026, 10, 8, 20);

ProfileController profilo() => ProfileController(
      identity: BirthIdentity(
        birthMoment: DateTime(1988, 5, 14, 8, 40),
        hasBirthTime: true,
        birthPlace: const BirthPlace(
          city: 'Napoli',
          latitude: 40.85,
          longitude: 14.27,
          timeZoneId: 'Europe/Rome',
          utcOffsetMinutes: 60,
        ),
      ),
    );

Future<void> monta(WidgetTester tester, Widget figlio) async {
  silenzia();
  SharedPreferences.setMockInitialValues({});
  finestra(tester);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<ProfileController>(create: (_) => profilo())
    ],
    child: RepaintBoundary(
      key: radice,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(maestro: Maestro.medora, child: figlio),
      ),
    ),
  ));
}

/// Lascia caricare catalogo e veli (asset veri, decodifica vera) e poi
/// fa girare i fotogrammi.
Future<void> carica(WidgetTester tester) async {
  final cielo = find.byKey(const Key('real_time_cosmo_cielo'));
  for (var i = 0; i < 60 && cielo.evaluate().isEmpty; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(cielo, findsOneWidget, reason: 'il cielo non si e\' caricato');
}

Future<void> passa(WidgetTester tester, int volte,
    [Duration passo = const Duration(milliseconds: 100)]) async {
  for (var i = 0; i < volte; i++) {
    await tester.pump(passo);
  }
}

CieloRealeScreen cielo(ModoDelCielo modo) => CieloRealeScreen(
      modo: modo,
      orologio: () => adesso,
      posizione: const DisabledSkyLocation(),
    );

/// Il nome della cattura del menu utente: col suffisso _prima quando lo
/// script delle immagini la scatta con la voce tolta (FG_PRIMA=1).
final String _menuUtente = Platform.environment['FG_PRIMA'] == '1'
    ? 'fg_08_il_menu_utente_in_fondo_prima'
    : 'fg_08_il_menu_utente_in_fondo_dopo';

void main() {
  testWidgets('FG.6: la voce nel menu utente, in fondo all\'elenco',
      (tester) async {
    silenzia();
    finestra(tester);
    SharedPreferences.setMockInitialValues(
        {'onboarding.done': true, 'santuario.greeted': true});
    await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: EsotericCircleApp(
            conIntro: false, services: AppServices.offline())));
    await passa(tester, 12, const Duration(milliseconds: 120));
    await tester.tap(find.byKey(const Key('barra_volto')).first,
        warnIfMissed: false);
    await passa(tester, 10, const Duration(milliseconds: 120));
    await tester.drag(
        find.byKey(const Key('account_list')), const Offset(0, -3000));
    await passa(tester, 10, const Duration(milliseconds: 120));
    if (Platform.environment['FG_PRIMA'] != '1') {
      expect(find.byKey(const Key('account_real_time_cosmo')), findsOneWidget);
    }
    await scatta(tester, _menuUtente);
  });

  testWidgets('FG.6: il menu temporaneo con le tre scelte', (tester) async {
    await monta(tester, const RealTimeCosmoScreen());
    await passa(tester, 5);
    expect(find.byKey(const Key('real_time_cosmo_adesso')), findsOneWidget);
    expect(find.byKey(const Key('real_time_cosmo_nascita')), findsOneWidget);
    expect(find.byKey(const Key('real_time_cosmo_ritorno')), findsOneWidget);
    await scatta(tester, 'fg_01_il_menu_delle_tre_prove');
  });

  testWidgets('FG.2: il cielo di adesso, verso sud', (tester) async {
    await monta(tester, cielo(ModoDelCielo.adesso));
    await carica(tester);
    await passa(tester, 30);
    expect(PittoreDelCielo.chiamateDelleStelleAllUltimoFotogramma, 1);
    expect(find.textContaining('Bussola non disponibile'), findsOneWidget);
    expect(find.textContaining('Cielo calcolato su Napoli'), findsOneWidget);
    await scatta(tester, 'fg_02_il_cielo_di_adesso_a_sud');
  });

  testWidgets('FG.2: il pizzico e il dito, verso est col Toro', (tester) async {
    await monta(tester, cielo(ModoDelCielo.adesso));
    await carica(tester);
    await passa(tester, 25);
    // Verso est: 90 gradi a sinistra del sud col dito.
    final centro =
        tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
    for (var i = 0; i < 10; i++) {
      await tester.dragFrom(centro, const Offset(45, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await passa(tester, 12);
    await scatta(tester, 'fg_03_il_cielo_verso_est');
  });

  testWidgets('FG.3: il cielo della nascita', (tester) async {
    await monta(tester, cielo(ModoDelCielo.nascita));
    await carica(tester);
    await passa(tester, 20);
    await scatta(tester, 'fg_04_il_cielo_della_nascita');
  });

  testWidgets('FG.3: il ritorno, l\'eta\', la corsa e l\'arrivo',
      (tester) async {
    await monta(tester, cielo(ModoDelCielo.ritorno));
    await carica(tester);
    await passa(tester, 6);
    expect(find.text('38'), findsOneWidget);
    await scatta(tester, 'fg_05_il_ritorno_l_eta');
    await passa(tester, 30);
    expect(find.text('STO TORNANDO INDIETRO NEL TEMPO'), findsOneWidget);
    await scatta(tester, 'fg_06_il_ritorno_la_corsa');
    // Lapide: fino all'ordine FH la corsa arrivava alla nascita in sette
    // secondi, la frase era "ALLA TUA NASCITA" e il tetto 169 istanti. Dalla
    // parte 8 FH ci sono i due tempi, sette secondi di corsa e otto di
    // rallentamento, e la frase porta la marca del genere: qui la forma non e'
    // scelta, e parla neutro.
    await passa(tester, 140);
    expect(
        find.text('QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI VENUTO AL MONDO'),
        findsOneWidget);
    await scatta(tester, 'fg_07_il_ritorno_l_arrivo');
    // Il tetto della voce 3.3 sui due tempi, piu' il cielo della nascita.
    expect(
        MisureDelCosmo.istantiCalcolatiNelRitorno,
        lessThanOrEqualTo(
            ((kDurataDelRiavvolgimento + kDurataDelRallentamento) *
                        kIstantiAlSecondo)
                    .ceil() +
                1));
  });
}
