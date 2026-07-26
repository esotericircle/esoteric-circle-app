import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_memory.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La schermata della Runa del Tramonto.
void main() {
  final ora = DateTime(2026, 7, 13, 20);

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

  // Con Riduci Movimento l'incisione basta un tocco: il flusso resta stabile.
  Widget host() => MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5)),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Compie il rito col ripiego tattile: tocca per gettare, tocca per incidere.
  Future<void> compi(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await passo(tester);
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    // L'incisione automatica del ripiego, poi il crossfade e la lettura.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('Si apre in attesa, con la pietra velata e l\'ora stimata',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('sunset_stone')), findsOneWidget);
    expect(find.byKey(const Key('sunset_getto_gesture')), findsOneWidget);
    expect(find.text('Scuoti per gettare la runa'), findsOneWidget);
    // Senza posizione, l'ora e' dichiarata stimata, con la voce per attivarla.
    expect(find.byKey(const Key('sunset_stimata')), findsOneWidget);
    expect(find.byKey(const Key('sunset_attiva')), findsOneWidget);
  });

  testWidgets('Il getto col tocco porta all\'incisione', (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await passo(tester);
    expect(find.byKey(const Key('sunset_incisione_gesture')), findsOneWidget);
    expect(find.text('Tieni il dito sulla pietra'), findsOneWidget);
  });

  testWidgets('Incisa la runa, si aprono le due voci dietro la rotazione',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);

    // Lettura: la prima voce e la trasparenza dei tre fattori.
    expect(find.byKey(const Key('sunset_voce_uno')), findsOneWidget);
    expect(find.byKey(const Key('sunset_trasparenza')), findsOneWidget);
    // La seconda voce e' dietro la rotazione: prima l'invito, poi la voce.
    expect(find.byKey(const Key('sunset_gira')), findsOneWidget);
    expect(find.byKey(const Key('sunset_voce_due')), findsNothing);
    // Doppio tap sull'invito: la pietra gira e svela la seconda voce.
    final loc = tester.getCenter(find.byKey(const Key('sunset_gira_doppio')));
    await tester.tapAt(loc);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(loc);
    await passo(tester);
    expect(find.byKey(const Key('sunset_voce_due')), findsOneWidget);

    // La sera si e' salvata, la striscia c'e'.
    expect(find.byKey(const Key('sunset_settimana')), findsOneWidget);
  });

  testWidgets('L\'incisione parziale non si azzera, riprende da dove era',
      (tester) async {
    // Senza Riduci Movimento l'incisione avanza solo mentre si tiene premuto.
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));
    // Preme un poco, poi alza: il segno non e' compiuto ma il progresso resta.
    final gesto = find.byKey(const Key('sunset_incisione_gesture'));
    final centro = tester.getCenter(gesto);
    final gesture = await tester.startGesture(centro);
    // Supera la soglia del tocco prolungato, incide un poco, poi alza il dito.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    // Non e' passata alla lettura: il segno resta a meta'.
    expect(find.byKey(const Key('sunset_voce_uno')), findsNothing);
    expect(find.text('Il segno non e\' compiuto'), findsOneWidget);
  });

  testWidgets('Il sigillo compare alla settima sera, non prima', (tester) async {
    // Sei sere gia' fatte nei giorni precedenti: stasera fa sette.
    final giorno = SunsetRune.giornoRituale(ora);
    final sere = <Map<String, dynamic>>[];
    for (var i = 1; i <= 6; i++) {
      final g = SunsetRune.iso(giorno.subtract(Duration(days: i)));
      sere.add({'giorno': g, 'rune': 'Fehu', 'ombra': false, 'lasciare': 'a', 'porta': 'b'});
    }
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana':
          '[${sere.map((s) => '{"giorno":"${s['giorno']}","rune":"Fehu","ombra":false,"lasciare":"a","porta":"b"}').join(',')}]',
    });
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);

    expect(find.byKey(const Key('sunset_settimana')), findsOneWidget);
    expect(find.byKey(const Key('sunset_sigillo')), findsOneWidget);
  });

  testWidgets('La prima sera non ha sigillo, ma la striscia lo dice', (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);

    expect(find.byKey(const Key('sunset_settimana')), findsOneWidget);
    expect(find.byKey(const Key('sunset_sigillo')), findsNothing);
    expect(find.textContaining('La prima delle sette'), findsOneWidget);
  });

  testWidgets('La cerniera scrive la runa portata dentro la notte', (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);
    // Dopo la lettura, la chiave della cerniera e' scritta.
    final c = await SunsetRuneMemory.ultimaPerCerniera();
    expect(c, isNotNull);
    expect(c!.giorno, SunsetRune.iso(SunsetRune.giornoRituale(ora)));
  });
}
