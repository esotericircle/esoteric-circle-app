import 'dart:convert';

import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_vivo.dart';
import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:esoteric_circle/core/magic/la_voce_del_sigillo.dart';
import 'package:esoteric_circle/core/magic/libro_dei_sigilli.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La schermata del Sigillo, dalla via alla rivelazione. Dall'ordine DO,
/// 15 settembre 2026, la via si sceglie prima di scrivere e il sigillo
/// tracciato entra nel Libro.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown;
  });

  /// Il modello finto: risponde a ognuna delle tre chiamate del Sigillo.
  Future<String?> modelloFinto(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    if (campi.containsKey('riformulata')) {
      return jsonEncode({'riformulata': 'Trovo chiarezza sulla mia strada'});
    }
    if (campi.containsKey('testo')) {
      return jsonEncode({'testo': 'Cercavi chiarezza sulla tua strada.'});
    }
    return jsonEncode({
      'titolo': 'La chiarezza sulla tua strada',
      'responso': 'Il segno custodisce la chiarezza che cerchi sulla tua '
          'strada. Resta illeggibile e lavora in silenzio.',
    });
  }

  Future<LibroDeiSigilli> apri(
    WidgetTester tester, {
    LibroDeiSigilli? libro,
    bool senzaMoto = false,
    ChiamataFinta? chiamata,
  }) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final l = libro ?? LibroDeiSigilli();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: senzaMoto
            ? (ctx, child) => MediaQuery(
                  data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
                  child: child!,
                )
            : null,
        home: MaestroScope(
            child: SigilloIntenzioneScreen(
                libro: l, chiamata: chiamata ?? modelloFinto)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return l;
  }

  Future<void> scegliEScrivi(WidgetTester tester, ViaMagica via, String frase,
      {bool traccia = true}) async {
    await tester.tap(find.byKey(Key('sigillo_via_${via.name}')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('sigillo_campo')), frase);
    await tester.pump();
    if (!traccia) return;
    await tester.ensureVisible(find.byKey(const Key('sigillo_traccia')));
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();
  }

  /// Legge l'avanzamento del tracciamento dal painter a schermo.
  RuotaSigilloPainter painter(WidgetTester tester) {
    final cp =
        tester.widget<CustomPaint>(find.byKey(const Key('sigillo_ruota')));
    return cp.painter! as RuotaSigilloPainter;
  }

  testWidgets(
      'DO.01: alla prima apertura si leggono cosa stai per fare e da dove '
      'viene, e cosa ti restera\' sta prima del campo', (tester) async {
    await apri(tester);
    expect(find.text(LaVoceDelSigillo.cosaStaiPerFare), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('sigillo_da_dove_viene')), 200,
        scrollable: find.descendant(
            of: find.byKey(const Key('sigillo_soglia')),
            matching: find.byType(Scrollable)));
    expect(find.textContaining('The Book of Pleasure, 1913'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('sigillo_via_verde')), -200,
        scrollable: find.descendant(
            of: find.byKey(const Key('sigillo_soglia')),
            matching: find.byType(Scrollable)));
    await scegliEScrivi(tester, ViaMagica.verde, '', traccia: false);
    final restera =
        tester.getRect(find.byKey(const Key('sigillo_cosa_ti_restera')));
    final campo = tester.getRect(find.byKey(const Key('sigillo_campo')));
    expect(restera.bottom, lessThanOrEqualTo(campo.top),
        reason: 'la riga di cosa ti restera\' deve stare prima del campo');
  });

  testWidgets('DO.09: la via si sceglie prima di scrivere, e non si deduce',
      (tester) async {
    await apri(tester);
    final prima = tester
        .widget<FilledButton>(find.descendant(
            of: find.byKey(const Key('sigillo_inizia')),
            matching: find.byType(FilledButton)))
        .onPressed;
    expect(prima, isNull, reason: 'senza una via scelta si scrive lo stesso');
    // Una frase del cuore sulla Via Verde resta sulla Via Verde: la via e'
    // quella dichiarata, non quella che le parole sembrano dire.
    final libro = await apri(tester);
    await scegliEScrivi(tester, ViaMagica.verde, 'Apro il mio cuore');
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(ViaMagica.verde.nome), findsWidgets);
    expect(libro.tutti.single.via, ViaMagica.verde);
  });

  testWidgets('Senza abbastanza lettere non si traccia', (tester) async {
    await apri(tester);
    await scegliEScrivi(tester, ViaMagica.bianca, 'aaa', traccia: false);
    final bottone = tester.widget<FilledButton>(find.descendant(
        of: find.byKey(const Key('sigillo_traccia')),
        matching: find.byType(FilledButton)));
    expect(bottone.onPressed, isNull,
        reason: 'con una lettera sola il sigillo si potrebbe tracciare');
    expect(find.textContaining('almeno due lettere'), findsOneWidget);
  });

  testWidgets('Il cammino si traccia un poco per volta, non tutto insieme',
      (tester) async {
    await apri(tester);
    await scegliEScrivi(tester, ViaMagica.bianca, 'Chiedo chiarezza');
    await tester.pump(const Duration(milliseconds: 200));
    final aMeta = painter(tester).avanzamento;
    expect(aMeta, greaterThan(0));
    expect(aMeta, lessThan(1), reason: 'il cammino e\' comparso tutto insieme');
    expect(painter(tester).mostraRuota, isTrue,
        reason: 'la ruota deve vedersi mentre si traccia, altrimenti non si '
            'capisce da dove nasce il segno');
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    expect(painter(tester).avanzamento, 1.0);
    expect(find.byKey(const Key('sigillo_via')), findsOneWidget);
  });

  testWidgets(
      'E ADESSO? Alla fine del tracciamento la schermata dice cosa succede '
      'e quando l\'app si fara\' viva, e il sigillo entra nel Libro vivo e '
      'spento', (tester) async {
    final libro = await apri(tester);
    await scegliEScrivi(
        tester, ViaMagica.bianca, 'Chiedo chiarezza sulla mia strada');
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('La chiarezza sulla tua strada'), findsOneWidget,
        reason: 'il titolo del modello non e\' arrivato a schermo');
    final lista = find.descendant(
        of: find.byKey(const Key('sigillo_scena')),
        matching: find.byType(Scrollable));
    for (final k in const [
      'sigillo_lascialo_lavorare',
      'sigillo_quando',
      'sigillo_apri_libro',
      'sigillo_sfondo',
    ]) {
      await tester.scrollUntilVisible(find.byKey(Key(k)), 150,
          scrollable: lista);
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    expect(find.text(LaVoceDelSigillo.lasciaLavorare), findsOneWidget);
    // Il Condividi resta assente, per decisione dell'ordine CG.
    expect(find.text('Condividi'), findsNothing);
    final s = libro.tutti.single;
    expect(s.statoA(libro.adesso), StatoDelSigillo.vivo);
    expect(s.cariche, isEmpty, reason: 'il sigillo deve nascere spento');
    expect(s.titolo, 'La chiarezza sulla tua strada');
    expect(s.scadenza.isAfter(libro.adesso), isTrue);
  });

  testWidgets(
      'Una richiesta sulla volonta\' altrui non si traccia: si riscrive',
      (tester) async {
    final libro = await apri(tester, chiamata: (i, r, c) async => null);
    await scegliEScrivi(
        tester, ViaMagica.rossa, 'Fai che lui si innamori di me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('sigillo_riformulata')), findsOneWidget,
        reason: 'la riformulazione non viene spiegata a chi ha scritto');
    expect(find.byKey(const Key('sigillo_proposta')), findsOneWidget,
        reason: 'senza modello la frase su un terzo resta senza proposta');
    expect(libro.tutti, isEmpty,
        reason: 'la frase su un terzo e\' stata tracciata');
    await tester.ensureVisible(find.byKey(const Key('sigillo_usa_proposta')));
    await tester.tap(find.byKey(const Key('sigillo_usa_proposta')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('sigillo_traccia')));
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    expect(libro.tutti.single.intenzione.contains('innamori'), isFalse);
  });

  testWidgets(
      'DO.09: Caligo riscrive tre volte al massimo, poi la frase resta la '
      'tua', (tester) async {
    var chiamate = 0;
    await apri(tester, chiamata: (i, r, c) async {
      if (c.containsKey('riformulata')) chiamate++;
      return modelloFinto(i, r, c);
    });
    await scegliEScrivi(tester, ViaMagica.bianca, 'Voglio chiarezza',
        traccia: false);
    for (var i = 0; i < 3; i++) {
      await tester.ensureVisible(find.byKey(const Key('sigillo_riformula')));
      await tester.tap(find.byKey(const Key('sigillo_riformula')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('sigillo_proposta')), findsOneWidget);
      // Si rifiuta la proposta scrivendo di nuovo: il tetto conta lo stesso.
      await tester.enterText(
          find.byKey(const Key('sigillo_campo')), 'Voglio chiarezza $i');
      await tester.pump();
    }
    expect(chiamate, 3);
    expect(find.byKey(const Key('sigillo_riformula')), findsNothing,
        reason: 'oltre la terza si puo\' riformulare ancora');
    expect(
        find.byKey(const Key('sigillo_riformulazioni_finite')), findsOneWidget);
  });

  testWidgets(
      'DO.11: a spazio pieno non c\'e\' un muro, c\'e\' la strada per il '
      'Libro', (tester) async {
    final libro = LibroDeiSigilli();
    await libro.apri();
    final adesso = libro.adesso;
    await libro.aggiungi(SigilloVivo(
      id: 'uno',
      intenzione: 'Chiedo chiarezza',
      riformulata: 'Chiedo chiarezza',
      via: ViaMagica.bianca,
      nascita: adesso,
      scadenza: adesso.add(const Duration(days: 30)),
    ));
    await apri(tester, libro: libro);
    expect(find.byKey(const Key('sigillo_limite')), findsOneWidget);
    expect(find.text(LaVoceDelSigillo.pieno(1)), findsOneWidget);
    expect(find.byKey(const Key('sigillo_limite_libro')), findsOneWidget);
    expect(find.byKey(const Key('sigillo_inizia')), findsNothing);
  });

  testWidgets('Con Riduci Movimento si arriva subito al sigillo finito',
      (tester) async {
    final libro = await apri(tester, senzaMoto: true);
    await scegliEScrivi(tester, ViaMagica.bianca, 'Chiedo pace');
    await tester.pump();
    expect(painter(tester).avanzamento, 1.0);
    expect(find.byKey(const Key('sigillo_via')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(libro.tutti, hasLength(1));
  });

  testWidgets(
      'DO.12: a un profilo femminile il maschile del modello non arriva mai',
      (tester) async {
    LaMarcaDelGenere.formaCorrente = CourtesyForm.feminine;
    await apri(tester, chiamata: (i, r, c) async {
      if (c.containsKey('titolo')) {
        return jsonEncode({
          'titolo': 'Sei pronto a vedere chiaro',
          'responso': 'Sei pronto: la chiarezza che cerchi sulla tua strada '
              'e\' nel segno.',
        });
      }
      return modelloFinto(i, r, c);
    });
    await scegliEScrivi(
        tester, ViaMagica.bianca, 'Chiedo chiarezza sulla mia strada');
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .join('\n');
    expect(testi.contains('pronto'), isFalse,
        reason: 'il maschile del modello e\' arrivato a un profilo femminile');
    expect(formeDelGenere(testi).where((f) => !f.endsWith('a')), isEmpty);
  });

  group('Regola 21: il sigillo non e\' una bindrune', () {
    test('Il cammino non ha un asse verticale condiviso', () {
      final c = IntentionSigil.cammino('Chiedo chiarezza sulla mia strada');
      expect(c.length, greaterThan(3));
      final xs = c.map((p) => p.dx).toList();
      final minX = xs.reduce((a, b) => a < b ? a : b);
      final maxX = xs.reduce((a, b) => a > b ? a : b);
      expect(maxX - minX, greaterThan(0.3),
          reason: 'i punti stanno quasi sulla stessa verticale, come una '
              'bindrune: apertura ${(maxX - minX).toStringAsFixed(2)}');
    });

    test('I punti stanno su un cerchio, non su un segmento', () {
      final c = IntentionSigil.cammino('Apro il mio cuore al coraggio');
      for (final p in c) {
        final d = (p - const Offset(0.5, 0.5)).distance;
        expect(d, closeTo(0.38, 0.001),
            reason: 'un punto del cammino non sta sulla ruota');
      }
    });
  });
}

typedef ChiamataFinta = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);
