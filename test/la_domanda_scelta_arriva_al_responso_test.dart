import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA DOMANDA SCELTA ARRIVA AL RESPONSO. Ordine S voce 21.
///
/// **Il difetto che questa voce chiude.** Il campo della domanda stava SOTTO il
/// getto, cioe' dopo: si gettava e poi si trovava il posto per una domanda che
/// non aveva piu' modo di entrare nella gettata. E i suggerimenti erano cinque
/// pillole qui piu' sessanta voci nelle chat, cioe' due elenchi della stessa
/// cosa in due case diverse.
///
/// **Cosa misurano queste prove.** Che la domanda si sceglie PRIMA, dalla
/// tendina, e che il testo scelto ARRIVA al responso: la persona lo ritrova a
/// schermo, e la lettura ne tiene conto. Se qualcuno smette di passare la
/// domanda al responso, il getto continuerebbe a funzionare e nessun'altra prova
/// si accorgerebbe di niente: la domanda sparirebbe in silenzio.
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
          ChangeNotifierProvider(create: (_) => EntitlementService()),
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

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('la domanda scelta dalla tendina si ritrova nel responso',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // **LA GRANDEZZA MISURATA E' IL TESTO DELLA DOMANDA, non la presenza della
    // scatola.** Una prova che chiedesse solo `rune_question_shown` passerebbe
    // anche con la scatola vuota, e la domanda si sarebbe persa comunque.
    final scelta = DomandeDelCerchio.generichePerLaGettata.first.testo;

    await tester.tap(find.byKey(const Key('rune_tendina_domande')));
    await passo(tester);
    await tester.tap(find.text(scelta).last);
    await passo(tester);

    final campo =
        tester.widget<TextField>(find.byKey(const Key('rune_question_field')));
    expect(campo.controller!.text, scelta,
        reason: 'la tendina non ha riempito il campo: la domanda si e\' persa '
            'fra la scelta e il campo');

    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);

    expect(find.byKey(const Key('rune_result')), findsOneWidget,
        reason: 'la gettata non e\' partita');
    // La scatola della domanda porta il testo scelto, dentro il responso.
    final mostrata = find.descendant(
      of: find.byKey(const Key('rune_question_shown')),
      matching: find.text(scelta),
    );
    expect(mostrata, findsOneWidget,
        reason: 'la domanda scelta NON arriva al responso: la persona ha '
            'chiesto "$scelta" e nel responso non la ritrova');
  });

  testWidgets('si puo\' ancora gettare senza domanda, e la riga lo dice',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // **LA DOMANDA NON DIVENTA UN PEDAGGIO.** Spostarla sopra il pulsante la
    // mette sulla strada del getto, ed e' esattamente il punto in cui una
    // schermata comincia a pretendere qualcosa prima di funzionare. La riga a
    // schermo dichiara che si puo' gettare senza, e questa prova lo fa.
    expect(find.byKey(const Key('rune_senza_domanda')), findsOneWidget,
        reason: 'la riga che dichiara la gettata senza domanda non c\'e\': '
            'la domanda sopra il pulsante sembrerebbe obbligatoria');

    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);

    expect(find.byKey(const Key('rune_result')), findsOneWidget,
        reason: 'senza domanda la gettata non parte: la domanda e\' diventata '
            'un pedaggio');
    expect(find.byKey(const Key('rune_question_shown')), findsNothing,
        reason: 'senza domanda il responso mostra comunque la scatola della '
            'domanda, e sarebbe vuota');
  });

  test('la domanda sta SOPRA il pulsante del getto, non sotto', () {
    // **SI GUARDA L'ORDINE DI DICHIARAZIONE nella colonna della soglia**, che e'
    // cio' che decide chi si legge prima: le parti vivono nella stessa lista di
    // figli, quindi qui l'ordine del sorgente E' l'ordine a schermo. La stessa
    // misura della voce S.19, per la stessa ragione.
    final sorgente =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    // **SI MISURA IL PUNTO DI CHIAMATA, non la casa della chiave.** La prima
    // stesura cercava `Key('rune_tendina_domande')`, che vive DENTRO il widget
    // della tendina, in fondo al file: la prova cadeva dicendo che la domanda sta
    // sotto il pulsante mentre a schermo stava sopra. Una prova che cade per la
    // ragione sbagliata non si aggiusta la soglia, si cambia la grandezza.
    final tendina = sorgente.indexOf('_TendinaDelleDomande(');
    final campo = sorgente.indexOf("Key('rune_question_field')");
    final pulsante = sorgente.indexOf("Key('rune_cast_button')");
    expect(tendina, greaterThan(0), reason: 'la tendina non c\'e\'');
    expect(campo, greaterThan(0), reason: 'il campo libero non c\'e\'');
    expect(pulsante, greaterThan(0), reason: 'il pulsante del getto non c\'e\'');
    expect(tendina, lessThan(pulsante),
        reason: 'la tendina delle domande e\' dichiarata DOPO il pulsante: si '
            'getta e poi si trova il posto per la domanda');
    expect(campo, lessThan(pulsante),
        reason: 'il campo della domanda e\' dichiarato DOPO il pulsante');
  });

  test('le domande della gettata vivono in UN punto solo', () {
    // **IL PRESIDIO DEL PUNTO UNICO.** Prima di questa voce le domande proposte
    // stavano in due case: cinque in `rune_cast.dart` e sessanta nella vista dei
    // suggerimenti della chat. Due elenchi della stessa cosa sono due elenchi da
    // tenere d'accordo a mano, e nessuna prova poteva dire quale fosse quello
    // giusto. Questa prova ENUMERA i file di `lib` e cade se un secondo elenco
    // di domande rinasce fuori dal punto unico.
    final casa = 'lib/core/domande/domande_del_cerchio.dart'.replaceAll('/', '');
    final colpevoli = <String>[];
    final domande = <String>{
      for (final d in DomandeDelCerchio.generichePerLaGettata) d.testo,
      for (final d in DomandeDelCerchio.personaliPerLaGettata) d.testo,
      for (final d in DomandeDelCerchio.dellaChat) d.testo,
    };
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (f.path.replaceAll('\\', '').replaceAll('/', '') == casa) continue;
      final testo = f.readAsStringSync();
      final quante = domande.where((d) => testo.contains(d)).length;
      // Una citazione sola puo' essere un esempio in un commento. Tre o piu'
      // testi di domanda nello stesso file sono un elenco.
      if (quante >= 3) colpevoli.add('${f.path}: $quante domande');
    }
    expect(colpevoli, isEmpty,
        reason: 'un secondo elenco di domande e\' nato fuori dal punto unico '
            '`DomandeDelCerchio`:\n${colpevoli.join("\n")}');
  });

  test('ogni domanda proposta e\' una domanda, e le personali dicono il dato',
      () {
    // ENUMERA l'elenco intero, non ne visita una: sono otto piu' otto piu'
    // sessanta, e una prova che ne guardasse una non direbbe niente delle altre.
    final rotte = <String>[];
    for (final d in [
      ...DomandeDelCerchio.generichePerLaGettata,
      ...DomandeDelCerchio.personaliPerLaGettata,
      ...DomandeDelCerchio.dellaChat,
    ]) {
      if (d.testo.trim().isEmpty) rotte.add('vuota');
      if (d.testo.length > 60) {
        rotte.add('${d.testo} (${d.testo.length} caratteri, non entra in riga)');
      }
      if (d.dove.isEmpty) rotte.add('${d.testo} (non dice dove serve)');
    }
    expect(rotte, isEmpty, reason: rotte.join('\n'));

    // **LE PERSONALI DELLA GETTATA DICHIARANO IL LORO DATO, tutte.** Una
    // personale senza dato passerebbe il filtro sempre, e nominerebbe cio' che
    // l'app non sa.
    final senzaDato = DomandeDelCerchio.personaliPerLaGettata
        .where((d) => d.dato == null)
        .map((d) => d.testo)
        .toList();
    expect(senzaDato, isEmpty,
        reason: 'queste personali non dichiarano il dato che le regge, quindi '
            'si mostrerebbero anche quando quel dato manca:\n'
            '${senzaDato.join("\n")}');

    // Otto e otto, come Mauro ha deciso.
    expect(DomandeDelCerchio.generichePerLaGettata.length, 8);
    expect(DomandeDelCerchio.personaliPerLaGettata.length, 8);
  });

  test('senza dati si mostrano le generiche e nessuna personale', () {
    // Il filtro e' la parte che tiene la promessa: senza dati addosso, l'elenco
    // delle personali resta vuoto invece di nominare Sole, Luna e Ascendente.
    expect(
        DomandeDelCerchio.perLaGettata(FamigliaDellaDomanda.personali,
                datiDisponibili: const {})
            .length,
        0);
    expect(
        DomandeDelCerchio.perLaGettata(FamigliaDellaDomanda.generiche,
                datiDisponibili: const {})
            .length,
        8,
        reason: 'le generiche non chiedono dati, quindi ci sono sempre tutte');
    // Con un dato solo compare la sua domanda e nient'altro.
    final conSegno = DomandeDelCerchio.perLaGettata(
        FamigliaDellaDomanda.personali,
        datiDisponibili: const {DatoPerLaDomanda.segno});
    expect(conSegno.length, 1);
    expect(conSegno.single.dato, DatoPerLaDomanda.segno);
  });
}
