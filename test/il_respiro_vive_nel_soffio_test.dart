import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RESPIRO GUIDATO VIVE NEL SOFFIO, E IN NESSUN ALTRO RITO. Ordine S voce 13.
///
/// **Il fatto.** Nell'Alba era comparsa la meditazione col respiro, arrivata come
/// effetto collaterale della voce P.17: quella voce aveva ragione a togliere
/// l'istruzione scritta ("tre dentro e tre fuori, sei giri"), che era un compito
/// da contare a mente, ma il rimedio ha portato il respiro guidato DENTRO ogni
/// dono del giorno. Il rito del mattino e' diventato il contenitore di un altro
/// rito.
///
/// **PERCHE' SI GUARDA CHI MONTA LA GUIDA, e non una schermata sola.** La guida
/// del respiro e' un widget del design system: la domanda della voce non e' "l'Alba
/// ce l'ha?" ma "chi ce l'ha, e ha il diritto di averla?". Percio' la prova
/// ENUMERA i montaggi in tutto `lib` e ammette un solo padrone.
void main() {
  test('la guida del respiro la monta solo il Soffio del Destino', () {
    final montaggi = <String>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      // Il componente stesso non conta: e' la sua definizione.
      if (percorso.endsWith('guida_del_respiro.dart')) continue;
      final righe = voce.readAsStringSync().split('\n');
      for (final riga in righe) {
        if (riga.trimLeft().startsWith('//')) continue;
        if (riga.contains('GuidaDelRespiro(')) {
          montaggi.add(percorso);
          break;
        }
      }
    }
    expect(montaggi, ['lib/features/rituals/breath_destiny_screen.dart'],
        reason: 'la guida del respiro e\' montata da: $montaggi. Il respiro '
            'guidato appartiene al Soffio del Destino ed e\' li\' che vive: un '
            'altro rito che se lo incastra dentro diventa il contenitore di un '
            'rito che non e\' suo');
  });

  test('dal dono del giorno al respiro si va con un invito, non col rito', () {
    // **La riga e' una PORTA VERA, non un annuncio.** Un invito che non porta da
    // nessuna parte e' un vicolo cieco, e in questo progetto e' vietato: la riga
    // spinge la rotta del Soffio.
    final scheda = File('lib/features/rituals/ritual_gift_card.dart')
        .readAsStringSync();
    expect(scheda.contains('ponte_verso_il_soffio'), isTrue,
        reason: 'dal dono del giorno non c\'e\' piu\' nessun ponte verso il '
            'respiro: la voce chiede un invito di una riga, non il nulla');
    expect(scheda.contains('BreathDestinyScreen.route'), isTrue,
        reason: 'il ponte verso il Soffio non apre niente: e\' un annuncio, e '
            'un annuncio che non porta da nessuna parte e\' un vicolo cieco');
    expect(scheda.contains('GuidaDelRespiro('), isFalse,
        reason: 'il respiro guidato e\' tornato dentro la scheda del dono');
  });

  test('solo il Soffio dichiara di guidare il respiro in scena', () {
    // Il dato che governa tutto sta in un punto solo, e questa prova lo tiene
    // vero: se domani un altro dono dicesse di guidare il respiro, la scheda
    // smetterebbe di offrirgli il ponte senza che nessuno se ne accorga.
    final chiLoGuida = DailyElement.values
        .where((d) => d.guidaIlRespiroInScena)
        .toList();
    expect(chiLoGuida, [DailyElement.breath],
        reason: 'questi doni dicono di guidare il respiro in scena: $chiLoGuida');
  });

  testWidgets('il ponte si RAGGIUNGE e porta nel Soffio', (tester) async {
    // **Non basta che la riga esista nel sorgente: deve raggiungersi col dito.**
    // La scheda del dono e' piu' alta dello schermo, e una riga che sta sotto il
    // taglio senza modo di arrivarci e' un vicolo cieco travestito da ponte.
    SharedPreferences.setMockInitialValues({});
    final messenger = TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // **I PROVIDER SERVONO PERCHE' IL PONTE APRE UNA ROTTA**, e quella rotta si
    // porta il suo `MaestroScope`, che legge il Maestro attivo: senza, il tocco
    // spingeva la rotta e la rotta cadeva costruendosi, quindi la prova vedeva un
    // ponte che non apriva niente per un difetto del banco.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: DawnRiteScreen(now: DateTime(2026, 8, 13, 6, 30)),
      ),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    final ponte = find.byKey(const Key('ponte_verso_il_soffio'));
    expect(ponte, findsOneWidget,
        reason: 'nella scheda del dono non c\'e\' nessun ponte verso il Soffio');
    // SI PORTA IN VISTA, come farebbe un dito che scorre.
    await tester.ensureVisible(ponte);
    await tester.pump();
    final dove = tester.getRect(ponte);
    final altezza =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(dove.top >= 0 && dove.bottom <= altezza + 0.5, isTrue,
        reason: 'il ponte verso il Soffio non si riesce a portare a schermo: sta '
            'fra ${dove.top.toStringAsFixed(1)} e '
            '${dove.bottom.toStringAsFixed(1)} su ${altezza.toStringAsFixed(0)} '
            'punti, ed e\' un vicolo cieco travestito da ponte');

    // E PORTA DAVVERO: al tocco si apre il Soffio.
    await tester.tap(ponte);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(BreathDestinyScreen), findsOneWidget,
        reason: 'toccando il ponte non si apre il Soffio del Destino');
  });
}
