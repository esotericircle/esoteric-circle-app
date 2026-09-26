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

/// MEDORA NON RESTA SOLA FRA L'ULTIMA CARTA E LA RIFLESSIONE.
/// Ordine BZ voce 07.
///
/// **Parole del fondatore.** "Quando scelgo l'ultima carta e parte
/// l'animazione di riflessione prima di tutto si vede per un secondo circa
/// Medora da sola e poi parte l'animazione: ELIMINA LA PRIMA PARTE DOVE SI
/// VEDE MEDORA DA SOLA."
///
/// **Cosa c'era davvero.** Alla terza carta la stesa diventa compiuta, e da
/// quell'istante la lista della scena teneva soltanto il ritratto di Medora:
/// il pannello, il ventaglio e i tre slot erano appesi a `!_complete`, mentre
/// il responso e le sue carte erano appesi a `_responsoInScena`, che e' falso
/// finche' Medora non ha finito di pensare. Fra i due c'era un buco, e in quel
/// buco giravano due animazioni che nessuno poteva vedere: la fioritura
/// dell'elemento della terza carta, da 780 o 1100 millisecondi, e il filo fra
/// le carte dell'ordine BN voce 08, da altri 720. Un secondo e mezzo abbondante
/// di ritratto solo, ed e' esattamente il secondo che il fondatore ha contato.
///
/// **LA GRANDEZZA MISURATA E' IL NUMERO DI FOTOGRAMMI IN CUI LO SCHERMO NON
/// MOSTRA NE' LE CARTE NE' LA RIFLESSIONE**, dal tocco dell'ultima carta fino
/// al responso. Non la durata di un'animazione e non una soglia di tempo: una
/// scena che non ha piu' niente da mostrare si riconosce da cosa c'e' in
/// albero, e quel conto deve essere zero.
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

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(child: scena),
        ),
      );

  /// **IL GESTO CHE APRE LA LETTURA. Ordine CQ voce 1.03**, 3 settembre
  /// 2026. Si aspetta che l'ultima carta sia arrivata nel suo slot, cioe' che
  /// il pulsante si accenda, e lo si preme senza nessun pump dopo: da quel
  /// tocco comincia l'istante che questa guardia osserva fotogramma per
  /// fotogramma. Prima dell'ordine CQ quell'istante era la terza carta.
  Future<void> premi(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        await tester.tap(pulsante, warnIfMissed: false);
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    fail('il pulsante che apre il responso non si e mai acceso');
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key("stesa_fan_$indice"));
    expect(carta, findsOneWidget, reason: "la carta $indice non e nell arco");
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
  }

  bool inAlbero(String chiave) => find.byKey(Key(chiave)).evaluate().isNotEmpty;

  testWidgets(
      "Dall ultima carta al responso non c e un solo fotogramma di Medora sola",
      (tester) async {
    silenzia();
    await caricaCaratteri();
    // La finestra vera del telefono: con il difetto di misura della memoria
    // "finestra di prova irreale" una scena alta muore fuori campo.
    tester.view.physicalSize = const Size(390, 1600);
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

    await pesca(tester, 38);
    await tester.pump(const Duration(seconds: 5));
    await pesca(tester, 39);
    await tester.pump(const Duration(seconds: 5));

    // L ULTIMA CARTA. Da qui si guarda fotogramma per fotogramma.
    await pesca(tester, 40);
    await premi(tester);

    var sola = 0;
    var conLeCarte = 0;
    var conLaRiflessione = 0;
    var fotogrammi = 0;
    final vuoti = <int>[];
    for (var t = 0; t < 6000; t += 100) {
      fotogrammi++;
      final carte = inAlbero("stesa_slots");
      final riflessione = inAlbero("stesa_attesa");
      final responso = inAlbero("stesa_synthesis");
      if (carte) conLeCarte++;
      if (riflessione) conLaRiflessione++;
      if (!carte && !riflessione && !responso) {
        sola++;
        vuoti.add(t);
      }
      if (responso) break;
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Si lascia finire tutto, o il ticker resta acceso a fine prova.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // ignore: avoid_print
    print("ORDINE BZ VOCE 7: dall ultima carta al responso $fotogrammi "
        "fotogrammi, $conLeCarte con le carte, $conLaRiflessione con la "
        "riflessione, $sola con Medora sola");

    // Le due pretese che tengono in piedi la misura: se la riflessione non
    // fosse mai comparsa, oppure il responso non fosse mai arrivato, un conto
    // di zero non vorrebbe dire niente.
    expect(conLaRiflessione, greaterThan(3),
        reason: "la riflessione di Medora non e mai comparsa: la prova non "
            "sta guardando la scena giusta");
    expect(inAlbero("stesa_synthesis"), isTrue,
        reason: "il responso non e mai arrivato: la prova non sta guardando "
            "la scena giusta");

    expect(sola, 0,
        reason: "$sola fotogrammi su $fotogrammi non mostrano ne le carte ne "
            "la riflessione, ai millisecondi $vuoti dopo l ultima carta: e "
            "esattamente il secondo di Medora da sola che il fondatore ha "
            "visto");
  });
}
