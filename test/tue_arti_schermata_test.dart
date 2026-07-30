import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/santuario/widgets/tue_arti_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Le tue arti" a schermo: mai vuota, con la matita e col cuore.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ArtiPreferiteController> monta(
    WidgetTester tester, {
    double altezza = 2392,
    Maestro assegnato = Maestro.medora,
    bool carica = true,
  }) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferite = ArtiPreferiteController(maestroAssegnato: assegnato);
    if (carica) await preferite.carica();
    addTearDown(preferite.dispose);

    final aperte = <String>[];
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MaestroController(initial: ThemeKey.of(assegnato)),
        ),
        ChangeNotifierProvider<ArtiPreferiteController>.value(
            value: preferite),
        // Le bolle grandi poggiano su DepthCard, che legge il Quality Tier per
        // decidere ombre e comparsa: la prova deve fornirlo, come l'app.
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: SingleChildScrollView(
              child: TueArtiView(onOpen: aperte.add),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return preferite;
  }

  testWidgets('Non e\' mai vuota, nemmeno prima che il disco risponda',
      (tester) async {
    // carica: false vuol dire che il controller non ha ancora letto nulla, cioe'
    // il primissimo frame dell'app. Nemmeno li' si deve vedere uno scaffale
    // spoglio.
    await monta(tester, carica: false);
    expect(find.byKey(const Key('tue_arti_titolo')), findsOneWidget);
    expect(find.byType(InkWell), findsWidgets,
        reason: 'lo scaffale personale e\' comparso vuoto al primo frame');
  });

  testWidgets('Mostra le arti scelte, ciascuna apribile', (tester) async {
    final preferite = await monta(tester);
    for (final id in preferite.ids) {
      expect(find.byKey(Key('tua_arte_$id')), findsOneWidget,
          reason: 'l\'arte $id e\' nello scaffale ma non si vede');
    }
  });

  testWidgets('La matita apre l\'elenco completo a spunte', (tester) async {
    await monta(tester);
    await tester.tap(find.byKey(const Key('tue_arti_matita')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tue_arti_foglio')), findsOneWidget);
    // Tutte le arti vive sono elencate, non solo quelle scelte.
    for (final id in ArtiPreferiteController.selezionabili) {
      expect(find.byKey(Key('scelta_$id')), findsOneWidget,
          reason: 'l\'arte $id non compare nell\'elenco della matita');
    }
    // I tre Maestri fanno da intestazione.
    for (final m in Maestro.values) {
      expect(find.text(m.displayName), findsWidgets);
    }
  });

  testWidgets('Dalla matita si aggiunge e si toglie davvero', (tester) async {
    final preferite = await monta(tester);
    // Dal 30 luglio 2026 lo scaffale nasce con NOVE arti, tre per Maestro, e le
    // arti vive sono esattamente nove: nasce quindi completo, e la matita serve
    // prima a togliere e poi a rimettere. E' la conseguenza diretta della
    // decisione del fondatore, non un difetto: la prova la percorre nell'ordine
    // in cui la percorre una persona.
    final una = preferite.ids.first;

    await tester.tap(find.byKey(const Key('tue_arti_matita')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('scelta_$una')));
    await tester.pumpAndSettle();
    expect(preferite.contiene(una), isFalse,
        reason: 'togliendo la spunta l\'arte resta nello scaffale');

    await tester.tap(find.byKey(Key('scelta_$una')));
    await tester.pumpAndSettle();
    expect(preferite.contiene(una), isTrue,
        reason: 'la spunta non ha rimesso l\'arte');
  });

  testWidgets('La pressione lunga toglie l\'arte dallo scaffale',
      (tester) async {
    final preferite = await monta(tester);
    final primo = preferite.ids.first;
    final quante = preferite.ids.length;

    await tester.longPress(find.byKey(Key('tua_arte_$primo')));
    await tester.pumpAndSettle();

    expect(preferite.contiene(primo), isFalse,
        reason: 'la pressione lunga non ha tolto l\'arte');
    expect(preferite.ids.length, quante - 1);
    expect(find.byKey(const Key('esito_preferita')), findsOneWidget,
        reason: 'l\'arte e\' sparita senza dire nulla a chi l\'ha tolta');
  });

  testWidgets('Il cuore dentro l\'arte mette e toglie', (tester) async {
    final preferite = ArtiPreferiteController(maestroAssegnato: Maestro.caligo);
    await preferite.carica();
    addTearDown(preferite.dispose);
    // Lo scaffale nasce con tutte e nove le arti vive, quindi non ce n'e' una
    // fuori da aggiungere: si toglie e si rimette col cuore, che e' il gesto
    // che questa prova deve misurare.
    final id = preferite.ids.first;
    preferite.cambia(id);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<ArtiPreferiteController>.value(
            value: preferite),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: SogliaArte(
          id: id,
          maestro: Maestro.caligo,
          child: const Scaffold(body: Center(child: Text('un\'arte'))),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('cuore_$id')), findsOneWidget,
        reason: 'dentro l\'arte non c\'e\' nessun cuore');
    await tester.tap(find.byKey(Key('cuore_$id')));
    await tester.pumpAndSettle();
    expect(preferite.contiene(id), isTrue,
        reason: 'il cuore dentro l\'arte non l\'ha aggiunta');
  });

  test('Ogni arte viva ha il cuore, perche\' passa dalla soglia unica', () {
    // La rete vera: il cuore non e' messo a mano in nove schermate, e' nella
    // soglia. Se una rotta d'arte tornasse a usare il MaestroScope nudo,
    // quell'arte perderebbe il cuore in silenzio.
    const rotte = {
      'lib/features/horoscope/oroscopo_screen.dart': 'horoscope',
      'lib/features/synastry/sinastria_gallery_screen.dart': 'synastry_vip',
      'lib/features/tarot/stesa_tre_carte_screen.dart': 'tarot_spread_three',
      'lib/features/maestri/aura/archetype/archetype_test_screen.dart':
          'archetype_test',
      'lib/features/maestri/aura/face/face_constellation_screen.dart':
          'face_constellation',
      'lib/features/maestri/aura/meditation/meditation_screen.dart':
          'meditation',
      'lib/features/maestri/caligo/animal/guide_animal_screen.dart':
          'guide_animal',
      'lib/features/maestri/caligo/rune/rune_draw_screen.dart': 'rune_draw',
      'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart':
          'magic_sigil',
    };
    rotte.forEach((percorso, id) {
      final s = File(percorso).readAsStringSync();
      expect(s.contains('SogliaArte('), isTrue,
          reason: '$percorso non passa dalla soglia unica: l\'arte si apre '
              'senza cuore');
      expect(s.contains("id: '$id'"), isTrue,
          reason: '$percorso non dichiara il proprio identificativo, quindi il '
              'cuore non saprebbe cosa salvare');
    });
    // Tutte le arti selezionabili sono coperte.
    expect(rotte.values.toSet(),
        ArtiPreferiteController.selezionabili.toSet(),
        reason: 'un\'arta viva non ha una rotta con la soglia, oppure la soglia '
            'copre un\'arte che non e\' selezionabile');
  });
}
