import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL PASSO DEL LUOGO DI NASCITA NON E' PIU' UNA TRAPPOLA.
///
/// Ordine 2169, voce 1. **Il fatto, osservato da Mauro due volte su di se'.**
/// Si scrivono le iniziali, compare l'elenco dei suggerimenti, la tastiera
/// sale e l'elenco finisce sotto la tastiera e sotto il pulsante. La persona
/// non lo vede, crede che scrivere il nome basti, preme il pulsante, e quel
/// pulsante dice "Salta per ora". Il luogo resta vuoto e lei e' convinta di
/// averlo dato. Mesi dopo l'Oroscopo le dice che mancano i dati di nascita.
///
/// **Le tre prove misurano tre cose diverse, perche' il difetto e' triplo:**
/// l'elenco che non si vede, il pulsante che mente sul proprio effetto, e la
/// scelta chiesta quando c'e' un candidato solo. Correggerne una lascerebbe
/// la trappola armata.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  /// Arriva al passo del luogo, con la TASTIERA APERTA quando [tastiera] e'
  /// maggiore di zero.
  ///
  /// La tastiera si simula con `viewInsets`, che e' esattamente cio' che il
  /// sistema comunica all'app quando la tastiera sale: 336 punti e' la misura
  /// di una tastiera italiana su un telefono da sei pollici e mezzo.
  Future<void> alPassoLuogo(WidgetTester tester,
      {double tastiera = 336, double altezza = 2392}) async {
    silence();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
            disableAnimations: true,
            viewInsets: EdgeInsets.only(bottom: tastiera),
          ),
          child: MaestroScope(child: child!),
        ),
        home: OnboardingScreen(clock: () => DateTime(2026, 7, 15)),
      ),
    ));
    await tester.pumpAndSettle();
    // accoglienza -> data -> ora -> luogo
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('onboarding_continue')).last);
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('risveglio_luogo_field')), findsOneWidget,
        reason: 'non si e\' arrivati al passo del luogo');
  }

  Future<void> scrivi(WidgetTester tester, String testo) async {
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), testo);
    await tester.pumpAndSettle();
  }

  String etichettaDelPulsante(WidgetTester tester) {
    final f = find.byKey(const Key('onboarding_continue'));
    final testi = find
        .descendant(of: f.last, matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    return testi.join(' ');
  }

  testWidgets('con la tastiera aperta l\'elenco dei suggerimenti SI VEDE',
      (tester) async {
    await alPassoLuogo(tester);
    await scrivi(tester, 'Tor');

    final elenco = find.ancestor(
        of: find.byKey(const Key('citta_Torino_TO')),
        matching: find.byType(Container));
    expect(elenco, findsWidgets,
        reason: 'scrivendo tre lettere non compare nessun elenco');

    // **LA MISURA, NON L'OCCHIO.** Lo spazio in cui la persona puo' vedere
    // qualcosa finisce dove comincia la tastiera, e piu' in su dove comincia
    // il pulsante. Se l'elenco sta sotto uno dei due, per lei non esiste.
    final schermo =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final cimaTastiera = schermo - 336;
    final pulsante =
        tester.getRect(find.byKey(const Key('onboarding_continue')).last);
    final limite = cimaTastiera < pulsante.top ? cimaTastiera : pulsante.top;
    final r = tester.getRect(elenco.last);

    // ignore: avoid_print
    print('LUOGO: l\'elenco va da ${r.top.toStringAsFixed(1)} a '
        '${r.bottom.toStringAsFixed(1)}; la tastiera comincia a '
        '${cimaTastiera.toStringAsFixed(1)}, il pulsante a '
        '${pulsante.top.toStringAsFixed(1)}');

    expect(r.top, lessThan(limite),
        reason: 'l\'elenco dei suggerimenti comincia gia\' sotto la tastiera '
            'o sotto il pulsante: la persona non lo vede affatto');
    // Almeno la prima voce deve essere intera: un elenco di cui si vede una
    // striscia di due pixel non e' un elenco che si puo' scegliere.
    expect(r.top + 48, lessThanOrEqualTo(limite),
        reason: 'della prima voce dell\'elenco si vede meno di 48 punti: non '
            'e\' toccabile');

    // **E DEVE ESSERE SCORRIBILE.** Otto suggerimenti non stanno tutti sopra
    // la tastiera nemmeno nel caso migliore: cio' che conta e' che si possa
    // arrivare all'ultimo, altrimenti chi cerca una citta' che sta in fondo
    // all'elenco resta nella trappola di prima.
    final voci = find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('citta_'))
        .evaluate()
        .toList();
    expect(voci.length, greaterThan(1),
        reason: 'un elenco di una voce sola non misura la scorribilita\'');
    final ultima = find.byKey(voci.last.widget.key!);
    await tester.ensureVisible(ultima);
    await tester.pumpAndSettle();
    final r2 = tester.getRect(ultima);
    // ignore: avoid_print
    print('LUOGO: l\'ultima delle ${voci.length} voci, portata in vista, '
        'finisce a ${r2.bottom.toStringAsFixed(1)} contro il limite '
        '${limite.toStringAsFixed(1)}');
    expect(r2.bottom, lessThanOrEqualTo(limite + 1),
        reason: 'l\'ultima voce dell\'elenco non si riesce a portare sopra la '
            'tastiera nemmeno scorrendo: chi cerca una citta\' che sta in '
            'fondo resta nella trappola di prima');
  });

  testWidgets(
      'col campo pieno e nessuna citta\' scelta, il pulsante NON dice '
      'di saltare', (tester) async {
    await alPassoLuogo(tester);
    // Un nome parziale: l'elenco propone piu' citta' e nessuna e' scelta.
    await scrivi(tester, 'Tor');

    final etichetta = etichettaDelPulsante(tester);
    // ignore: avoid_print
    print('LUOGO: col campo pieno il pulsante dice "$etichetta"');
    expect(etichetta.toLowerCase().contains('salta'), isFalse,
        reason: 'il pulsante dice "$etichetta" mentre nel campo c\'e\' del '
            'testo: chi ha scritto il nome della propria citta\' preme quel '
            'pulsante credendo di confermarla, e invece salta il passaggio. '
            'E\' la trappola che ha lasciato la fondatrice senza luogo.');
  });

  testWidgets('il nome esatto di UNA sola citta\' si sceglie da solo',
      (tester) async {
    await alPassoLuogo(tester);
    // Nel catalogo esiste una sola Cattolica, in provincia di Rimini.
    final quante = CityCatalog.cities
        .where((c) => c.name.toLowerCase() == 'cattolica')
        .length;
    expect(quante, 1,
        reason: 'la prova si regge su Cattolica come nome unico nel catalogo, '
            'e nel catalogo ce ne sono $quante: scegline un altro invece di '
            'allentare la pretesa');

    await scrivi(tester, 'Cattolica');

    // Scelta significa scelta davvero: il pulsante non parla piu' di saltare
    // e l'elenco non chiede piu' niente.
    final etichetta = etichettaDelPulsante(tester);
    // ignore: avoid_print
    print('LUOGO: scritto il nome esatto, il pulsante dice "$etichetta"');
    expect(etichetta.toLowerCase().contains('salta'), isFalse,
        reason: 'con un solo candidato possibile il pulsante chiede ancora di '
            'scegliere: un candidato solo non e\' una scelta, e\' gia\' la '
            'risposta');
    expect(find.byKey(const Key('risveglio_luogo_scelto')), findsOneWidget,
        reason:
            'scritto per intero il nome di una citta\' che nel catalogo e\' '
            'unica, il luogo non risulta scelto');
  });
}
