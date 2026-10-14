// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/la_lettura_evolutiva.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/upgrade_invite.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/features/synastry/il_ritratto_della_coppia.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_composito_e_keplero.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_corpus_della_sinastria_evolutiva.g.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/legame_e_eta.dart';
import 'package:esoteric_circle/core/ricordi/artwork_del_ricordo.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';
import 'package:esoteric_circle/features/synastry/la_tua_nascita_per_una_lettura.dart';
import 'package:esoteric_circle/features/synastry/lo_studio_di_medora.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ANTEPRIME DELLA SINASTRIA EVOLUTIVA**, ordine FT voce FT.15: le
/// schermate nuove, che prima dell'ordine non c'erano (la scheda della home
/// portava al velo del Coming soon). Solo il "dopo", a 360 per 797 punti
/// logici col rapporto di pixel 3, in `docs/preview/FT/`, con
/// `--dart-define=STATO=dopo`. La scena e' quella ferma a mani aperte: il
/// filmato vero si guarda sul telefono (voce aperta in attesa di verifica).
const _stato = String.fromEnvironment('STATO');

/// Un filmato che non si carica: la scena resta ferma, come con Riduci
/// Movimento, e la cattura non dipende dal lettore video.
class _FilmatoAssente implements LettoreDellaScenaSinastria {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox();
  @override
  void chiudi() {}
}

CieloEvolutivo _cielo(DateTime nascita, String nome) =>
    CieloEvolutivo.perNascita(
        momentoUtc: DateTime.utc(nascita.year, nascita.month, nascita.day, 12),
        giornoDiNascita: nascita,
        nome: nome);

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaSuoneria.spentaPerLeProve = false;
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

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
      final dir = Directory('docs/preview/FT');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FT ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, Widget home, {Tier? tier}) async {
    silenzia();
    // Il carattere dei simboli non e' fra quelli che la suite carica: qui
    // serve, perche' i glifi dei pianeti si guardano nella cattura.
    await tester.runAsync(() async {
      final loader = FontLoader('NotoSansSymbols');
      loader.addFont(Future.value(ByteData.view(
          File('assets/fonts/NotoSansSymbols-subset.ttf')
              .readAsBytesSync()
              .buffer)));
      await loader.load();
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: tier ?? Tier.free)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(child: figlio!),
          ),
          home: home,
        ),
      ),
    ));
    await passa(tester);
    // Le immagini dello studio e del ritratto si decodificano fuori dal
    // tempo finto: senza, la cattura le prenderebbe vuote.
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        final w = e.widget as Image;
        await precacheImage(w.image, e);
      }
    });
    await passa(tester, 4);
  }

  Widget lettura() => SinastriaEvolutivaScreen(
        nomeTuo: 'Tu',
        cieloTuo: _cielo(DateTime(1990, 5, 12), 'Tu'),
        nomeSuo: 'Giulia',
        cieloSuo: _cielo(DateTime(1992, 9, 3), 'Giulia'),
        fabbricaDellaScena: _FilmatoAssente.new,
        oggi: DateTime(2026, 10, 14),
      );

  Future<void> alCentro(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 400,
        scrollable: find.byType(Scrollable).first, maxScrolls: 80);
    await Scrollable.ensureVisible(tester.element(f), alignment: 0.15);
    await passa(tester, 3);
  }

  testWidgets('FT.06-FT.10: la lettura del Viandante', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, lettura());
    await scatta(tester, 'ft_viandante_1_apertura');
    await alCentro(tester, find.byKey(const Key('sinastria_oggi_fra_voi')));
    await scatta(tester, 'ft_viandante_2_oggi_fra_voi');
    await alCentro(tester,
        find.byKey(Key('sinastria_capitolo_${Capitolo.attrazione.name}')));
    await scatta(tester, 'ft_viandante_3_capitolo');
    await alCentro(tester,
        find.byKey(Key('sinastria_chiuso_capitolo_${Capitolo.mente.name}')));
    await scatta(tester, 'ft_viandante_4_capitoli_chiusi');
    await alCentro(tester, find.byKey(const Key('sinastria_chiuso_adepto')));
    await scatta(tester, 'ft_viandante_5_esclusive_chiuse');
  });

  testWidgets('FT.09-FT.11: la lettura dell\'Adepto', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, lettura(), tier: Tier.tier2);
    await alCentro(tester, find.byKey(const Key('sinastria_keplero')));
    await scatta(tester, 'ft_adepto_1_keplero');
    await alCentro(tester, find.byKey(const Key('sinastria_composito')));
    await scatta(tester, 'ft_adepto_2_composito');
    await alCentro(tester, find.byKey(const Key('sinastria_momento_giusto')));
    await scatta(tester, 'ft_adepto_3_momento_giusto');
  });

  testWidgets('FT.03: la nascita dell\'altra persona', (tester) async {
    if (_stato.isEmpty) return;
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    await monta(tester,
        LaNascitaDellAltraPersona(palette: palette, nomeIniziale: 'Giulia'));
    await scatta(tester, 'ft03_la_nascita_dell_altra_persona');
  });

  testWidgets('FT.03: la tua nascita per una lettura', (tester) async {
    if (_stato.isEmpty) return;
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    await monta(tester, LaTuaNascitaPerUnaLettura(palette: palette));
    await scatta(tester, 'ft03_la_tua_nascita_per_una_lettura');
  });

  testWidgets('FT.11 e FT.14: il ritratto della coppia e la card del capitolo',
      (tester) async {
    if (_stato.isEmpty) return;
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final tuo = _cielo(DateTime(1990, 5, 12), 'Tu');
    final suo = _cielo(DateTime(1992, 9, 3), 'Giulia');
    final capitoli = LetturaEvolutiva.componi(
        tuo: tuo,
        suo: suo,
        nomeSuo: 'Giulia',
        legame: Legame.amore,
        corpus: corpusDellaSinastriaEvolutiva);
    final composito = IlComposito.fra(tuo, suo);
    final titoli =
        corpusDellaSinastriaEvolutiva['composito|${composito.cella}|titolo']!;
    final coppia = ArtworkDelRicordo.percorsoDellaCoppia(
        IlSegnoDelCielo.dellaLongitudine(
            composito.punti[PuntoDelCieloEvolutivo.sole]!));
    for (final (nome, card) in [
      (
        'ft11_il_ritratto_della_coppia',
        RitrattoDellaCoppia(
            palette: palette,
            nomeSuo: 'Giulia',
            legame: Legame.amore,
            coppia: coppia,
            sintesi: titoli[
                LetturaEvolutiva.semeDellaCoppia(tuo, suo) % titoli.length],
            capitoli: capitoli,
            width: 340),
      ),
      (
        'ft14_la_card_del_capitolo',
        CardDelCapitolo(
            palette: palette,
            nomeSuo: 'Giulia',
            legame: Legame.amore,
            capitolo: capitoli.first,
            width: 340),
      ),
    ]) {
      await monta(
          tester,
          Scaffold(
              backgroundColor: palette.deepest,
              body: Center(child: SingleChildScrollView(child: card))));
      await scatta(tester, nome);
    }
  });

  testWidgets('FT.13: le coppie nuove di oggi sono finite', (tester) async {
    if (_stato.isEmpty) return;
    await monta(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showUpgradeInvite(
                  context,
                  title: 'Le coppie nuove di oggi sono finite',
                  message: 'Domani se ne apre una nuova. Oppure leggi questa '
                      'subito, o sali di piano per leggerne di più ogni '
                      'giorno.',
                  riscattoLabel:
                      '${ListinoDegliEos.sinastriaEvolutivaInPiu.nome}, '
                      '${ListinoDegliEos.prezzo(150)}',
                  onRiscatta: () async {},
                ),
                child: const Text('apri'),
              ),
            ),
          ),
        ));
    await tester.tap(find.text('apri'));
    await passa(tester, 10);
    await scatta(tester, 'ft13_coppie_finite_invito');
  });
}
