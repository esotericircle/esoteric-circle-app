import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
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
    expect(find.text('Scuoti il telefono o tocca la pietra\nper gettarla.'),
        findsOneWidget);
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
    // Qui Riduci Movimento e' attivo: l'unica riga di invito deve dire il gesto
    // vero di QUEL caso, il tocco unico, e non promettere un tracciamento.
    expect(find.text('Tocca la pietra per incidere il simbolo.'), findsOneWidget);
    expect(find.textContaining('Traccia con il dito'), findsNothing);
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
    // L'invito e' sfumato via appena il segno e' cominciato.
    expect(
        tester
            .widget<AnimatedOpacity>(find.ancestor(
                of: find.byKey(const Key('sunset_invito')),
                matching: find.byType(AnimatedOpacity)))
            .opacity,
        0);
  });

  testWidgets('Il tracciato del dito incide, senza aspettare il tempo',
      (tester) async {
    // La riga di invito promette "Traccia con il dito sulla pietra":
    // qui si blocca quella promessa. Il dito si muove entro un solo frame, quindi
    // il contributo del tempo di pressione e' trascurabile: se il segno avanza,
    // avanza per il movimento.
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));

    // Senza Riduci Movimento la riga promette il tracciamento.
    expect(find.text('Traccia con il dito sulla pietra\ne scopri il simbolo.'),
        findsOneWidget);

    final gesto = find.byKey(const Key('sunset_incisione_gesture'));
    final centro = tester.getCenter(gesto);
    double progresso() => (tester
            .widget<CustomPaint>(find.byKey(const Key('sunset_incisione')))
            .painter! as dynamic)
        .progresso as double;

    // Preme e supera la soglia del tocco prolungato, senza muoversi.
    final g = await tester.startGesture(centro);
    await tester.pump(const Duration(milliseconds: 600));
    final fermo = progresso();

    // Ora traccia, dentro un solo frame: nessun tempo in piu', solo percorso.
    for (var i = 0; i < 6; i++) {
      await g.moveBy(const Offset(0, 40));
    }
    await tester.pump(const Duration(milliseconds: 1));
    final tracciato = progresso();
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tracciato, greaterThan(fermo),
        reason: 'il tracciato del dito non fa avanzare il segno');
    // E il guadagno e' quello del percorso, non un'inezia: duecentoquaranta
    // punti su una runa a due tratti valgono quasi mezzo segno.
    expect(tracciato - fermo, greaterThan(0.2));
  });

  testWidgets('Il tracciato non fa mai regredire il segno', (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));

    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    double progresso() => (tester
            .widget<CustomPaint>(find.byKey(const Key('sunset_incisione')))
            .painter! as dynamic)
        .progresso as double;

    final g = await tester.startGesture(centro);
    await tester.pump(const Duration(milliseconds: 600));
    await g.moveBy(const Offset(0, 30));
    await tester.pump(const Duration(milliseconds: 1));
    final avanti = progresso();
    // Torna indietro sullo stesso percorso: il segno non si disfa.
    await g.moveBy(const Offset(0, -30));
    await tester.pump(const Duration(milliseconds: 1));
    expect(progresso(), greaterThanOrEqualTo(avanti));
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('Col luogo noto resta la sola riga, senza pulsante',
      (tester) async {
    // A posizione concessa il pulsante non ha piu' ragione di esistere: in fondo
    // resta una riga sola, e dice il tramonto vero.
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(
      now: ora,
      dataNascita: DateTime(1988, 7, 5),
      location: const _LuogoConcesso(),
    )));
    await passo(tester);
    await passo(tester);

    expect(find.byKey(const Key('sunset_attiva')), findsNothing);
    expect(find.byKey(const Key('sunset_stimata')), findsNothing);
    expect(find.byKey(const Key('sunset_ora')), findsOneWidget);
    expect(find.textContaining('Tramonto alle'), findsOneWidget);
  });

  testWidgets('Il fantasma arriva col silenzio e sparisce al primo tocco',
      (tester) async {
    // Senza Riduci Movimento: il punto di luce percorre il primo tratto.
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));

    double? fantasma() => (tester
            .widget<CustomPaint>(find.byKey(const Key('sunset_incisione')))
            .painter! as dynamic)
        .fantasma as double?;

    // Prima della soglia di silenzio non c'e'.
    await tester.pump(const Duration(milliseconds: 900));
    expect(fantasma(), isNull, reason: 'compare troppo presto');

    // Passata la soglia, c'e'.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 16));
    expect(fantasma(), isNotNull, reason: 'non compare dopo il silenzio');

    // Il primo contatto lo spegne, e non torna piu'.
    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    final g = await tester.startGesture(centro);
    await tester.pump(const Duration(milliseconds: 600));
    expect(fantasma(), isNull, reason: 'non si spegne al tocco');
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));
    // Anche dopo un lungo silenzio non riappare.
    await tester.pump(const Duration(seconds: 3));
    expect(fantasma(), isNull, reason: 'e tornato dopo il tocco');
  });

  testWidgets('Con Riduci Movimento il fantasma e un velo fermo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host()); // host ha disableAnimations
    await passo(tester);
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));

    double? fantasma() => (tester
            .widget<CustomPaint>(find.byKey(const Key('sunset_incisione')))
            .painter! as dynamic)
        .fantasma as double?;

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 16));
    // Il valore convenzionale del velo fermo, nessun punto che viaggia.
    expect(fantasma(), -1.0);
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

  testWidgets('Con insistenza, il testo mostrato e quello salvato coincidono',
      (tester) async {
    // La runa di stasera e' gia' uscita tre sere fa: la clausola d'insistenza
    // deve essere gia' nel testo al momento in cui si compone e si persiste.
    final giorno = SunsetRune.giornoRituale(ora);
    final stasera = SunsetRune.estrai(ora,
            dataNascita: DateTime(1988, 7, 5), identita: '1988-07-05')
        .rune.name;
    final treFa = SunsetRune.iso(giorno.subtract(const Duration(days: 3)));
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana':
          '[{"giorno":"$treFa","rune":"$stasera","ombra":false,'
              '"lasciare":"a","porta":"b"}]',
    });
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);

    // A video la runa torna, con la sua clausola.
    expect(find.byKey(const Key('sunset_ritorno')), findsOneWidget);
    final bloccoUno = find.descendant(
        of: find.byKey(const Key('sunset_voce_uno')), matching: find.byType(Text));
    final mostrato = tester.widgetList<Text>(bloccoUno).last.data!;

    // E il testo salvato e' lo stesso, clausola compresa.
    final settimana = await SunsetRuneMemory.settimanaCorrente(giorno);
    final oggi = settimana.firstWhere((s) => s.giorno == SunsetRune.iso(giorno));
    expect(oggi.lasciare, mostrato);
    // La clausola c'e' davvero: il testo salvato e' piu' lungo della sola voce.
    expect(oggi.lasciare.length, greaterThan(60));
  });

  testWidgets('Dopo una pausa lunga la ripresa non completa di colpo',
      (tester) async {
    // Senza Riduci Movimento: preme un poco, molla, aspetta a lungo, ripreme.
    // Il ticker fermo al rilascio non deve scaricare il tempo di pausa.
    SharedPreferences.setMockInitialValues({});
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(MaterialApp(
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 300));

    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    // Prima pressione breve, poi rilascio.
    var g = await tester.startGesture(centro);
    await tester.pump(const Duration(milliseconds: 600));
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));
    // Pausa lunga a dito alzato: tre secondi.
    await tester.pump(const Duration(seconds: 3));
    // Seconda pressione breve: se il bug ci fosse, il dt gigante completerebbe.
    g = await tester.startGesture(centro);
    await tester.pump(const Duration(milliseconds: 300));
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));
    // Non e' completa: la lettura non si e' aperta.
    expect(find.byKey(const Key('sunset_voce_uno')), findsNothing);
  });

  testWidgets('La striscia riempie per data, un giorno saltato resta vuoto',
      (tester) async {
    // Oggi e tre giorni fa fatte, ieri e l'altro ieri saltati.
    final giorno = SunsetRune.giornoRituale(ora);
    final treFa = SunsetRune.iso(giorno.subtract(const Duration(days: 3)));
    final ieri = SunsetRune.iso(giorno.subtract(const Duration(days: 1)));
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana':
          '[{"giorno":"$treFa","rune":"Fehu","ombra":false,"lasciare":"a","porta":"b"}]',
    });
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);

    // La casella di tre giorni fa e di oggi ci sono, quella di ieri no.
    expect(find.byKey(Key('sunset_casella_$treFa')), findsOneWidget);
    expect(find.byKey(Key('sunset_casella_${SunsetRune.iso(giorno)}')),
        findsOneWidget);
    expect(find.byKey(Key('sunset_casella_$ieri')), findsNothing);
  });

  // Semina sei sere coi nomi dati, per portare la settima a sette.
  String seiSere(DateTime giorno, List<String> nomi) {
    final voci = <String>[];
    for (var i = 0; i < 6; i++) {
      final g = SunsetRune.iso(giorno.subtract(Duration(days: i + 1)));
      voci.add('{"giorno":"$g","rune":"${nomi[i]}","ombra":false,'
          '"lasciare":"a","porta":"b"}');
    }
    return '[${voci.join(',')}]';
  }

  testWidgets('Il sigillo dice il legame quando una runa torna', (tester) async {
    final giorno = SunsetRune.giornoRituale(ora);
    // Sei Fehu: qualcosa si ripete di sicuro nella settimana.
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana': seiSere(giorno, List.filled(6, 'Fehu')),
    });
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);
    expect(find.textContaining('due segni che tornano'), findsOneWidget);
  });

  testWidgets('Il sigillo dice l\'assenza d\'insistenza a sette segni diversi',
      (tester) async {
    final giorno = SunsetRune.giornoRituale(ora);
    final stasera = SunsetRune.estrai(ora,
            dataNascita: DateTime(1988, 7, 5), identita: '1988-07-05')
        .rune.name;
    // Sei nomi distinti, tutti diversi da quello di stasera: sette segni diversi.
    final pool = kElderFuthark
        .map((r) => r.name)
        .where((n) => n != stasera)
        .take(6)
        .toList();
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana': seiSere(giorno, pool),
    });
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compi(tester);
    expect(find.textContaining('Sette segni diversi'), findsOneWidget);
  });
}

/// Una posizione gia' concessa, per il caso in cui il pulsante deve sparire.
class _LuogoConcesso extends SkyLocation {
  const _LuogoConcesso();
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async =>
      const SkyPlace(latitude: 41.9, longitude: 12.5);
  @override
  Future<SkyPlace?> resolveSeConcesso() async =>
      const SkyPlace(latitude: 41.9, longitude: 12.5);
}
