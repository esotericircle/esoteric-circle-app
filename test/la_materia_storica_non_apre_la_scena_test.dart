import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/design_system/components/da_dove_nasce.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA MATERIA STORICA NON APRE LA SCENA.** Ordine CQ voce 6.27, 5 settembre
/// 2026.
///
/// **Trovato a video sul telefono del fondatore**, durante il collaudo che lui
/// stesso aveva chiesto: aprendo l'Estrazione Rune, prima ancora di gettare, la
/// schermata mostrava Tacito e la Germania al capitolo dieci, l'Edda poetica,
/// la Voluspa, la Gylfaginning di Snorri Sturluson e il metodo di calcolo. Un
/// muro di quattrocento caratteri di materia storica, aperto, sopra il gesto.
///
/// **E' esattamente cio' che la legge del mood vieta**, con le parole del
/// fondatore del 2 settembre: *"l'utente non cerca informazioni, cerca risposte
/// e vuole essere guidato. non gliene frega niente di transiti, pianeti, ecc.
/// non dico di non scrivere da dove arrivano le risposte, ma non all'inizio."*
///
/// **La grandezza misurata e' la materia storica A VISTA PRIMA DEL GESTO**, e
/// non la sua presenza: quel testo deve esserci, perche' e' la promessa che
/// nulla e' inventato. Deve stare dietro la porta.
///
/// **PERCHE' NESSUNA GUARDIA L'AVEVA PRESO.** La guardia del mood sorveglia i
/// titoli dei Doni e l'unicita' della porta; quella delle bolle delle rune
/// sorveglia il RESPONSO, cioe' cio' che arriva dopo il getto. Nessuna delle
/// due guarda la scena PRIMA del gesto, ed e' li' che il muro viveva.
void main() {
  void silenceSensors(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
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

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(
                  initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: Tier.tier1)),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
        ),
      );

  /// **LA FINESTRA E' QUELLA DI UN TELEFONO VERO**, 390 per 844: sul default
  /// da 800 per 600 la scena si stende e la misura parla di un layout che
  /// nessuno vede.
  Future<void> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    silenceSensors(tester);
    await tester.pumpWidget(host());
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('la materia storica della gettata sta dietro la porta',
      (tester) async {
    await monta(tester);

    /// I testi storici delle quattro gettate, presi dal corpus e non
    /// riscritti qui: due copie della stessa frase divergono al primo
    /// ritocco del corpus, e la guardia smetterebbe di cercare cio' che
    /// esiste davvero.
    final materia = <String, String>{
      for (final g in gettate) g.nome: g.testoDinamico,
    };
    cardinaleMinimo(materia.length, 3,
        cosa: 'gettate del corpus con la loro materia storica',
        perche: 'Con poche gettate questa prova direbbe che nessun muro apre '
            'la scena per non averne cercati abbastanza.');

    /// Il testo montato a vista, letto dai `ParagrafiDiLettura` e dai `Text`
    /// che NON stanno dietro la porta.
    final dietroLaPorta = find.descendant(
      of: find.byType(DaDoveNasce),
      matching: find.byType(Text),
    );
    final nascosti = dietroLaPorta.evaluate().toSet();
    final aVista = <String>[];
    for (final e in find.byType(Text).evaluate()) {
      if (nascosti.contains(e)) continue;
      final t = (e.widget as Text).data ?? '';
      if (t.trim().isEmpty) continue;
      aVista.add(t);
    }
    final tuttoAVista = aVista.join(' ');

    /// **SI CERCA UN PEZZO LUNGO E CARATTERISTICO**, non la stringa intera:
    /// il testo si spezza in paragrafi, quindi la stringa intera non compare
    /// mai come un blocco solo e cercarla darebbe verde sempre.
    final colpe = <String>[];
    for (final voce in materia.entries) {
      final pezzo = voce.value.length > 60
          ? voce.value.substring(0, 60)
          : voce.value;
      if (tuttoAVista.contains(pezzo)) {
        colpe.add('${voce.key}: "$pezzo..."');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.27: blocchi di testo a vista prima del gesto '
        '${aVista.length}, dei quali materia storica ${colpe.length}');
    cardinaleMinimo(aVista.length, 3,
        cosa: 'blocchi di testo a vista nella scena prima del gesto',
        perche: 'Con la scena vuota non ci sarebbe nessun muro da trovare, e '
            'la prova sarebbe verde per non aver montato niente.');
    expect(colpe, isEmpty,
        reason: 'la materia storica della gettata apre la scena invece di '
            'stare dietro il tocco:\n  ${colpe.join("\n  ")}\n'
            'Chi arriva qui vuole gettare, non leggere Tacito: la fonte resta, '
            'e scende dietro la porta come in tutte le altre arti.');
  });

  testWidgets('e la porta c e, con dentro la materia', (tester) async {
    await monta(tester);
    final porta = find.byType(DaDoveNasce);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.27: porte "Da dove nasce" nella scena '
        '${porta.evaluate().length}');
    expect(porta, findsOneWidget,
        reason: 'l Estrazione Rune non ha la porta comune: senza, la materia '
            'storica o apre la scena o sparisce, e sparire vorrebbe dire '
            'rompere la promessa che nulla e inventato');
    final dentro = find.descendant(
      of: porta, matching: find.byType(Text));
    expect(dentro, findsWidgets,
        reason: 'la porta c e ma non ha niente dietro: un tocco che apre sul '
            'nulla e peggio di nessun tocco');
  });
}
