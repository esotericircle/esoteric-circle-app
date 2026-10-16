import 'dart:async';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/avvio_sinastria_evolutiva.dart';
import 'package:esoteric_circle/features/synastry/lo_studio_di_medora.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SINASTRIA EVOLUTIVA SI APRE SULLA SUA SCENA.** Ordine FY voce FY.11,
/// 16 ottobre 2026. Il fondatore, sulla build 2312: *"La sinastria evolutiva
/// inizia con una schermata nera e le funzioni social, niente altro"*.
///
/// **LA CAUSA, MISURATA.** La rotta dell'arte (`synastry_depth`) apriva il
/// ponte `AvvioSinastriaEvolutiva` dell'ordine FT voce FT.14: uno `Scaffold`
/// tutto nero che, al primo fotogramma, spingeva sopra di se' il modulo "La
/// sua nascita" (il codice dell'altro telefono, "Fai leggere la tua
/// nascita"). Lo studio di Medora, il video e la lettura arrivavano solo dopo
/// aver dato la nascita dell'altra persona: chi apriva la funzione vedeva il
/// nero e le funzioni sociali, niente altro.
///
/// **E UNA SECONDA CAUSA, PIU' SOTTILE**, dall'ordine FX voce FXA.08: la
/// Sinastria evolutiva tiene il suo lettore (non la regia comune, che ha
/// l'attesa massima di quattro secondi), e il blocco sotto lo studio aspetta
/// la scena ferma. Un video che non si prepara mai, che e' pronto e non
/// parte, o che parte e si blocca, teneva il resto a opacita' zero per
/// sempre.
///
/// **COSA MISURA.** Il giro vero dalla rotta dell'arte: lo studio c'e' al
/// primo sguardo e il modulo no; scelta la persona, la lettura compare
/// nella stessa schermata, sotto la stessa scena, senza un secondo video.
/// E per i tre lettori che non arrivano mai a fine, il blocco sotto lo studio
/// compare entro l'attesa massima.
class _LettoreCheSiFerma implements LettoreDellaScenaSinastria {
  _LettoreCheSiFerma(this.modo);

  /// 'non si prepara', 'pronto e non parte', 'parte e si blocca'.
  final String modo;
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  int sospensioni = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;

  @override
  Future<void> apri() {
    if (modo == 'non si prepara') return Completer<void>().future;
    _pronto = true;
    _ascolta?.call();
    return Future.value();
  }

  @override
  Future<void> volume(double quanto) async {}

  @override
  Future<void> avvia() async {
    if (modo != 'parte e si blocca') return;
    _cominciato = true;
    _ascolta?.call();
  }

  @override
  Future<void> sospendi() async => sospensioni++;

  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_che_si_ferma'), color: Color(0xFF203040));

  @override
  void chiudi() {}
}

final _marco = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Marco');
final _giulia = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Giulia');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Widget app(Widget home) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(
              create: (_) => SettingsController(suonoEVibrazione: false)),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: Tier.free)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: home,
        ),
      );

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets(
      'FY.11: dalla rotta dell\'arte si apre lo studio di Medora, non il nero '
      'col modulo; scelta la persona la lettura compare sotto la stessa scena',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).push(AvvioSinastriaEvolutiva.route()),
            child: const Text('apri'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('apri'));
    await passa(tester, 12);

    // Il primo sguardo: la scena, e non il modulo.
    final scena = find.byKey(const Key('sinastria_evolutiva_scena'));
    expect(scena, findsOneWidget,
        reason: 'all\'apertura la Sinastria evolutiva non mostra la sua '
            'scena: si vede il nero del ponte');
    expect(find.byKey(const Key('studio_sfondo')), findsOneWidget,
        reason: 'lo studio di Medora non e\' dipinto');
    expect(find.byKey(const Key('nascita_altra_codice')), findsNothing,
        reason: 'all\'apertura si vede il modulo del codice, la funzione '
            'sociale, al posto della scena');
    final r = tester.getRect(scena);
    expect(r.width, 390, reason: 'la scena non e\' larga quanto lo schermo');
    // La scena e' la prima cosa sotto la barra del titolo (che qui, senza
    // la barra di stato, e' alta kToolbarHeight).
    expect(r.top, lessThanOrEqualTo(kToolbarHeight + 0.5),
        reason: 'la scena non comincia sotto la barra del titolo');
    expect(r.height, greaterThan(500), reason: 'la scena non e\' intera');

    // Sotto la scena, a scena ferma, la scelta della persona: si vede e si
    // tocca.
    final scelta = find.byKey(const Key('sinastria_scegli_la_persona'));
    expect(scelta, findsOneWidget,
        reason: 'sotto la scena manca il gesto che apre la lettura');
    await tester.ensureVisible(scelta);
    await passa(tester, 2);
    await tester.tap(scelta);
    await passa(tester, 8);
    expect(find.byKey(const Key('nascita_altra_codice')), findsOneWidget,
        reason: 'il gesto non apre la nascita dell\'altra persona: la '
            'lettura a due telefoni (FY.14: per la Sinastria resta) e la '
            'strada a mano');

    await tester.enterText(
        find.byKey(const Key('nascita_altra_nome')), 'Giulia');
    await tester.tap(find.byKey(const Key('nascita_altra_ora_non_nota')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('nascita_altra_data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nascita_altra_conferma')));
    await passa(tester, 12);

    // La risposta, nella stessa schermata e sotto la stessa scena.
    expect(find.byType(SinastriaEvolutivaScreen), findsOneWidget,
        reason: 'la lettura si e\' aperta in una seconda schermata');
    expect(scena, findsOneWidget);
    expect(find.byKey(const Key('sinastria_evolutiva_nomi')), findsOneWidget,
        reason: 'scelta la persona la lettura non compare');
    expect(find.text('Tu e Giulia'), findsOneWidget);
    expect(find.byKey(const Key('sinastria_scegli_la_persona')), findsNothing,
        reason: 'con la lettura aperta resta il gesto della scelta');
    expect(tester.takeException(), isNull);
  });

  for (final schermo in const [
    Size(360, 760),
    Size(360, 797),
    Size(390, 844),
    Size(412, 915),
    Size(430, 932),
  ]) {
    testWidgets(
        'FY.11 a ${schermo.width.toInt()}x${schermo.height.toInt()}: la '
        'scelta della persona si vede intera nella prima schermata, sotto '
        'Medora', (tester) async {
      silenzia();
      tester.view.physicalSize = schermo;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(SinastriaEvolutivaScreen(
        nomeTuo: 'Tu',
        cieloTuo: _marco,
        chiediLaPersona: (_) async => null,
      )));
      await passa(tester, 6);
      final pulsante =
          tester.getRect(find.byKey(const Key('sinastria_scegli_la_persona')));
      // Il testo della scelta, la prima cosa che si vede sopra il velo.
      final pannello =
          tester.getRect(find.byKey(const Key('sinastria_la_scelta_titolo')));
      final medora = tester.getRect(find.byKey(const Key('studio_medora')));
      expect(pulsante.bottom, lessThanOrEqualTo(schermo.height),
          reason: 'il pulsante della scelta finisce a ${pulsante.bottom}, '
              'sotto la piega di ${schermo.height}');
      expect(pannello.top, greaterThanOrEqualTo(medora.bottom - 0.5),
          reason: 'la scelta comincia a ${pannello.top} e copre Medora, '
              'che finisce a ${medora.bottom}');
      expect(tester.takeException(), isNull);
    });
  }

  for (final modo in const [
    'non si prepara',
    'pronto e non parte',
    'parte e si blocca'
  ]) {
    testWidgets(
        'FY.11 e FXA.08: un video che $modo non tiene nascosto per sempre il '
        'blocco sotto lo studio', (tester) async {
      silenzia();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final lettore = _LettoreCheSiFerma(modo);
      await tester.pumpWidget(app(SinastriaEvolutivaScreen(
        nomeTuo: 'Marco',
        cieloTuo: _marco,
        nomeSuo: 'Giulia',
        cieloSuo: _giulia,
        fabbricaDellaScena: () => lettore,
      )));
      bool ferma() => tester
          .widget<IlRestoDopoLaScena>(find.byType(IlRestoDopoLaScena))
          .scenaFerma;
      // Il tempo massimo: quanto dura il filmato, piu' l'attesa massima
      // della regia comune, piu' la dissolvenza.
      final massimo = ScenaDellaSinastriaInVideo.durata +
          RegiaDellaScena.attesaMassima +
          IlFilmatoCheSfuma.dissolvenza;
      var t = Duration.zero;
      while (t < massimo && !ferma()) {
        await tester.pump(const Duration(milliseconds: 250));
        t += const Duration(milliseconds: 250);
      }
      expect(ferma(), isTrue,
          reason: 'con un video che $modo, dopo ${t.inMilliseconds} ms il '
              'blocco sotto lo studio e\' ancora nascosto: la Sinastria resta '
              'una scena vuota per sempre');
      await tester.pump(IlFilmatoCheSfuma.dissolvenza);
      expect(find.byKey(const Key('il_tocco_che_salta')), findsNothing,
          reason: 'il velo che salta il video resta sopra la schermata');
      await tester.pumpWidget(const SizedBox());
    });
  }
}
