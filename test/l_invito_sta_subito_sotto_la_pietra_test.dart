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

    // **LA PRETESA SI E' ROVESCIATA, E NON E' UNA GUARDIA ALLENTATA.** Ordine
    // AS voce 09, decisione di Mauro del 21 agosto 2026: la bolla "Gira la
    // pietra" NON ESISTE PIU'. Era passata per tre ordini, ognuno l'aveva
    // spostata o riscritta, ed era diventata la cosa piu' grande della scena
    // dopo la pietra per un gesto che nel rito non conta: il destino ha voluto
    // che la runa cadesse dritta o rovesciata, e girarla a mano non cambia il
    // responso.
    //
    // Questa prova nasceva per tenerla vicina alla pietra; adesso sorveglia la
    // decisione nuova, cioe' che nessuno la rimetta e che fra la pietra e il
    // suo nome non si infili di nuovo un invito. Il GESTO resta vivo, e lo
    // prova `il_doppio_tocco_gira_sulla_pietra_test.dart`.
    expect(find.byKey(const Key('sunset_gira_doppio')), findsNothing,
        reason: 'la bolla "Gira la pietra" e tornata');
    expect(find.text('Gira la pietra'), findsNothing,
        reason: 'l invito a girare la pietra e tornato senza la sua chiave');
    final pietra =
        tester.getRect(find.byKey(const Key('sunset_pietra_lettura')));
    final nome = tester.getRect(find.byKey(const Key('sunset_nome')));
    final distanza = nome.top - pietra.bottom;
    // ignore: avoid_print
    print('ORDINE AS VOCE 09: distanza fra la pietra e il suo nome '
        '${distanza.toStringAsFixed(1)} punti, soglia $sogliaPunti');
    expect(distanza, lessThanOrEqualTo(sogliaPunti),
        reason: 'fra la pietra e il suo nome ci sono '
            '${distanza.toStringAsFixed(1)} punti, oltre la soglia di '
            '$sogliaPunti: fra loro si e infilato qualcosa');
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
