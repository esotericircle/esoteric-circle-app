import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA BARRA SOTTILE HA UN SOLO STATO. Ordine AR voce 10.
///
/// **Questa guardia SOSTITUISCE `la_barra_si_ritira_da_sola_test`**, che
/// sorvegliava il ritiro automatico dell'ordine AO voce 02. Non e' un
/// allentamento: e' un cambio di oggetto, perche' la cosa da sorvegliare non
/// esiste piu'. Decisione di Mauro del 19 agosto 2026, che supera due sue
/// decisioni precedenti: il nome accanto al volto (ordine AN voce 02) e il
/// ritiro automatico della barra aperta (ordine AO voce 02).
///
/// **Cosa si pretende adesso.** Che la barra resti sempre alta uguale, che il
/// nome non ci sia, e soprattutto che ognuno dei tre bersagli porti dove deve
/// al PRIMO tocco: era il primo tocco a essere sprecato per aprire, ed e' la
/// parte che non si puo' dimenticare.
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
      m.setMockStreamHandler(EventChannel(nome),
          MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  final barra = find.byKey(const Key('barra_dell_identita'));

  Future<void> apri(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('la barra resta alta uguale, qualunque cosa si tocchi',
      (tester) async {
    await apri(tester);
    expect(barra, findsOneWidget, reason: 'la barra non c e in home');
    final prima = tester.getRect(barra).height;
    // Si tocca il volto, che era il gesto che la apriva.
    await tester.tap(find.byKey(const Key('barra_volto')),
        warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    if (barra.evaluate().isEmpty) return; // si e aperta una rotta: va bene
    final dopo = tester.getRect(barra).height;
    // ignore: avoid_print
    print('ORDINE AR VOCE 10: la barra era alta $prima e adesso e alta $dopo');
    expect(dopo, prima,
        reason: 'la barra ha cambiato altezza: e tornato lo stato aperto');
  });

  testWidgets('nella barra non c e nessun nome', (tester) async {
    await apri(tester);
    expect(find.byKey(const Key('barra_nome_proprio')), findsNothing,
        reason: 'il nome e tornato nella barra: con un nome lungo si '
            'sovrappone al resto, ed e la ragione per cui Mauro lo ha tolto');
  });

  testWidgets('i tre bersagli hanno un area di tocco piena', (tester) async {
    await apri(tester);
    for (final chiave in const ['barra_volto', 'barra_eventi_cosmici',
        'barra_borsellino']) {
      final bersaglio = find.byKey(Key(chiave));
      expect(bersaglio, findsOneWidget, reason: '$chiave non c e piu');
      final riquadro = tester.getRect(bersaglio);
      // ignore: avoid_print
      print('ORDINE AR VOCE 10: $chiave alto '
          '${riquadro.height.toStringAsFixed(0)} e largo '
          '${riquadro.width.toStringAsFixed(0)}');
      // **PERCHE' IL BERSAGLIO NON PUO' SUPERARE LA BARRA, misurato e
      // dichiarato.** L'ordine dice di allargare l'area invisibile invece
      // della barra, e qui l'area invisibile si allarga in LARGHEZZA. In
      // altezza no: la barra e' alta trenta punti e sotto di lei comincia il
      // contenuto della schermata, quindi un bersaglio piu' alto ruberebbe i
      // tocchi a cio' che sta sotto, che e' un difetto peggiore di un
      // bersaglio corto. Si pretende quindi che ogni bersaglio prenda TUTTA
      // l'altezza della barra, e che sia largo almeno quanto e' alto.
      expect(riquadro.height, greaterThanOrEqualTo(28),
          reason: '\$chiave e alto \${riquadro.height} punti: non prende '
              'nemmeno l altezza della barra');
      expect(riquadro.width, greaterThanOrEqualTo(riquadro.height),
          reason: '\$chiave e piu stretto che alto: l area di tocco non e '
              'stata allargata dove si poteva, cioe in larghezza');
    }
  });

  testWidgets('il volto porta all account al PRIMO tocco', (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('barra_volto')),
        warnIfMissed: false);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .take(12)
        .join(' | ');
    // ignore: avoid_print
    print('ORDINE AR VOCE 10: dopo il tocco sul volto si legge: $testi');
    expect(find.text('Il tuo account'), findsOneWidget,
        reason: 'il primo tocco sul volto non porta all account: e speso per '
            'aprire la barra, che e cio che questa voce ha tolto');
  });

  testWidgets('Eventi Cosmici porta al Calendario al PRIMO tocco',
      (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('barra_eventi_cosmici')),
        warnIfMissed: false);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('Eventi Cosmici'), findsWidgets,
        reason: 'il primo tocco al centro non porta al Calendario');
  });
}
