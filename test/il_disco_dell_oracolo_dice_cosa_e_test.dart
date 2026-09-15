import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL DISCO DELL'ORACOLO DICE COSA E' E COSA DA'. Ordine S voce 12.
///
/// **Il fatto.** L'Oracolo funzionava, e il disco con i raggi in cima non diceva
/// cosa fosse: chi lo guardava non capiva ne' cosa stesse guardando ne' cosa
/// ottenesse muovendolo. La riga del gesto compariva solo PRIMA della
/// rivelazione, e la riga del sensore stava in fondo, dopo il responso: dopo il
/// gesto il disco restava li', nudo.
///
/// **Delle due strade dell'ordine si e' presa la (a):** il disco resta e acquista
/// un senso. Buttarlo perche' non era spiegato sarebbe stato risolvere un problema
/// di parole togliendo l'unico punto dell'app in cui il cielo reagisce al
/// movimento del telefono.
///
/// **La misura che conta e' che la dichiarazione RESTI DOPO IL GESTO**, perche' e'
/// li' che prima non c'era niente: una prova che guardasse solo la schermata
/// appena aperta passerebbe col difetto in piedi.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> monta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    silenzia();
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: DayOracleScreen(now: DateTime(2026, 8, 13, 13, 30)),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('la carta dice cosa e, e le istruzioni se ne vanno dopo il gesto',
      (tester) async {
    // **LA PRETESA SI E' ROVESCIATA COL DONO. Ordine AS voce 08.**
    //
    // Questa prova nasceva per il DISCO dell'Oracolo, che funzionava e non
    // diceva cosa fosse: la cura di allora fu una didascalia che restava anche
    // dopo il gesto, "perche' il disco resta li'". Adesso il dono e' l'Arcano
    // del Giorno e il livello visivo e' la CARTA, cioe' la risposta stessa:
    // prima del gesto la didascalia dice cosa si sta per scoprire, dopo non
    // serve piu' e se ne va, perche' due righe di istruzioni fra la carta e il
    // suo responso allontanano la risposta.
    //
    // Non e' una guardia allentata: sorveglia la decisione nuova, cioe' che la
    // dichiarazione ci sia PRIMA e sparisca DOPO.
    await monta(tester);
    final didascalia = find.byKey(const Key('rito_cosa_e_il_visivo'));
    expect(didascalia, findsOneWidget,
        reason: 'la carta coperta non dice cosa sia: chi guarda non sa cosa '
            'sta per scoprire');
    final testo = tester.widget<Text>(didascalia).data!;
    expect(testo.toLowerCase(), contains('carta'),
        reason: 'la didascalia non nomina la carta');

    await tester.tap(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('ritual_content')), findsOneWidget,
        reason: 'il gesto non ha rivelato niente');
    expect(didascalia, findsNothing,
        reason: 'dopo il gesto le istruzioni restano fra la carta e il suo '
            'responso');
  });

  testWidgets('la riga del ripiego tattile non si dice due volte',
      (tester) async {
    // **Era in fondo alla schermata, dopo il responso.** Adesso sta accanto alla
    // cosa che si muove, che e' la sua casa: se restasse anche in fondo, la
    // stessa frase si leggerebbe due volte nella stessa scorsa.
    await monta(tester);
    final riga = find.textContaining('Inclina il telefono');
    expect(riga, findsOneWidget,
        reason: 'la riga del ripiego tattile compare '
            '${riga.evaluate().length} volte: e\' obbligatoria, e una volta '
            'basta');
  });
}
