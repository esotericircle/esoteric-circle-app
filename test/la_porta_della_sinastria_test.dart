import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA PORTA DELLA SINASTRIA VIP. Ordine CA voci 01 e 02.
///
/// **CA.01, la grandezza misurata e' COSA SI VEDE PER PRIMO**, in punti
/// dipinti: entrando nella Sinastria VIP la prima schermata deve portare il
/// titolo, le due carte affiancate e le tre scelte, e NON il catalogo dei
/// volti. Parole del fondatore: "le bolle di fai sinastria vip oppure calcola
/// il tuo gemello astrale VIP devono stare nella prima schermata che vede
/// l'utente e non nella schermata di scelta del vip".
///
/// **CA.02, la grandezza misurata e' QUALE CASELLA CAMBIA dopo un tocco.**
/// Parole del fondatore: "toccando la carta di sinistra per cambiare quel
/// personaggio, viene cambiato sempre quello di destra". La prova tocca la
/// carta di SINISTRA, sceglie un volto, e guarda quale delle due caselle lo
/// ha preso.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
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
    silenzia();
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const PortaDellaSinastria(
          userSign: Zodiac.leo,
          userName: 'Mauro',
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Sceglie [quale] nella galleria che si e' appena aperta.
  Future<void> scegliDallaGalleria(WidgetTester tester, Vip quale) async {
    expect(find.byType(SinastriaGalleryScreen), findsOneWidget,
        reason: 'la galleria di scelta non si e\' aperta');
    final carta = find.byKey(Key('vip_${quale.name}'));
    await tester.scrollUntilVisible(carta, 150,
        scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(carta);
    await tester.pump();
    await tester.tap(carta);
    // La rotta che si chiude ha la sua transizione: si aspetta guardando.
    for (var i = 0; i < 12 &&
            find.byType(SinastriaGalleryScreen).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // ignore: avoid_print
    print('DIAGNOSI: galleria ancora aperta? '
        '${find.byType(SinastriaGalleryScreen).evaluate().isNotEmpty}');
  }

  testWidgets('CA.01: entrando si vedono per prime le due carte e le tre '
      'scelte, non il catalogo', (tester) async {
    await monta(tester);
    final titolo = find.byKey(const Key('sinastria_titolo_confronto'));
    expect(titolo, findsOneWidget,
        reason: 'la prima schermata non porta il titolo del confronto');
    expect(tester.widget<Text>(titolo).data, 'La Tua Compatibilità con un VIP',
        reason: 'il titolo non e\' quello che il fondatore ha scritto');

    final tua = tester.getRect(find.byKey(const Key('sinastria_carta_tua')));
    final daScegliere =
        tester.getRect(find.byKey(const Key('sinastria_carta_da_scegliere')));
    // ignore: avoid_print
    print('ORDINE CA VOCE 1: carta tua a ${tua.left.round()}, carta da '
        'scegliere a ${daScegliere.left.round()}');
    expect(tua.center.dx, lessThan(daScegliere.center.dx),
        reason: 'la tua carta non sta a sinistra');

    // **LE TRE SCELTE SONO QUI, non nella galleria.**
    for (final modo in ModoDellaSinastria.values) {
      expect(find.byKey(Key(modo.chiave)), findsOneWidget,
          reason: 'la scelta "${modo.titolo}" non e\' nella prima schermata');
    }
    // E il catalogo dei volti NON e' questa schermata.
    expect(find.byType(SinastriaGalleryScreen), findsNothing,
        reason: 'la prima schermata e\' ancora il catalogo dei volti');
    expect(find.byKey(Key('vip_${VipCatalog.vips.first.name}')), findsNothing,
        reason: 'i volti del catalogo sono gia\' in scena');
  });

  testWidgets('CA.01: la Sinastria VIP si APRE sulla porta, non sul catalogo',
      (tester) async {
    // **QUESTA E' LA MISURA DELL'INGRESSO VERO**, cioe' della rotta che l'app
    // costruisce quando qualcuno tocca la Sinastria VIP dal Santuario. Le
    // altre prove montano la porta a mano, e direbbero il vero anche se
    // nessuno la aprisse mai.
    final rotta = artRouteFor('synastry_vip',
        userBirth: DateTime(1990, 8, 10), userName: 'Mauro');
    expect(rotta, isNotNull, reason: 'la Sinastria VIP non ha nessuna rotta');
    await tester.pumpWidget(MaterialApp(
      home: const SizedBox.shrink(),
      onGenerateRoute: (_) => rotta,
    ));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: Builder(builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(artRouteFor('synastry_vip',
                userBirth: DateTime(1990, 8, 10), userName: 'Mauro')!);
          });
          return const SizedBox.shrink();
        }),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // ignore: avoid_print
    print('ORDINE CA VOCE 1: aprendo la Sinastria VIP si monta '
        '${find.byType(PortaDellaSinastria).evaluate().isNotEmpty ? "la porta" : "altro"}');
    expect(find.byType(PortaDellaSinastria), findsOneWidget,
        reason: 'la Sinastria VIP non apre sulla porta con le due carte');
    expect(find.byType(SinastriaGalleryScreen), findsNothing,
        reason: 'la Sinastria VIP apre ancora sul catalogo dei volti');
  });
  testWidgets('CA.02: la carta che si tocca e\' la carta che cambia',
      (tester) async {
    await monta(tester);
    final primo = VipCatalog.vips[2];
    final secondo = VipCatalog.vips[5];

    // Prima si riempie la casella di DESTRA, come farebbe chiunque.
    await tester.tap(find.byKey(const Key('sinastria_carta_da_scegliere')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await scegliDallaGalleria(tester, secondo);
    expect(find.text(secondo.name), findsWidgets,
        reason: 'la carta di destra non ha preso il volto scelto');

    // **E ADESSO SI TOCCA QUELLA DI SINISTRA**, che e' il gesto del difetto.
    await tester.tap(find.byKey(const Key('sinastria_carta_tua')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await scegliDallaGalleria(tester, primo);

    // La casella di sinistra porta il primo, quella di destra ancora il
    // secondo: nessuna delle due ha preso il posto dell'altra.
    final sotto = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('sinastria_carta_tua')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    final sottoDestra = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('sinastria_carta_da_scegliere')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    // ignore: avoid_print
    print('ORDINE CA VOCE 2: a sinistra $sotto, a destra $sottoDestra');
    expect(sotto.join(' '), contains(primo.name),
        reason: 'ho toccato la carta di sinistra e il volto scelto non e\' '
            'finito li\': e\' il difetto che il fondatore ha visto');
    expect(sottoDestra.join(' '), contains(secondo.name),
        reason: 'toccando la carta di sinistra e\' cambiata quella di destra');
  });

  testWidgets('CA.01: la galleria di scelta restituisce il volto e non apre '
      'il responso', (tester) async {
    await monta(tester);
    await tester.tap(find.byKey(const Key('sinastria_carta_da_scegliere')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await scegliDallaGalleria(tester, VipCatalog.vips[3]);
    // Si torna alla porta, non si apre nessun responso.
    expect(find.byType(PortaDellaSinastria), findsOneWidget);
    expect(find.byType(SinastriaGalleryScreen), findsNothing,
        reason: 'la galleria e\' rimasta aperta dopo la scelta');
    expect(find.byKey(const Key('sinastria_fai_il_confronto')), findsOneWidget,
        reason: 'il bottone che apre il responso non c\'e\'');
  });
}
