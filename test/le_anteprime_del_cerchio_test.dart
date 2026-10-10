// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/confronto_del_cielo_screen.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_richiesta_di_legame.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DEL CERCHIO SOCIALE, ordine EY.** A 360 per 797 punti
/// logici col rapporto di pixel 3, la misura del telefono del fondatore
/// (regola R12), catturate dentro `tester.runAsync` coi `pump`.
///
/// Si generano con `--dart-define=STATO=prima` oppure `dopo`, in
/// `docs/preview/prima_dopo/`. **La "prima" esiste solo per le schermate che
/// c'erano gia'** (il passo del nome dell'onboarding e il menu' account), e
/// si fa rieseguendo questa prova sul codice di partenza (784dd20b) in una
/// copia a parte: le schermate nuove del Cerchio non hanno un prima.
const _stato = String.fromEnvironment('STATO');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  void misura(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
  }

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('EY ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> precarica(WidgetTester tester) async {
    await tester.runAsync(() async {
      final ctx = radice.currentContext!;
      for (final f in FamigliaDelleIcone.values) {
        for (final i in IconaDelProfilo.di(f)) {
          await precacheImage(AssetImage(i.asset), ctx);
        }
      }
    });
    await passa(tester, 3);
  }

  Future<PortaFintaDelCerchioSociale> montaLoSociale(
      WidgetTester tester, Widget schermata,
      {PortaFintaDelCerchioSociale? porta}) async {
    misura(tester);
    final finta = porta ?? PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      // Una nascita adulta: senza data il Cerchio sociale resta chiuso
      // (ordine EZ voce 04, i quattordici anni).
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: figlio!),
          ),
          home: schermata,
        ),
      ),
    ));
    await passa(tester);
    await precarica(tester);
    return finta;
  }

  testWidgets('EY.01: il passo del nome dell\'onboarding', (tester) async {
    if (_stato.isEmpty) return;
    silenzia();
    misura(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: EsotericCircleApp(
            conIntro: false, services: AppServices.offline())));
    await passa(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('onboarding_continue')));
      await passa(tester, 6);
    }
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Giulia');
    await passa(tester, 6);
    tester.testTextInput.hide();
    await passa(tester, 4);
    await scatta(tester, 'ey01_onboarding_nome_nel_cerchio');
  });

  testWidgets('EY: il menu\' account con la voce del Cerchio', (tester) async {
    if (_stato.isEmpty) return;
    silenzia();
    misura(tester);
    SharedPreferences.setMockInitialValues(
        {'onboarding.done': true, 'santuario.greeted': true});
    await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: EsotericCircleApp(
            conIntro: false, services: AppServices.offline())));
    await passa(tester, 12);
    await tester.tap(find.byKey(const Key('barra_volto')).first,
        warnIfMissed: false);
    await passa(tester, 10);
    await scatta(tester, 'ey_menu_account');
  });

  testWidgets('EY.03, EY.05, EY.10, EY.11: il tuo Cerchio', (tester) async {
    if (_stato != 'dopo') return;
    await montaLoSociale(tester, const IlTuoCerchioScreen());
    await scatta(tester, 'ey05_il_tuo_cerchio_semaforini');
    await tester.scrollUntilVisible(find.byKey(const Key('segno_s1')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'ey11_segno_ricevuto_risposte_e_reazioni');
  });

  testWidgets('EY.03: il tuo nome nel Cerchio e la vetrina delle icone',
      (tester) async {
    if (_stato != 'dopo') return;
    await montaLoSociale(tester, const ProfiloNelCerchioScreen());
    await scatta(tester, 'ey03_profilo_nel_cerchio');
    await tester.scrollUntilVisible(find.byKey(const Key('bloccata_u-x')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'ey03_profilo_bloccati_e_visibilita');
    await tester.scrollUntilVisible(
        find.byKey(const Key('profilo_icona')), -300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('profilo_icona')));
    await passa(tester, 8);
    await precarica(tester);
    await scatta(tester, 'ey03_vetrina_delle_icone');
  });

  testWidgets('EY.08: la tendina dell\'indicatore online', (tester) async {
    if (_stato != 'dopo') return;
    await montaLoSociale(
        tester,
        Builder(
            builder: (c) => Scaffold(
                backgroundColor: const Color(0xFF0B0A1A),
                body: Center(
                    child: TextButton(
                        onPressed: () => apriLaTendinaDelCerchio(c),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    await passa(tester, 10);
    await precarica(tester);
    await scatta(tester, 'ey08_la_tendina_del_cerchio');
  });

  testWidgets('EY.13: il confronto del cielo', (tester) async {
    if (_stato != 'dopo') return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await montaLoSociale(
        tester,
        ConfrontoDelCieloScreen(
            amico: amico, mioSegno: Zodiac.leo, oggi: DateTime(2026, 10, 4)));
    await scatta(tester, 'ey13_confronto_del_cielo');
    await tester.scrollUntilVisible(
        find.byKey(const Key('confronto_fonti_e_metodo')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('confronto_fonti_e_metodo')));
    await passa(tester, 6);
    await scatta(tester, 'ey13_confronto_fonti_e_metodo');
  });

  testWidgets('EY.10, EY.12, EY.14: la scheda dell\'amico', (tester) async {
    if (_stato != 'dopo') return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await montaLoSociale(tester, SchedaDellAmicoScreen(amico: amico));
    await scatta(tester, 'ey14_scheda_amico_glifo');
    await tester.scrollUntilVisible(find.byKey(const Key('dono_sigillo')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'ey10_ey12_segni_e_doni');
  });

  testWidgets('EY.04: chiama nel tuo Cerchio, il codice, la richiesta',
      (tester) async {
    if (_stato != 'dopo') return;
    await montaLoSociale(tester, const InvitaNelCerchioScreen());
    await scatta(tester, 'ey04_chiama_nel_tuo_cerchio');
    await tester.tap(find.byKey(const Key('invita_mostra')));
    await passa(tester, 10);
    await scatta(tester, 'ey04_il_mio_codice_da_inquadrare');
  });

  testWidgets('EY.04: la richiesta di legame', (tester) async {
    if (_stato != 'dopo') return;
    await montaLoSociale(
        tester,
        Builder(
            builder: (c) => Scaffold(
                backgroundColor: const Color(0xFF0B0A1A),
                body: Center(
                    child: TextButton(
                        onPressed: () =>
                            mostraLaRichiestaDiLegame(c, 'AB12CD34'),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    await passa(tester, 10);
    await scatta(tester, 'ey04_richiesta_di_legame');
  });
}
