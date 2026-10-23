// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **IL SEGNAPOSTO DEL GENERE NON ARRIVA MAI A VIDEO, NELLA STESA.** Ordine
/// GA voce GA.06, 21 ottobre 2026.
///
/// **IL FATTO.** Il lettore cieco dei Tarocchi (`docs/collaudo/GA/
/// lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`, difetto 9) ha letto in
/// tutte e dieci le Croci Celtiche del campione *"La Papessa ([te stesso|te
/// stessa|tu])"*: la posizione "Te stesso" porta la marca del genere a tre vie
/// (`SpreadPosition.seStesso`, ordine FI voce 05), e due punti la scrivevano
/// col nome grezzo, `label`, invece che con l'etichetta risolta: il "Da dove
/// viene" della consultazione (`TarotReading.daDoveViene`) e la riga della
/// posizione sopra ogni bolla di carta nella schermata. Arrivava a video cosi'.
///
/// **CHE COSA SI MISURA.** Il testo che la persona legge, non il codice che lo
/// scrive: (1) ogni pezzo della lettura (titolo, risposta, cosa fare, "Da dove
/// viene", ogni carta col suo titolo, paragrafo e riquadro) in tutte le stese,
/// con molte estrazioni; (2) ogni `Text` e ogni `RichText` della schermata
/// vera aperta sulla Croce Celtica, con la carta "Te stesso" a video. Una
/// marca e' una quadra con dentro almeno una barra verticale.
final RegExp _marca = RegExp(r'\[[^\]]*\|[^\]]*\]');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('nessuna lettura, in nessuna stesa, porta una marca grezza', () {
    final guasti = <String>[];
    var pezzi = 0;
    var conTeStesso = 0;
    for (final tipo in TarotSpreadType.values) {
      for (var seme = 0; seme < 40; seme++) {
        final s =
            TarotSpread.draw(seed: seme * 13 + 1, posizioni: tipo.posizioni);
        if (s.cards.any((c) => c.position == SpreadPosition.seStesso)) {
          conTeStesso++;
        }
        final r = TarotReading.of(s, TarotTopic.values[seme % 16],
            mazzo: 'Rider-Waite', nomeDellaStesa: tipo.nome);
        final testi = <String>[
          r.titolo,
          r.principale.risposta,
          r.principale.cosaFare,
          r.fonte,
          for (final p in r.posizioni) ...[
            p.apertura,
            p.testo,
            if (p.responso case final c?) ...[c.titolo, c.risposta, c.cosaFare],
          ],
          for (final c in s.cards) c.position.etichetta,
        ];
        for (final t in testi) {
          pezzi++;
          if (_marca.hasMatch(t)) {
            guasti.add('${tipo.name} seme $seme: "${_marca.firstMatch(t)![0]}" '
                'in "${t.length > 90 ? '${t.substring(0, 90)}...' : t}"');
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: pezzi di lettura guardati $pezzi, stese con la '
        'carta "Te stesso" $conTeStesso, marche grezze ${guasti.length}');
    cardinaleMinimo(conTeStesso, 40,
        cosa: 'stese con la posizione "Te stesso"',
        perche: 'Senza la Croce Celtica la marca della posizione non entra '
            'mai nel conto.');
    cardinaleMinimo(pezzi, 4 * 40 * 6, cosa: 'pezzi di lettura guardati');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  testWidgets('la Croce Celtica a video non mostra una marca grezza',
      (tester) async {
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
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
    tester.view.physicalSize = const Size(360, 12000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(
          child: StesaTreCarteScreen(
            seed: 2,
            revealAll: true,
            skipIntro: true,
            topic: TarotTopic.bivio,
            tipo: TarotSpreadType.dieciCarte,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    final stesa = tester
        .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
        .stesaCorrente;
    expect(
        stesa.cards.any((c) => c.position == SpreadPosition.seStesso), isTrue,
        reason: 'la Croce Celtica a video non ha la carta "Te stesso": la '
            'prova non guarderebbe la marca');
    expect(find.byKey(const Key('stesa_letta_seStesso')), findsOneWidget,
        reason: 'la bolla della carta "Te stesso" non e\' a video');
    final testi = <String>[
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        t.data ?? t.textSpan?.toPlainText() ?? '',
      for (final r in tester.widgetList<RichText>(find.byType(RichText)))
        r.text.toPlainText(),
    ];
    final guasti = [
      for (final t in testi)
        if (_marca.hasMatch(t)) _marca.firstMatch(t)![0]!,
    ];
    print('ORDINE GA VOCE 06: testi a video nella Croce Celtica '
        '${testi.length}, marche grezze ${guasti.length} $guasti');
    cardinaleMinimo(testi.length, 60,
        cosa: 'testi a video nella Croce Celtica');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });
}
