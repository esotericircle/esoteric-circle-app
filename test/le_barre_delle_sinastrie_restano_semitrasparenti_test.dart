// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/collezione_screen.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/features/synastry/la_tua_nascita_per_una_lettura.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE BARRE DELLE SINASTRIE RESTANO SEMITRASPARENTI.** Ordine FY voce
/// FY.20, per le sole schermate delle Sinastrie (il resto dell'app lo
/// sorveglia la guardia del tema comune). Il fondatore, 16 ottobre 2026:
/// *"Quando scorro in alto, la barra del titolo compare solida di botto e non
/// più trasparente"*, e *"Tutte le barre del titolo di ogni funzionalità
/// devono restare sempre semitrasparenti, tutte e per sempre"*.
///
/// **COSA MISURA.** Il colore che la barra dipinge davvero: quello del suo
/// `Material`, con la tinta di superficie che Material 3 ci posa sopra
/// all'elevazione del momento (`ElevationOverlay.applySurfaceTint`, la
/// stessa formula del motore). La sua opacita' resta sotto
/// [_opacitaMassima] all'apertura e dopo aver scorso il contenuto sotto la
/// barra, e non cambia fra i due stati. Una barra piena (il fondo profondo
/// senza trasparenza, o il velo che passava da 0,16 a 0,9 nella Sinastria
/// evolutiva) ha opacita' 1 o 0,9.
const double _opacitaMassima = 0.6;

/// Il cardinale minimo: le schermate delle Sinastrie con una barra.
const int _schermateAttese = 7;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  var misurate = 0;
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

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

  final schermate = <String, Widget Function()>{
    'Sinastria evolutiva': () => SinastriaEvolutivaScreen(
          nomeTuo: 'Tu',
          cieloTuo: CieloEvolutivo.perNascita(
              momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Tu'),
          nomeSuo: 'Giulia',
          cieloSuo: CieloEvolutivo.perNascita(
              momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Giulia'),
        ),
    'Sinastria evolutiva, la scelta': () => SinastriaEvolutivaScreen(
          nomeTuo: 'Tu',
          cieloTuo: CieloEvolutivo.perNascita(
              momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Tu'),
          chiediLaPersona: (_) async => null,
        ),
    'La sua nascita': () =>
        LaNascitaDellAltraPersona(palette: palette, nomeIniziale: 'Giulia'),
    'La tua nascita': () => LaTuaNascitaPerUnaLettura(palette: palette),
    'Sinastria VIP, la porta': () => PortaDellaSinastria(
        userSign: Zodiac.cancer,
        userName: 'Mauro',
        userBirth: DateTime(1966, 7, 23)),
    'Sinastria VIP, la galleria': () => SinastriaGalleryScreen(
        userSign: Zodiac.cancer,
        userName: 'Mauro',
        userBirth: DateTime(1966, 7, 23)),
    'Sinastria VIP, il responso': () => SinastriaVipScreen(
        vip: VipCatalog.conNome('Zendaya')!,
        saltaLaChiamata: true,
        userName: 'Tu'),
    'Sinastria VIP, la collezione': () => CollezioneScreen(onApri: (_) {}),
  };

  for (final MapEntry(key: nome, value: crea) in schermate.entries) {
    testWidgets(
        'FY.20, $nome: la barra del titolo resta semitrasparente all\'apertura '
        'e scorrendo', (tester) async {
      silenzia();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
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
              create: (_) => EntitlementService(initial: Tier.tier2)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // Il tema vero dell'app: la tinta di superficie e l'elevazione
          // di quando si scorre vengono da li'.
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(child: figlio!),
          ),
          home: crea(),
        ),
      ));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      double opacita() {
        final m = tester.widget<Material>(find
            .descendant(
                of: find.byType(AppBar).first, matching: find.byType(Material))
            .first);
        final colore = ElevationOverlay.applySurfaceTint(
            m.color ?? Colors.transparent, m.surfaceTintColor, m.elevation);
        return colore.a;
      }

      final prima = opacita();
      // Il contenuto scorre sotto la barra: e' il gesto del fondatore.
      final scorrevoli = find.byType(Scrollable);
      var scorso = false;
      for (final e in scorrevoli.evaluate()) {
        final s = e.widget as Scrollable;
        if (s.axisDirection != AxisDirection.down) continue;
        await tester.drag(find.byWidget(s).first, const Offset(0, -500),
            warnIfMissed: false);
        scorso = true;
        break;
      }
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      final dopo = opacita();
      print('FY.20 $nome: opacita\' della barra ${prima.toStringAsFixed(3)} '
          'all\'apertura, ${dopo.toStringAsFixed(3)} '
          '${scorso ? 'scorrendo' : 'senza nulla da scorrere'}');
      misurate++;
      expect(prima, lessThanOrEqualTo(_opacitaMassima),
          reason: '$nome: all\'apertura la barra e\' piena ($prima)');
      expect(dopo, lessThanOrEqualTo(_opacitaMassima),
          reason: '$nome: scorrendo la barra diventa piena ($dopo)');
      expect((dopo - prima).abs(), lessThan(0.01),
          reason: '$nome: scorrendo la barra cambia di botto, da $prima a '
              '$dopo');
      await tester.pumpWidget(const SizedBox());
    });
  }

  tearDownAll(() {
    expect(misurate, greaterThanOrEqualTo(_schermateAttese),
        reason: 'la guardia ha misurato $misurate schermate su '
            '$_schermateAttese');
  });
}
