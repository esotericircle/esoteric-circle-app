import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CARTA SI APRE AL TOCCO. Ordine BN voce 04.
///
/// Parole del fondatore: "voglio poter fare click su una carta e questa deve
/// ingrandirsi facendomi anche leggere i dettagli di quella carta che poi si
/// tratta della stessa descrizione che si trova sotto".
///
/// **La misura che conta e' che il testo sia LO STESSO**, carattere per
/// carattere, di quello della bolla: se fosse una seconda copia, al primo che
/// ne cambia una la carta direbbe una cosa e la bolla un'altra.
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

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  Widget attorno(Widget scena, {bool riduciMovimento = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester,
      {bool riduciMovimento = false}) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = const Size(360, 4400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(
      const StesaTreCarteScreen(
        seed: 2,
        revealAll: true,
        skipIntro: true,
        topic: TarotTopic.bivio,
      ),
      riduciMovimento: riduciMovimento,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  /// Il testo di un widget testuale, comunque sia dipinto.
  /// Gli spazi bianchi contano come uno: e' cio' che rende confrontabile un
  /// testo spezzato in blocchi con lo stesso testo scritto di seguito.
  String normalizza(String t) =>
      t.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Il testo che quel punto dell'albero mostra davvero, comunque sia montato.
  ///
  /// **La forma e' cambiata, la grandezza misurata no.** Il narrato della carta
  /// aperta passa dalla porta comune dei paragrafi, come pretende
  /// `etichette_e_lettura`, quindi sotto la chiave non c'e' piu' un `Text`
  /// solo ma i blocchi in cui quella porta lo dispone. Si raccolgono tutti e
  /// si confrontano le PAROLE, normalizzando gli spazi: dove il testo va a
  /// capo lo decide la porta comune ed e' una scelta di impaginazione, mentre
  /// cio' che questa prova difende e' che le due copie non esistano. Una
  /// parola cambiata da una parte fa cadere la prova come prima.
  String testoDi(WidgetTester tester, Finder dove) {
    final pezzi = <String>[
      for (final t in tester.widgetList<Text>(
          find.descendant(of: dove, matching: find.byType(Text))))
        if (t.data != null) t.data!,
    ];
    if (pezzi.isEmpty) {
      pezzi.addAll(tester
          .widgetList<RichText>(
              find.descendant(of: dove, matching: find.byType(RichText)))
          .map((r) => r.text.toPlainText()));
    }
    if (pezzi.isEmpty) {
      final diretto = tester.widgetList<Text>(dove);
      if (diretto.isNotEmpty && diretto.first.data != null) {
        pezzi.add(diretto.first.data!);
      }
    }
    return normalizza(pezzi.join(' '));
  }


  testWidgets('il testo della carta aperta e\' quello della bolla, uguale',
      (tester) async {
    await monta(tester);

    for (final posizione in SpreadPosition.values) {
      // Il testo della BOLLA, che e' la fonte.
      final bolla = find.byKey(Key('stesa_letta_${posizione.name}'));
      expect(bolla, findsOneWidget,
          reason: 'la bolla di ${posizione.name} non c\'e\': la prova non sta '
              'guardando la scena giusta');
      // I testi lunghi della bolla: la descrizione e', fra questi, quella che
      // l'ingrandimento deve mostrare IDENTICA. Non si concatenano, perche' la
      // bolla della carta chiave porta anche il perche', che e' un'altra cosa.
      // **IL TESTO NARRATO PASSA DA ParagrafiDiLettura, ordine BU voce 01**, e
      // li' dentro il testo intero sta nel suo campo `testo`: i Text che ne
      // escono sono i singoli paragrafi. Si guardano tutte e due le forme,
      // altrimenti la prova cercherebbe un blocco unico che non esiste piu'.
      final testiDellaBolla = <String>[
        for (final t in tester.widgetList<Text>(
            find.descendant(of: bolla, matching: find.byType(Text))))
          normalizza(t.data ?? ''),
        for (final p in tester.widgetList<ParagrafiDiLettura>(
            find.descendant(of: bolla, matching: find.byType(ParagrafiDiLettura))))
          normalizza(p.testo),
      ].where((t) => t.length > 40).toList();
      expect(testiDellaBolla, isNotEmpty);

      // La carta si apre.
      final carta = find.byKey(Key('stesa_apri_${posizione.name}'));
      expect(carta, findsOneWidget,
          reason: 'la carta di ${posizione.name} non risponde al tocco');
      await tester.tap(carta, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final aperta = find.byKey(const Key('carta_ingrandita_testo'));
      expect(aperta, findsOneWidget,
          reason: 'la carta ${posizione.name} non si e\' aperta');
      expect(testiDellaBolla, contains(testoDi(tester, aperta)),
          reason: 'il testo della carta aperta non e\' nessuno di quelli della '
              'sua bolla: sono due copie, e al primo che ne cambia una '
              'diranno cose diverse');

      // Si chiude, e la scena torna quella di prima.
      Navigator.of(tester.element(find.byType(MaestroScope))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('carta_ingrandita_testo')), findsNothing);
    }
  });

  testWidgets('ogni carta ha almeno 48 per 48 punti di bersaglio',
      (tester) async {
    await monta(tester);
    for (final posizione in SpreadPosition.values) {
      final carta = find.byKey(Key('stesa_apri_${posizione.name}'));
      final r = tester.getRect(carta);
      expect(r.width, greaterThanOrEqualTo(48),
          reason: '${posizione.name}: il bersaglio e\' largo ${r.width}');
      expect(r.height, greaterThanOrEqualTo(48),
          reason: '${posizione.name}: il bersaglio e\' alto ${r.height}');
    }
  });

  testWidgets('con Riduci Movimento si apre gia\' composta, e il testo c\'e\'',
      (tester) async {
    await monta(tester, riduciMovimento: true);
    await tester.tap(find.byKey(const Key('stesa_apri_passato')),
        warnIfMissed: false);
    // UN SOLO fotogramma: senza movimento non c'e' niente da aspettare, e il
    // testo dev'essere gia' li'.
    await tester.pump();
    expect(find.byKey(const Key('carta_ingrandita_testo')), findsOneWidget,
        reason: 'con Riduci Movimento la carta deve aprirsi gia\' composta: '
            'chi ha tolto le animazioni non ha chiesto di rinunciare ai '
            'dettagli della carta');
    expect(find.byKey(const Key('carta_ingrandita_figura')), findsOneWidget);
    Navigator.of(tester.element(find.byType(MaestroScope))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
