// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/avvio_sinastria_evolutiva.dart';
import 'package:esoteric_circle/features/synastry/lo_studio_di_medora.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_tendina_della_sinastria_aiuto.dart';

/// **IL GIRO DELLE DUE SINASTRIE, COME UNA PERSONA.** Ordine FY voce FY.21,
/// 16 ottobre 2026. Il fondatore: *"Code deve fare simulazione per ogni
/// funzionalità qui sopra"*.
///
/// Per la Sinastria evolutiva e per la Sinastria VIP il giro intero, dalla
/// rotta vera: apertura, video, scelta, azione, risposta, ritorno. Ogni passo
/// ha la sua misura qui, e con `--dart-define=SCATTA_FY=true` la sua cattura in
/// `docs/collaudo/FY/sinastrie/`, a 390 per 844 punti col rapporto di pixel
/// 2.
///
/// **IL VIDEO E' FINTO, E LO DICE.** In prova il lettore video non c'e': la
/// finta mostra, al posto del filmato, un fotogramma vero di riferimento
/// (per la Sinastria evolutiva quello composto dall'Architetto in
/// `docs/collaudo/FT/riferimenti/`, per la VIP il primo fotogramma del
/// Sipario). Nessuna risposta qui la scrive un modello: le due Sinastrie
/// leggono il corpus e il calcolo, e nessuna chiamata a pagamento parte.
const _scatta = bool.fromEnvironment('SCATTA_FY');

class _FintaEvolutiva implements LettoreDellaScenaSinastria {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  bool _finito = false;
  int avvii = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => Image.memory(_fotogramma,
      key: const Key('finta_evolutiva'), fit: BoxFit.fill);

  /// Letto una volta, fuori dal tempo finto: un `FileImage` si caricherebbe
  /// nel tempo finto e la cattura lo aspetterebbe per sempre.
  static final _fotogramma =
      File('docs/collaudo/FT/riferimenti/composizione_primo_fotogramma.png')
          .readAsBytesSync();
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

class _FintaVip implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  bool _finito = false;
  int avvii = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => Image.asset(IlPalcoDellaSinastriaVip.primoFotogramma,
      key: const Key('finta_vip'), fit: BoxFit.cover);
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();
  final scatti = <String>[];

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaSuoneria.spentaPerLeProve = false;
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  Future<void> passa(WidgetTester tester, [int volte = 6]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    if (!_scatta) return;
    // Le immagini si decodificano fuori dal tempo finto: senza, la cattura
    // le prenderebbe vuote.
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e)
            .timeout(const Duration(seconds: 5), onTimeout: () {
          print("FY.21: un'immagine non si decodifica in tempo");
        });
      }
    });
    await passa(tester, 2);
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 2.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/collaudo/FY/sinastrie');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FY.21 CATTURA: ${dir.path}/$nome.png ${img.width}x${img.height}');
      scatti.add(nome);
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, Widget Function(BuildContext) apri,
      {Tier tier = Tier.free}) async {
    silenzia();
    // Il carattere dei simboli (i glifi dei segni e dei pianeti) non e' fra
    // quelli che la suite carica: senza, la cattura li mostra vuoti.
    await tester.runAsync(() async {
      final loader = FontLoader('NotoSansSymbols');
      loader.addFont(Future.value(ByteData.view(
          File('assets/fonts/NotoSansSymbols-subset.ttf')
              .readAsBytesSync()
              .buffer)));
      await loader.load();
    });
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: tier)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('giro_apri'),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: apri)),
                  child: const Text('Apri la funzione'),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('giro_apri')));
    await passa(tester, 8);
  }

  testWidgets(
      'FY.21, la Sinastria evolutiva: apertura, video, scelta, azione, '
      'risposta, ritorno', (tester) async {
    final finta = _FintaEvolutiva();
    // La rotta vera dell'arte apre il ponte; qui il ponte e' montato dentro
    // una pagina, con la finta del video.
    await monta(
        tester, (_) => AvvioSinastriaEvolutiva(fabbricaDellaScena: () => finta),
        tier: Tier.tier2);

    // APERTURA: lo studio di Medora, con la posa dell'astrolabio.
    expect(find.byKey(const Key('sinastria_evolutiva_scena')), findsOneWidget);
    expect(finta.avvii, 1, reason: 'il video non parte all\'apertura');
    expect(find.byKey(const Key('nascita_altra_codice')), findsNothing);
    await scatta(tester, 'e01_apertura');

    // VIDEO: sopra lo studio solo il video.
    finta.comincia();
    await passa(tester, 4);
    expect(find.byKey(const Key('finta_evolutiva')), findsOneWidget);
    final resto =
        tester.widgetList<IlRestoDopoLaScena>(find.byType(IlRestoDopoLaScena));
    expect(resto.every((r) => !r.scenaFerma), isTrue,
        reason: 'a video in corso il resto e\' gia\' in scena');
    await scatta(tester, 'e02_video');

    // FINE DEL VIDEO: la scena ferma e, in fondo, la scelta.
    finta.finisci();
    await passa(tester, 6);
    final scelta = find.byKey(const Key('sinastria_scegli_la_persona'));
    expect(scelta, findsOneWidget);
    expect(tester.getRect(scelta).bottom, lessThanOrEqualTo(844));
    await scatta(tester, 'e03_scena_ferma_e_scelta');

    // SCELTA E AZIONE: dall'ordine GD la tendina che sale (GD.14-GD.17).
    // LAPIDE: qui la prova compilava "La sua nascita" in una seconda
    // schermata e poi toccava il legame nella lettura; dall'ordine GD il
    // legame si sceglie prima, uno solo (GD.16).
    await compilaLaTendina(tester, legame: 'famiglia');
    await scatta(tester, 'e04_la_riflessione');
    await tester.pump(AttesaDiMedora.durataMinima);
    await passa(tester, 10);
    await scatta(tester, 'e05_la_statua_sul_tavolo');

    // RISPOSTA: la lettura, sotto la stessa scena, senza un secondo video.
    await tester.scrollUntilVisible(
        find.byKey(const Key('sinastria_evolutiva_nomi')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('sinastria_evolutiva_nomi')), findsOneWidget);
    expect(find.text('Tu e Giulia'), findsOneWidget);
    expect(finta.avvii, 1, reason: 'scelta la persona il video e\' ripartito');
    await passa(tester, 6);
    await scatta(tester, 'e06_la_lettura');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await passa(tester, 6);
    expect(tester.takeException(), isNull);
    await scatta(tester, 'e07_legame_famiglia_e_capitolo');

    // RITORNO.
    await tester.tap(find.byTooltip('Indietro').first);
    await passa(tester, 8);
    expect(find.byType(SinastriaEvolutivaScreen), findsNothing,
        reason: 'la freccia non riporta indietro');
    expect(find.byKey(const Key('giro_apri')), findsOneWidget);
    await scatta(tester, 'e08_ritorno');
  });

  testWidgets(
      'FY.21, la Sinastria VIP: apertura, video, scelta, azione, risposta, '
      'ritorno', (tester) async {
    final finta = _FintaVip();
    await monta(
        tester,
        (_) => PortaDellaSinastria(
              userSign: Zodiac.cancer,
              userName: 'Mauro',
              userBirth: DateTime(1966, 7, 23),
              fabbricaDellaScena: () => finta,
            ));

    // APERTURA: il sipario chiuso.
    expect(finta.avvii, 1, reason: 'il Sipario non parte all\'apertura');
    await scatta(tester, 'v01_apertura');

    // VIDEO.
    finta.comincia();
    await passa(tester, 4);
    expect(find.byKey(const Key('finta_vip')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_vip_interfaccia')), findsNothing);
    await scatta(tester, 'v02_video');

    // FINE: le due carte col cuore in mezzo (FY.12).
    finta.finisci();
    await passa(tester, 6);
    Rect carta(String chiave) => tester.getRect(find.descendant(
        of: find.byKey(Key(chiave)), matching: find.byType(VipFramedPortrait)));
    final tua = carta('sinastria_carta_tua');
    final vip = carta('sinastria_carta_da_scegliere');
    final cuore = tester.getRect(find.byKey(const Key('sinastria_vip_cuore')));
    expect((cuore.center.dx - (tua.right + vip.left) / 2).abs(),
        lessThanOrEqualTo(0.5));
    expect((cuore.center.dy - tua.center.dy).abs(), lessThanOrEqualTo(0.5));
    await scatta(tester, 'v03_le_due_carte');

    // SCELTA: la galleria, un volto.
    await tester.tap(find.byKey(const Key('sinastria_carta_da_scegliere')));
    await passa(tester, 8);
    expect(find.byType(SinastriaGalleryScreen), findsOneWidget);
    await scatta(tester, 'v04_la_galleria');
    final zendaya = VipCatalog.conNome('Zendaya')!;
    final volto = find.byKey(Key('vip_${zendaya.name}'));
    await tester.scrollUntilVisible(volto, 150,
        scrollable: find
            .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable))
            .first);
    await tester.ensureVisible(volto);
    await tester.pump();
    await tester.tap(volto);
    await passa(tester, 10);
    expect(find.byType(SinastriaGalleryScreen), findsNothing);
    expect(find.text('Scopri la compatibilità'), findsOneWidget);
    await scatta(tester, 'v05_il_vip_scelto');

    // AZIONE: scopri la compatibilita'.
    final scopri = find.byKey(const Key('sinastria_fai_il_confronto'));
    await tester.ensureVisible(scopri);
    await tester.pump();
    await tester.tap(scopri);
    // La chiamata del VIP e poi il verdetto.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // RISPOSTA.
    expect(find.byType(SinastriaVipScreen), findsOneWidget);
    expect(find.textContaining('Zendaya'), findsWidgets);
    expect(tester.takeException(), isNull);
    await scatta(tester, 'v06_il_responso');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await passa(tester, 6);
    await scatta(tester, 'v07_il_responso_scorso');

    // RITORNO: alla porta, poi fuori.
    await tester.tap(find.byTooltip('Indietro').first);
    await passa(tester, 10);
    expect(find.byType(SinastriaVipScreen), findsNothing);
    expect(find.byType(PortaDellaSinastria), findsOneWidget);
    await scatta(tester, 'v08_ritorno_alla_porta');
    await tester.tap(find.byType(BackButton).first);
    await passa(tester, 10);
    expect(find.byKey(const Key('giro_apri')), findsOneWidget);
    await scatta(tester, 'v09_ritorno');
  });

  tearDownAll(() {
    if (_scatta) print('FY.21: ${scatti.length} catture');
  });
}
