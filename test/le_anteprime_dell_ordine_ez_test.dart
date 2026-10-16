// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/confronto_del_cielo_screen.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DELL'ORDINE EZ, prima e dopo.** A 360 per 797 punti logici
/// col rapporto di pixel 3 (regola R12), catturate dentro `tester.runAsync`
/// coi `pump`. Si generano con `--dart-define=STATO=prima` sul codice di
/// partenza (983a9cfc) e con `STATO=dopo` sul codice dell'ordine, in
/// `docs/preview/prima_dopo/`.
///
/// **La tendina non disegna icone** (premessa Q2): le icone del profilo si
/// guardano nella vetrina, nel tuo Cerchio, nel profilo e nella scheda
/// dell'amico, le quattro schermate che le mostrano.
const _stato = String.fromEnvironment('STATO');

/// Quattro amici, uno per famiglia d'icona: il difetto dell'ordine EZ voce 01
/// si vede su tutte e quattro.
class _PortaConLeQuattroFamiglie extends PortaFintaDelCerchioSociale {
  /// L'icona del profilo di chi guarda: un Arcano, il caso piu' alto.
  static const String iconaMia = 'arcano:1';

  static Map<String, Object?> _amico(
          String uid, String nome, String icona, String segno) =>
      {
        ...PortaFintaDelCerchioSociale.amico,
        'uid': uid,
        'nome': nome,
        'icona': icona,
        'segno': segno,
      };

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null) return e;
    if (porta == 'ilMioCerchio') {
      return EsitoSociale(dati: {
        ...e.dati,
        'amici': [
          _amico('u-1', 'Stella Lieve', 'segno:4', 'leo'),
          _amico('u-2', 'Eco Corvo Mite', 'animale:6', 'scorpio'),
          _amico('u-3', 'Luce del Mago', 'arcano:1', 'gemini'),
          _amico('u-4', 'Voce Saggia', 'archetipo:2', 'virgo'),
        ],
      });
    }
    if (porta == 'ilMioProfiloNelCerchio') {
      return EsitoSociale(dati: {...e.dati, 'icona': iconaMia});
    }
    return e;
  }
}

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
      print('EZ ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
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

  Future<IlCerchioSociale> monta(WidgetTester tester, Widget schermata,
      {BirthIdentity? identita, PortaFintaDelCerchioSociale? porta}) async {
    silenzia();
    misura(tester);
    final finta = porta ?? _PortaConLeQuattroFamiglie();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          // Una nascita adulta, salvo dove la prova la sceglie: senza data il
          // Cerchio sociale resta chiuso (ordine EZ voce 04).
          identita:
              identita ?? BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)),
          oggi: DateTime(2026, 10, 4));
      await sociale.caricaIlCerchio();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
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
    return sociale;
  }

  Future<void> scorriFino(WidgetTester tester, Finder cosa,
      [double passo = 300]) async {
    await tester.scrollUntilVisible(cosa, passo,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
  }

  testWidgets('EZ.01: la vetrina delle icone, famiglia per famiglia',
      (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const ProfiloNelCerchioScreen());
    await scatta(tester, 'ez01_profilo_con_un_arcano');
    await tester.tap(find.byKey(const Key('profilo_icona')));
    await passa(tester, 8);
    await precarica(tester);
    await scatta(tester, 'ez01_vetrina_i_segni');
    final foglio = find.byType(Scrollable).last;
    for (final (f, nome) in const [
      (FamigliaDelleIcone.animale, 'ez01_vetrina_gli_animali'),
      // LAPIDE, ordine FA voce 01: qui stava la vetrina degli Arcani, usciti
      // dalle icone del profilo; la cattura ez01_vetrina_gli_arcani resta in
      // docs come prova dell'ordine EZ.
      (FamigliaDelleIcone.archetipo, 'ez01_vetrina_gli_archetipi'),
    ]) {
      await tester.scrollUntilVisible(find.text(f.titolo.toUpperCase()), 200,
          scrollable: foglio);
      await tester.drag(foglio, const Offset(0, -160));
      await passa(tester, 4);
      await scatta(tester, nome);
    }
  });

  testWidgets('EZ.01: il tuo Cerchio con un amico per famiglia',
      (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const IlTuoCerchioScreen());
    await scorriFino(tester, find.byKey(const Key('persona_u-4')), 200);
    // Il primo dei quattro in alto: si vedono tutte e quattro le famiglie.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 420));
    await passa(tester, 4);
    await scatta(tester, 'ez01_il_tuo_cerchio_quattro_famiglie');
  });

  testWidgets('EZ.01: la scheda di un amico con un Arcano', (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(
        Map<String, Object?>.of(PortaFintaDelCerchioSociale.amico)
          ..['icona'] = 'arcano:1');
    await monta(tester, SchedaDellAmicoScreen(amico: amico));
    await scatta(tester, 'ez01_scheda_amico_arcano');
  });

  testWidgets('EZ.02: il confronto del cielo, due giorni di fila',
      (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    for (final (giorno, nome) in [
      (DateTime(2026, 10, 4), 'ez02_confronto_4_ottobre'),
      (DateTime(2026, 10, 5), 'ez02_confronto_5_ottobre'),
    ]) {
      await monta(
          tester,
          ConfrontoDelCieloScreen(
              key: ValueKey(nome),
              amico: amico,
              mioSegno: Zodiac.leo,
              oggi: giorno));
      await scatta(tester, nome);
    }
  });

  testWidgets('EZ.04: il tuo Cerchio a tredici anni', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const IlTuoCerchioScreen(),
        identita: BirthIdentity(birthMoment: DateTime(2013, 3, 2, 10)));
    await scatta(tester, 'ez04_il_tuo_cerchio_a_tredici_anni');
  });

  testWidgets('EZ.05: il regalo degli Eos nella scheda dell\'amico',
      (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(tester, SchedaDellAmicoScreen(amico: amico));
    await scorriFino(
        tester,
        find.byKey(const Key(_stato == 'prima'
            ? 'amico_regala_eos'
            : 'amico_regala_eos_dietro_il_velo')));
    await scatta(tester, 'ez05_regala_eos');
  });

  testWidgets('EZ.06: la riga degli amici offline nei Piani', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const PricingScreen(isDemo: true));
    await scorriFino(tester, find.byKey(const Key('pricing_table')), 400);
    final riga = find.descendant(
        of: find.byKey(const Key('pricing_table')),
        matching: find.text('Oroscopo per gli amici'));
    await tester.ensureVisible(riga);
    // La tabella scorre in orizzontale: la colonna dell'Illuminato e' l'ultima.
    final orizzontale = tester.state<ScrollableState>(
        find.ancestor(of: riga, matching: find.byType(Scrollable)).first);
    orizzontale.position.jumpTo(orizzontale.position.maxScrollExtent);
    await passa(tester, 4);
    await scatta(tester, 'ez06_piani_amici_offline');
  });

  testWidgets('EZ.08: i segni da mandare e un segno ricevuto', (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(tester, SchedaDellAmicoScreen(amico: amico));
    await scorriFino(tester, find.byKey(const Key('dono_sigillo')));
    await scatta(tester, 'ez08_segni_da_mandare');
    await monta(tester, const IlTuoCerchioScreen(key: ValueKey('ricevuto')));
    await scorriFino(tester, find.byKey(const Key('segno_s1')));
    await scatta(tester, 'ez08_segno_ricevuto');
  });
}
