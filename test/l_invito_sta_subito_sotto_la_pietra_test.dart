import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'INVITO "GIRA LA PIETRA" STA SUBITO SOTTO LA PIETRA.
///
/// Ordine 2161, voce 11. Prima fra la pietra e l'invito stavano il nome, il
/// verso, la Voce A intera e la riga di trasparenza: piu' di uno schermo di
/// distanza fra l'oggetto e il suo invito. La misura e' la distanza in punti
/// fra il bordo basso della pietra e il bordo alto dell'invito, con la
/// soglia dichiarata qui sotto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final ora = DateTime(2026, 8, 6, 21, 30);

  /// La pietra della lettura e' alta 168; l'invito le sta sotto entro questa
  /// soglia: la costante dichiarata della schermata piu' il respiro del nome
  /// e' un errore, quindi la soglia e' STRETTA, trenta punti.
  const sogliaPunti = 30.0;

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
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
  }

  testWidgets('la distanza pietra-invito sta nella soglia dichiarata',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenzia();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5)),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Il bordo basso della pietra: dalla chiave della pietra toccabile se
    // c'e' (e' quella che la voce 8 aggiunge), altrimenti dal nome, che le
    // stava subito sotto col passo medio prima della correzione. Cosi' la
    // stessa prova misura il prima e il dopo.
    final pietraFinder = find.byKey(const Key('sunset_pietra_lettura'));
    final double pietraFondo = pietraFinder.evaluate().isNotEmpty
        ? tester.getRect(pietraFinder).bottom
        : tester.getRect(find.byKey(const Key('sunset_nome'))).top -
            SpacingTokens.md;
    final invito = tester.getRect(find.byKey(const Key('sunset_gira_doppio')));
    final distanza = invito.top - pietraFondo;
    // ignore: avoid_print
    print('INVITO: distanza pietra-invito = ${distanza.toStringAsFixed(1)} '
        'punti (soglia $sogliaPunti)');
    expect(distanza, lessThanOrEqualTo(sogliaPunti),
        reason: 'L\'invito "Gira la pietra" sta a '
            '${distanza.toStringAsFixed(1)} punti sotto la pietra, oltre la '
            'soglia di $sogliaPunti: fra loro c\'e\' ancora altro, e Mauro '
            'lo vuole SUBITO sotto.');
  });

  testWidgets('la pietra e\' la prima cosa che si vede, e il testo viene dopo',
      (tester) async {
    // **ORDINE S VOCE 11, misurato a schermo.** Le tre righe "Cosa fai",
    // "Perche\'" e "Cosa ti resta" stavano SOPRA la pietra nella stessa colonna e
    // la spingevano in basso: la schermata si leggeva come un foglio di istruzioni
    // con una runa in mezzo. Qui si misura la sola cosa che conta: **dove sta la
    // pietra quando la lettura si apre**, e se il testo le sta sopra.
    SharedPreferences.setMockInitialValues({});
    silenzia();
    // La misura del telefono di Mauro: su una finestra alta 2600 punti la pietra
    // ci starebbe comunque, e la prova non misurerebbe niente.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5)),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    final pietra = tester.getRect(find.byKey(const Key('sunset_pietra_lettura')));
    final righe =
        tester.getRect(find.byKey(const Key('tre_righe_rune')));
    // ignore: avoid_print
    print('TRAMONTO: pietra da ${pietra.top.toStringAsFixed(1)} a '
        '${pietra.bottom.toStringAsFixed(1)}, tre righe da '
        '${righe.top.toStringAsFixed(1)}');

    expect(righe.top, greaterThan(pietra.bottom),
        reason: 'le tre righe cominciano a ${righe.top.toStringAsFixed(1)} e la '
            'pietra finisce a ${pietra.bottom.toStringAsFixed(1)}: il testo sta '
            'ancora sopra la pietra, e la pietra e\' la protagonista');

    // **E LA PIETRA STA NEL PRIMO SGUARDO.** Non basta che il testo sia sotto: se
    // la pietra cominciasse a meta\' schermo, la prima cosa che si vede sarebbe
    // ancora altro. La soglia e\' un terzo dell\'altezza utile, dichiarata qui.
    final altezza = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(pietra.top, lessThan(altezza / 3),
        reason: 'la pietra comincia a ${pietra.top.toStringAsFixed(1)} su '
            '${altezza.toStringAsFixed(0)} punti di schermo: piu\' di un terzo '
            'sopra di lei c\'e\' altro, e non e\' lei la prima cosa che si vede');
  });
}
