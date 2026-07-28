import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/angels_screen.dart';
import 'package:esoteric_circle/features/identity/widgets/birth_companions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata dei tre Angeli, la tessera che la apre e i compagni di nascita
/// nella carta natale.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  final conOra = BirthIdentity.fromParts(
    birthDate: DateTime(1985, 3, 3),
    birthHour: 7,
    birthMinute: 20,
  );
  final senzaOra = BirthIdentity.fromParts(birthDate: DateTime(1985, 3, 3));

  Widget host(Widget child, {bool riduciMovimento = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: riduciMovimento),
            child: MaestroScope(child: child),
          ),
        ),
      );

  void schermo(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Mostra tre carte con tre arti distinte, non ripieghi dipinti',
      (tester) async {
    silence();
    schermo(tester);
    await tester.pumpWidget(host(AngelsScreen(identity: conOra)));
    await passo(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(find.byKey(const Key('angelo_custode')), findsOneWidget);
    expect(find.byKey(const Key('angelo_cuore')), findsOneWidget);
    expect(find.byKey(const Key('angelo_intelletto')), findsOneWidget);

    // Le tre immagini vengono davvero dalla cartella degli angeli, e sono tre
    // file diversi: se fossero ripieghi dipinti non ci sarebbe nessuna Image.
    final immagini = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName)
        .where((n) => n.contains('assets/img/angeli/'))
        .toSet();
    expect(immagini.length, greaterThanOrEqualTo(3),
        reason: 'tre arti distinte dalla cartella degli angeli');

    // La spiegazione di come sono scelti c'e', col disclaimer una volta sola.
    expect(find.byKey(const Key('angeli_come_scelti')), findsOneWidget);
    expect(find.byKey(const Key('angeli_disclaimer')), findsOneWidget);
  });

  testWidgets('Senza ora il terzo angelo non si mostra come noto',
      (tester) async {
    silence();
    schermo(tester);
    await tester.pumpWidget(host(AngelsScreen(identity: senzaOra)));
    await passo(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(find.byKey(const Key('angelo_intelletto')), findsNothing);
    expect(find.byKey(const Key('angelo_intelletto_assente')), findsOneWidget);
    expect(find.textContaining('ora'), findsWidgets);
    // Gli altri due restano.
    expect(find.byKey(const Key('angelo_custode')), findsOneWidget);
    expect(find.byKey(const Key('angelo_cuore')), findsOneWidget);
  });

  testWidgets('L\'ingresso e\' un trionfo, e con Riduci Movimento e\' fermo',
      (tester) async {
    silence();
    schermo(tester);

    // Con animazioni: al primo frame le carte non sono ancora posate.
    await tester.pumpWidget(host(AngelsScreen(identity: conOra)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final durante = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(durante.any((o) => o.opacity < 0.99), isTrue,
        reason: 'a inizio corsa qualcosa sta ancora entrando');
    expect(AngelsScreen.ingresso.inMilliseconds, greaterThan(0));
    expect(AngelsScreen.ingresso.inMilliseconds, lessThanOrEqualTo(2500),
        reason: 'e\' un trionfo, non un\'attesa');

    // A corsa finita tutto e' posato.
    await tester.pump(const Duration(seconds: 3));
    final dopo = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(dopo.every((o) => o.opacity > 0.99), isTrue);

    // Con Riduci Movimento: gia' posato al primo frame, nessun moto.
    await tester.pumpWidget(
        host(AngelsScreen(identity: conOra), riduciMovimento: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final fermo = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(fermo.every((o) => o.opacity > 0.99), isTrue,
        reason: 'con Riduci Movimento le carte sono gia\' in posa');
  });

  testWidgets('I compagni di nascita stanno nella carta natale',
      (tester) async {
    silence();
    schermo(tester);
    await tester.pumpWidget(host(Scaffold(
      body: SingleChildScrollView(
        child: BirthCompanions(
          details: conOra.toBirthDetails(),
          identity: conOra,
        ),
      ),
    )));
    await passo(tester);

    expect(find.byKey(const Key('carta_animale_guida')), findsOneWidget);
    expect(find.byKey(const Key('carta_angeli')), findsOneWidget);

    // I tre nomi sono quelli calcolati, non un elenco fisso.
    final triade = GuardianAngels.forBirth(conOra.toBirthDetails());
    expect(triade.known.length, 3);
    expect(find.textContaining(triade.guardian.name), findsWidgets);

    // Al tocco si aprono i tre Angeli.
    await tester.tap(find.byKey(const Key('carta_angeli')));
    await passo(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('angels_screen')), findsOneWidget);
  });

  testWidgets('La tessera della carta natale mostra TRE miniature',
      (tester) async {
    silence();
    schermo(tester);
    await tester.pumpWidget(host(Scaffold(
      body: SingleChildScrollView(
        child: BirthCompanions(
          details: conOra.toBirthDetails(),
          identity: conOra,
        ),
      ),
    )));
    await passo(tester);

    // Si contano DENTRO la tessera, dove l'utente le vede, non nella
    // schermata dedicata, dove il conto tornava mentre a schermo ne compariva
    // una sola. La misura va presa dove sta la promessa.
    final tessera = find.byKey(const Key('carta_angeli'));
    expect(tessera, findsOneWidget);
    final arti = tester
        .widgetList<Image>(find.descendant(
            of: tessera, matching: find.byType(Image)))
        .map((i) => (i.image as AssetImage).assetName)
        .where((n) => n.contains('angeli'))
        .toSet();
    expect(arti.length, 3,
        reason: 'tre angeli, tre volti: ne ho contati ${arti.length}');
  });

  testWidgets('La schermata porta la nota Fonti e metodo', (tester) async {
    silence();
    schermo(tester);
    await tester.pumpWidget(host(AngelsScreen(identity: conOra)));
    await passo(tester);

    final punto = find.byKey(const Key('angeli_fonti_metodo'));
    expect(punto, findsOneWidget);
    await tester.tap(punto);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fonti e metodo'), findsOneWidget);
    // La frase scomoda c'e', ed e' quella che conta.
    final nota = tester.widget<Text>(
        find.byKey(const Key('angeli_nota_edizioni')));
    expect(nota.data, contains('edizione primaria'));
    expect(nota.data, contains('Lenain'));
    expect(nota.data, contains('Ambelain'));
  });

  test('Il catalogo copre i nove cori con otto angeli ciascuno', () {
    for (final coro in AngelCatalog.choirs) {
      final dentro =
          AngelCatalog.all.where((a) => a.choir.name == coro.name).length;
      expect(dentro, 8, reason: 'il coro ${coro.name} ha $dentro angeli');
    }
  });
}
