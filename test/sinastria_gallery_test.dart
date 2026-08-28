import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La galleria di apertura della Sinastria VIP: si sceglie il VIP, poi il
/// responso. Ricerca, filtri di categoria, tasto A caso, griglia dei volti.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> pump(WidgetTester tester, {math.Random? random}) async {
    silenceSensors();
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        // ORDINE BO VOCE 13: la galleria mostra quante coppie hai
        // scoperto, quindi la collezione le serve davvero.
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SinastriaGalleryScreen(userSign: Zodiac.gemini, random: random),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('La galleria mostra ricerca, la tendina e la griglia',
      (tester) async {
    // **LA FILA DI PULSANTI E LA SEZIONE IN EVIDENZA NON CI SONO PIU'.**
    // Parole del fondatore del 28 agosto 2026: "elimina la sezione Vip in
    // evidenza che non serve a nulla" e "anziche' usare un pulsante per ogni
    // categoria, usa un unico selettore menu' a tendina Categoria VIP con
    // tutte le opzioni". Il VIP a caso resta, spostato accanto alla ricerca:
    // toglierlo non l'ha chiesto nessuno.
    await pump(tester);
    expect(find.byKey(const Key('sinastria_gallery')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_search')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_random')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_categoria')), findsOneWidget,
        reason: 'la tendina delle categorie non c\'e\'');
    expect(find.byKey(const Key('sinastria_filter_Tutti')), findsNothing,
        reason: 'la fila di pulsanti per categoria e\' tornata');
    expect(find.text('VIP in evidenza'), findsNothing,
        reason: 'la sezione in evidenza e\' tornata');
    // Il primo VIP della griglia c'e'.
    expect(find.byKey(Key('vip_${VipCatalog.first.name}')), findsOneWidget);
  });

  testWidgets('La ricerca filtra i VIP per nome, dal vivo', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('sinastria_search')), 'messi');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vip_Lionel Messi')), findsOneWidget);
    // Un VIP che non contiene "messi" sparisce dalla griglia.
    expect(find.byKey(const Key('vip_Angelina Jolie')), findsNothing);
  });

  testWidgets('Un nome inesistente svuota la griglia con un messaggio',
      (tester) async {
    await pump(tester);
    await tester.enterText(
        find.byKey(const Key('sinastria_search')), 'zzzznessuno');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sinastria_gallery_empty')), findsOneWidget);
  });

  testWidgets('La tendina delle categorie restringe la griglia',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('sinastria_categoria')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sinastria_categoria_Sport')).last);
    await tester.pumpAndSettle();
    // Un VIP Sport resta, uno di un'altra categoria sparisce.
    expect(find.byKey(const Key('vip_Roger Federer')), findsOneWidget);
    expect(find.byKey(const Key('vip_Taylor Swift')), findsNothing);
  });

  testWidgets('Il tasto A caso pesca un VIP valido e apre il responso',
      (tester) async {
    await pump(tester, random: math.Random(5));
    final atteso = VipCatalog.vips[math.Random(5).nextInt(VipCatalog.vips.length)];
    await tester.tap(find.byKey(const Key('sinastria_random')));
    await tester.pumpAndSettle();
    // Il responso e' aperto sul VIP pescato, che appartiene al catalogo.
    expect(find.byKey(const Key('sinastria_gauge')), findsOneWidget);
    final ritratto = tester.widget<VipFramedPortrait>(
      find.descendant(
        of: find.byKey(const Key('sinastria_pole_vip')),
        matching: find.byType(VipFramedPortrait),
      ),
    );
    expect(ritratto.name, atteso.name);
    expect(VipCatalog.vips.map((v) => v.name), contains(ritratto.name));
  });

  testWidgets('Scegliere un VIP apre il responso su quel VIP', (tester) async {
    await pump(tester);
    final scelto = VipCatalog.first;
    await tester.tap(find.byKey(Key('vip_${scelto.name}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sinastria_list')), findsOneWidget);
    final ritratto = tester.widget<VipFramedPortrait>(
      find.descendant(
        of: find.byKey(const Key('sinastria_pole_vip')),
        matching: find.byType(VipFramedPortrait),
      ),
    );
    expect(ritratto.name, scelto.name);
  });

  testWidgets('Il tasto Cambia VIP riporta alla galleria', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(Key('vip_${VipCatalog.first.name}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sinastria_list')), findsOneWidget);
    // **IL RESPONSO E' PIU' LUNGO, ordine CA voce 04**: sopra la bolla c'e' il
    // suo titolo e sotto la nota, quindi il tasto Cambia VIP non e' piu' in
    // prima schermata. Si porta sotto gli occhi prima di toccarlo.
    await tester.scrollUntilVisible(
        find.byKey(const Key('sinastria_change_vip')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(const Key('sinastria_change_vip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sinastria_change_vip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sinastria_gallery')), findsOneWidget);
  });
}
