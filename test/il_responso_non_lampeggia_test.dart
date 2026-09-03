import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL RESPONSO NON LAMPEGGIA. Ordine BN voce 03.
///
/// Parole del fondatore: "quando l'utente sceglie la terza o ultima Carta si
/// vede per un attimo immediatamente la risposta e dopo un attimo parte
/// l'animazione di riflessione, e' proprio una visione lampo molto fastidiosa
/// in cui si vede gia' il responso e poi sopra parte l'animazione".
///
/// **La causa era la stessa forma di difetto dell'ordine BK**: due stati
/// diversi che condividevano lo stesso valore. Il responso si mostrava se la
/// stesa era compiuta e l'attesa non era PIENA, ma `assente` valeva sia prima
/// che l'attesa cominciasse sia dopo che era finita. Fra il tocco della terza
/// carta e l'inizio dell'attesa c'e' la fioritura dell'elemento, che dura: in
/// quella finestra il responso entrava in albero.
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

  /// Tutto il testo che l'albero dipinge adesso.
  /// **LA SCENA DELL'ATTESA NON E' RESPONSO, e va tolta dal conto.** Mentre
  /// Medora pensa, la sua scena porta righe sue, che prima della terza carta
  /// non c'erano: contarle vorrebbe dire accusare del lampo proprio la cosa
  /// che il lampo lo copre.
  String testoInAlbero(WidgetTester tester) {
    // Fuori dal conto due cose che non sono responso: la scena dell'attesa,
    // che porta le righe di Medora mentre pensa, e le CARTE, che portano il
    // proprio nome. Un nome che compare perche' la carta si e' scoperta non e'
    // il responso: il responso e' il consiglio, le tre bolle e la domanda.
    final daTogliere = <String>{};
    for (final chiave in const ['stesa_attesa', 'stesa_slots']) {
      final dove = find.byKey(Key(chiave));
      if (dove.evaluate().isEmpty) continue;
      for (final t in tester.widgetList<Text>(
          find.descendant(of: dove, matching: find.byType(Text)))) {
        if (t.data != null) daTogliere.add(t.data!);
      }
      for (final r in tester.widgetList<RichText>(
          find.descendant(of: dove, matching: find.byType(RichText)))) {
        daTogliere.add(r.text.toPlainText());
      }
    }
    final pezzi = <String>[];
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      if (t.data != null && !daTogliere.contains(t.data)) pezzi.add(t.data!);
    }
    for (final r in tester.widgetList<RichText>(find.byType(RichText))) {
      final testo = r.text.toPlainText();
      if (!daTogliere.contains(testo)) pezzi.add(testo);
    }
    return pezzi.join('\n');
  }

  /// Quanti caratteri del RESPONSO sono a video adesso.
  ///
  /// Il responso non si scrive qui: si prende quello che la scena mostra a
  /// lettura finita, e si contano i suoi tratti lunghi. Cosi' la prova non
  /// dipende da nessun corpus battuto dentro, e resta vera se domani i testi
  /// cambiano.
  int caratteriDi(List<String> tratti, String aVideo) {
    var quanti = 0;
    for (final t in tratti) {
      if (aVideo.contains(t)) quanti += t.length;
    }
    return quanti;
  }

  /// I TRATTI CHE APPARTENGONO AL SOLO RESPONSO.
  ///
  /// Non tutto il testo a schermo e' responso: i nomi delle carte, il pannello
  /// delle scelte e i titoli ci sono anche prima. Si tengono solo i tratti che
  /// a stesa compiuta ci sono e che prima della terza carta non c'erano, cosi'
  /// la prova conta il responso e non la scena.
  List<String> trattiDelResponso(String dopo, String prima) {
    final soli = <String>[];
    for (var i = 0; i + 20 <= dopo.length; i += 20) {
      final t = dopo.substring(i, i + 20);
      if (!prima.contains(t)) soli.add(t);
    }
    return soli;
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    // **PRIMA SI PREME PER COMINCIARE. Ordine CO voce 07**, 3 settembre 2026:
    // il fondatore ha chiesto un pulsante esplicito, e il ventaglio non
    // risponde piu' a chi non ha cominciato. Il pulsante c'e' solo prima della
    // prima carta, quindi da qui in poi questa riga non fa niente.
    final inizia = find.byKey(const Key('stesa_inizia'));
    if (tester.widgetList(inizia).isNotEmpty) {
      await tester.tap(inizia, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget,
        reason: 'la carta $indice non e\' nell\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
  }

  testWidgets('dalla terza carta alla fine dell\'attesa il responso non c\'e\'',
      (tester) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(attorno(const StesaTreCarteScreen(
      seed: 2,
      skipIntro: true,
      topic: TarotTopic.bivio,
    )));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Le prime due carte: qui il responso non c'e' comunque.
    await pesca(tester, 38);
    await tester.pump(const Duration(seconds: 5));
    await pesca(tester, 39);
    await tester.pump(const Duration(seconds: 5));

    // LA TERZA, ed e' l'istante del difetto. Da qui si guarda fotogramma per
    // fotogramma, senza saltare nulla.
    await pesca(tester, 40);

    // Si lascia finire tutto: fioritura, attesa e dissolvenza. Un'attesa
    // abbondante e non un ciclo che si ferma al primo responso visto, o col
    // difetto reintrodotto questo giro si fermerebbe sul lampo invece che
    // sulla scena finita, e il rosso nominerebbe la cosa sbagliata.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    final aStesaCompiuta = testoInAlbero(tester);
    expect(find.byKey(const Key('stesa_synthesis')), findsOneWidget,
        reason: 'il responso non e\' mai comparso: la prova non sta guardando '
            'la scena giusta');
    expect(aStesaCompiuta.length, greaterThan(200));

    // Adesso si rifa' la stessa strada, contando i caratteri a ogni passo.
    //
    // **LA CHIAVE NUOVA NON E' UN VEZZO**: senza, Flutter riconosce lo stesso
    // widget e riusa lo State, quindi il secondo giro ripartirebbe da una
    // stesa gia' compiuta e la prova misurerebbe una scena che non esiste.
    await tester.pumpWidget(attorno(StesaTreCarteScreen(
      key: UniqueKey(),
      seed: 2,
      skipIntro: true,
      topic: TarotTopic.bivio,
    )));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await pesca(tester, 38);
    await tester.pump(const Duration(seconds: 5));
    await pesca(tester, 39);
    await tester.pump(const Duration(seconds: 5));

    // La scena PRIMA della terza carta: quello che c'e' qui non e' responso.
    final primaDellaTerza = testoInAlbero(tester);
    final tratti = trattiDelResponso(aStesaCompiuta, primaDellaTerza);
    expect(tratti.length, greaterThanOrEqualTo(8),
        reason: 'il responso riconosciuto e\' troppo corto: la prova non sta '
            'guardando il testo giusto');

    await pesca(tester, 40);
    // IL PRIMO FOTOGRAMMA DOPO LA TERZA CARTA, che e' quello del lampo.
    expect(caratteriDi(tratti, testoInAlbero(tester)), 0,
        reason:
            'nel primo fotogramma dopo la terza carta il responso e\' gia\' '
            'in albero: e\' esattamente la visione lampo che il fondatore ha '
            'visto');

    var trascorso = 0;
    while (find.byKey(const Key('stesa_synthesis')).evaluate().isEmpty &&
        trascorso < 12000) {
      await tester.pump(const Duration(milliseconds: 100));
      trascorso += 100;
      if (find.byKey(const Key('stesa_synthesis')).evaluate().isNotEmpty) break;
      expect(caratteriDi(tratti, testoInAlbero(tester)), 0,
          reason: 'a $trascorso millesimi dalla terza carta il responso non '
              'deve essere in albero: Medora sta ancora pensando');
    }
    expect(trascorso, greaterThan(0));
    await tester.pump(const Duration(seconds: 8));
  });
}
