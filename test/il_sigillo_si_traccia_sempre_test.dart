// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/chat/user_profile.dart';
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

import 'cardinale_minimo.dart';

/// **"TRACCIA IL SIGILLO" SI TOCCA SEMPRE.** Ordine EV voce 02, il
/// fondatore: *"nel sigillo non posso fare click su "traccia il sigillo""*.
///
/// Sulla cattura del fondatore il pulsante era spento con la tastiera aperta
/// e il giorno scelto. Il codice lo spegneva finche' sopra c'era una forma
/// proposta da Calìgo, che con la tastiera aperta stava fuori vista. Si
/// misurano quattro situazioni con l'intenzione scritta e il giorno scelto,
/// tutte col cursore nel campo (la tastiera aperta): il tocco su "Traccia il
/// sigillo" deve tracciare un sigillo e chiudere la tastiera.
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
      'responso': 'Il segno e\' tracciato.',
    });
  }

  Future<LibroDeiSigilli> apri(WidgetTester tester) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final l = LibroDeiSigilli();
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
        home: MaestroScope(
            child: SigilloIntenzioneScreen(libro: l, chiamata: modelloFinto)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return l;
  }

  Future<void> scrivi(WidgetTester tester, String frase) async {
    await tester.tap(find.byKey(const Key('sigillo_via_bianca')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    // Il cursore nel campo: e' la tastiera aperta della cattura.
    await tester.tap(find.byKey(const Key('sigillo_campo')));
    await tester.enterText(find.byKey(const Key('sigillo_campo')), frase);
    await tester.pump();
  }

  Future<void> vediIlPulsante(WidgetTester tester) async {
    // La lista della scrittura nasce pigra: il pulsante sta in fondo.
    await tester.scrollUntilVisible(
        find.byKey(const Key('sigillo_traccia')), 200,
        scrollable: find
            .descendant(
                of: find.byKey(const Key('sigillo_scrittura')),
                matching: find.byType(Scrollable))
            .first);
    await tester.pump();
  }

  Future<void> tocca(WidgetTester tester) async {
    await vediIlPulsante(tester);
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  final aVuoto = <String>[];
  var situazioni = 0;

  Future<void> misura(WidgetTester tester, String nome, LibroDeiSigilli libro,
      {required bool tracciato}) async {
    situazioni++;
    // Il segno si scrive dopo la rivelazione: si lascia finire.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    final tastiera = tester.testTextInput.isVisible;
    print('IL SIGILLO SI TRACCIA SEMPRE, $nome: sigilli nel Libro '
        '${libro.tutti.length}, tastiera aperta $tastiera');
    if (tracciato && libro.tutti.length != 1) aVuoto.add('$nome: non traccia');
    if (tracciato && tastiera) aVuoto.add('$nome: la tastiera resta aperta');
  }

  testWidgets('la frase scritta, col cursore nel campo', (tester) async {
    final libro = await apri(tester);
    await scrivi(tester, 'Chiedo chiarezza sulla mia strada');
    await tocca(tester);
    await misura(tester, 'frase scritta', libro, tracciato: true);
  });

  testWidgets('con la forma di Calìgo chiesta e non usata', (tester) async {
    final libro = await apri(tester);
    await scrivi(tester, 'Voglio chiarezza');
    await tester.ensureVisible(find.byKey(const Key('sigillo_riformula')));
    await tester.tap(find.byKey(const Key('sigillo_riformula')));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.byKey(const Key('sigillo_proposta')), findsOneWidget,
        reason: 'la forma di Caligo non e\' comparsa: la prova non misura');
    await tester.tap(find.byKey(const Key('sigillo_campo')));
    await tester.pump();
    await tocca(tester);
    await misura(tester, 'forma proposta e non usata', libro, tracciato: true);
    if (libro.tutti.isNotEmpty &&
        libro.tutti.single.intenzione != 'Voglio chiarezza') {
      aVuoto.add('forma non usata: ha tracciato '
          '"${libro.tutti.single.intenzione}"');
    }
  });

  testWidgets('la frase su un terzo, poi la forma di Calìgo', (tester) async {
    final libro = await apri(tester);
    await scrivi(tester, 'Fai che lui si innamori di me');
    await tocca(tester);
    expect(find.byKey(const Key('sigillo_proposta')), findsOneWidget);
    await vediIlPulsante(tester);
    expect(libro.tutti, isEmpty,
        reason: 'la frase su un terzo si e\' '
            'tracciata');
    expect(
        find.descendant(
            of: find.byKey(const Key('sigillo_traccia')),
            matching: find.text('Traccia con la forma di Calìgo')),
        findsOneWidget);
    await tocca(tester);
    print('IL SIGILLO SI TRACCIA SEMPRE, frase su un terzo dopo il tocco: '
        '${find.byKey(const Key('sigillo_traccia')).evaluate().isEmpty ? 'il segno si traccia' : 'ancora la scrittura'}');
    await misura(tester, 'frase su un terzo', libro, tracciato: true);
    if (libro.tutti.isNotEmpty &&
        libro.tutti.single.intenzione.contains('innamori')) {
      aVuoto.add('frase su un terzo: tracciata cosi\' com\'era');
    }
  });

  testWidgets('il pulsante non e\' mai spento senza dire perche\'',
      (tester) async {
    await apri(tester);
    await scrivi(tester, '');
    final senza = tester.widget<FilledButton>(find.descendant(
        of: find.byKey(const Key('sigillo_traccia')),
        matching: find.byType(FilledButton)));
    situazioni++;
    if (senza.onPressed == null) {
      aVuoto.add('senza frase il pulsante e\' spento senza dire perche\'');
    }
    expect(
        find.descendant(
            of: find.byKey(const Key('sigillo_traccia')),
            matching: find.text('Scrivi la tua intenzione')),
        findsOneWidget);
  });

  test('i conti', () {
    cardinaleMinimo(situazioni, 4, cosa: 'situazioni guardate');
    print('IL SIGILLO SI TRACCIA SEMPRE: tocchi a vuoto ${aVuoto.length} su '
        '$situazioni situazioni $aVuoto');
    expect(aVuoto, isEmpty, reason: aVuoto.join('\n'));
  });
}
