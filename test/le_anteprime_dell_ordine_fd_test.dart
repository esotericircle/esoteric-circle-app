// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/la_rubrica_del_telefono.dart';
import 'package:esoteric_circle/core/condivisione/la_porta_dei_messaggi.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_richiesta_di_legame.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/design_system/components/la_conferma_della_spesa.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:esoteric_circle/features/shell/il_tasto_indietro_della_home.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// LE ANTEPRIME DELL'ORDINE FD, a 360 per 797 punti logici col rapporto di
/// pixel 3. Le quattro della consegna: la conferma dei minuti, quella degli
/// Eos, quella col saldo che non basta, l'avviso del tasto indietro sulla
/// home.
///
/// **Girano sempre** e controllano a ogni giro che i testi a video siano
/// quelli dell'ordine; **scrivono le immagini solo con**
/// `AGGIORNA_ANTEPRIME=1`, in `docs/preview/FD/`.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();
  final scrivi = Platform.environment['AGGIORNA_ANTEPRIME'] == '1';

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
    m.setMockMethodCallHandler(SystemChannels.platform, (c) async => null);
  }

  void finestra(WidgetTester tester) {
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
    if (!scrivi) return;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FD');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FD ANTEPRIMA: ${dir.path}/$nome.png ${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> conferma(WidgetTester tester, int saldo,
      Future<void> Function(BuildContext) apri) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final borsa = QuestionAllowance(porta: _PortaFerma(saldo));
    await tester.runAsync(borsa.sincronizza);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: borsa),
        ChangeNotifierProvider(create: (_) => MaestroController()),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, f) => MaestroScope(child: f!),
          home: Builder(
            builder: (c) => Scaffold(
              backgroundColor: const Color(0xFF080718),
              body: Center(
                child: TextButton(
                    key: const Key('apri'),
                    onPressed: () => apri(c),
                    child: const Text('')),
              ),
            ),
          ),
        ),
      ),
    ));
    await passa(tester, 2);
    await tester.tap(find.byKey(const Key('apri')));
    await passa(tester);
  }

  testWidgets('FD: la conferma dei minuti del LIVE', (tester) async {
    await conferma(tester, 300,
        (c) => LaConfermaDellaSpesa.deiMinuti(c, minuti: 20, disponibili: 37));
    expect(find.text('Stai per aprire una sessione dal vivo.'), findsOneWidget);
    expect(
        find.text(
            'Questa sessione consuma 20 minuti dei tuoi 37 minuti disponibili.'),
        findsOneWidget);
    expect(find.text('Apri la sessione'), findsOneWidget);
    expect(find.text('Non ora'), findsOneWidget);
    await scatta(tester, 'fd_conferma_minuti');
  });

  testWidgets('FD: la conferma degli Eos', (tester) async {
    await conferma(
        tester, 300, (c) => LaConfermaDellaSpesa.degliEos(c, costo: 50));
    expect(find.text('Stai per usare i tuoi Eos.'), findsOneWidget);
    expect(
        find.text(
            'Questa richiesta costa 50 Eos. Nel tuo borsellino ce ne sono 300.'),
        findsOneWidget);
    expect(find.text('Procedi'), findsOneWidget);
    await scatta(tester, 'fd_conferma_eos');
  });

  testWidgets('FD: la conferma col saldo che non basta', (tester) async {
    await conferma(
        tester, 120, (c) => LaConfermaDellaSpesa.degliEos(c, costo: 300));
    expect(
        find.text(
            'Questa richiesta costa 300 Eos e nel tuo borsellino ce ne sono 120.'),
        findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('conferma_spesa_procedi')))
            .onPressed,
        isNull);
    await scatta(tester, 'fd_conferma_saldo_corto');
  });

  testWidgets('FD: l\'avviso del tasto indietro sulla home', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    finestra(tester);
    final ora = DateTime(2026, 10, 5, 10);
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(
          conIntro: false, services: AppServices.offline(), clock: () => ora),
    ));
    await passa(tester, 10);
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await passa(tester, 3);
    expect(find.text(IlTastoIndietroDellaHome.avviso), findsOneWidget);
    await scatta(tester, 'fd_home_avviso_indietro');
    await tester.pump(const Duration(seconds: 3));
  });

  // --- FD.06, LA RUBRICA COME PRIMA STRADA DEL CERCHIO ---

  final rubrica = [
    for (final n in const [
      'Alba Ferri',
      'Bruno Sala',
      'Carla Neri',
      'Dario Monti',
      'Elena Riva',
      'Fabio Greco',
      'Giulia Conti',
      'Luca Bassi',
      'Marta Leone',
      'Nadia Fontana',
      'Omar Villa',
      'Paola Serra',
    ])
      ContattoDellaRubrica(
          nome: n, numero: '+39 333 ${n.length}00 ${n.codeUnitAt(0)}'),
  ];

  Future<void> montaLInvito(WidgetTester tester,
      {bool concedi = true, PortaFintaDelCerchioSociale? porta}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    LaRubricaDelTelefono.richiesta = () async => concedi;
    LaRubricaDelTelefono.giaConcessa = () async => false;
    LaRubricaDelTelefono.leggi = () async => rubrica;
    LaPortaDeiMessaggi.apri = (u) async => true;
    final finta = porta ?? PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
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
          builder: (c, f) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: f!),
          ),
          home: const InvitaNelCerchioScreen(),
        ),
      ),
    ));
    await passa(tester, 8);
  }

  Future<void> apriLaRubrica(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('invita_rubrica')));
    await passa(tester, 8);
    final cta = find.widgetWithText(FilledButton, 'Apri la rubrica');
    if (cta.evaluate().length > 1) {
      await tester.tap(cta.last);
      await passa(tester, 8);
    }
  }

  testWidgets('il tutorial sul Redmi coi tasti di sistema', (tester) async {
    // Il fatto di un tester del 5 ottobre 2026: sul Redmi Note 14 il tasto
    // Avanti del fumetto dei Maestri stava sotto la barra dei tre tasti.
    // 1080x2400 a 2,75, la barra dei tasti 48 punti, quella di stato 32, il
    // carattere a 1,3. La barra dei tasti e' disegnata in fondo, grigia,
    // perche' l'anteprima non ha il sistema.
    silenzia();
    SharedPreferences.setMockInitialValues(
        {MemoriaDelPrimoApprodo.chiaveArmata: true});
    MemoriaDelPrimoApprodo.dimenticaLApertura();
    addTearDown(MemoriaDelPrimoApprodo.dimenticaLApertura);
    tester.view.devicePixelRatio = 2.75;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.viewPadding = const FakeViewPadding(top: 88, bottom: 132);
    tester.view.padding = const FakeViewPadding(top: 88, bottom: 132);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: Stack(
          children: [
            PrimoApprodo(
              child: Scaffold(
                backgroundColor: const Color(0xFF080718),
                body: Center(
                  child: AncoraDelPrimoApprodo(
                    nome: BersagliDelPrimoApprodo.trio,
                    child: Container(
                        width: 360,
                        height: 270,
                        color: const Color(0xFF3A2F6B)),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: IgnorePointer(child: ColoredBox(color: Color(0xCC444444))),
            ),
          ],
        ),
      ),
    ));
    await passa(tester);
    await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
    await passa(tester);
    expect(find.text('2 di 5'), findsOneWidget);
    final avanti =
        tester.getRect(find.byKey(const Key('primo_approdo_avanti')));
    print('FD, IL REDMI: fondo di Avanti ${avanti.bottom.round()} su '
        '${(2400 / 2.75 - 48).round()} liberi');
    expect(avanti.bottom, lessThanOrEqualTo(2400 / 2.75 - 48));
    await scatta(tester, 'fd_tutorial_redmi_tasti_di_sistema');
  });

  testWidgets('FD.06: le quattro schede nel nuovo ordine', (tester) async {
    await montaLInvito(tester);
    expect(find.text('Chiama chi conosci'), findsOneWidget);
    expect(find.text('Apri la rubrica'), findsOneWidget);
    await scatta(tester, 'fd06_quattro_schede');
  });

  testWidgets('FD.06: la rubrica con tre contatti scelti', (tester) async {
    await montaLInvito(tester);
    await apriLaRubrica(tester);
    for (final i in [0, 2, 3]) {
      await tester.tap(find.byKey(Key('rubrica_$i')));
      await tester.pump();
    }
    await passa(tester, 3);
    expect(find.text('Manda l’invito'), findsOneWidget);
    await scatta(tester, 'fd06_rubrica_tre_scelti');
  });

  testWidgets('FD.06: la rubrica al tetto dei dieci', (tester) async {
    await montaLInvito(tester);
    await apriLaRubrica(tester);
    for (var i = 0; i < 10; i++) {
      final k = find.byKey(Key('rubrica_$i'));
      await tester.ensureVisible(k);
      await tester.tap(k);
      await tester.pump();
    }
    await tester.ensureVisible(find.byKey(const Key('rubrica_11')));
    await passa(tester, 3);
    expect(find.text('Dieci per volta.'), findsOneWidget);
    await scatta(tester, 'fd06_rubrica_al_tetto');
  });

  testWidgets('FD.06: la scheda col permesso negato', (tester) async {
    await montaLInvito(tester, concedi: false);
    await apriLaRubrica(tester);
    expect(find.text('La rubrica è chiusa. Puoi sempre mandare il link.'),
        findsOneWidget);
    await scatta(tester, 'fd06_permesso_negato');
  });

  testWidgets('FD.06: il link scaduto', (tester) async {
    await montaLInvito(tester, porta: _PortaColCodiceScaduto());
    mostraLaRichiestaDiLegame(
        tester.element(find.byType(InvitaNelCerchioScreen)), 'AB12CD34');
    await passa(tester, 6);
    expect(
        find.text('Questo invito è scaduto. Chiedi alla persona che te lo ha '
            'mandato di rifarlo.'),
        findsOneWidget);
    await scatta(tester, 'fd06_link_scaduto');
    await tester.pump(const Duration(seconds: 5));
  });
}

class _PortaColCodiceScaduto extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'leggiIlCodice') {
      return const EsitoSociale(dati: {'valido': false});
    }
    return super.sociale(porta, corpo);
  }
}

class _PortaFerma extends PortaDelCerchio {
  _PortaFerma(this._saldo);
  final int _saldo;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio(
          giorno: '2026-10-05',
          piano: 'free',
          spesi: const {},
          saldoEos: _saldo);

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}
