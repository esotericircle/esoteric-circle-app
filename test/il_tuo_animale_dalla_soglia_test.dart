import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_corpus.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL TUO ANIMALE, DALLA SOGLIA DEL VIAGGIO.** Richiesta del fondatore, 20
/// ottobre 2026: *"Una volta che l'animale e' stato rivelato, devi aggiungere
/// un pulsante nella schermata di apertura della funzionalita', che apre un
/// popup che descrive le caratteristiche dell'animale rivelato"*, le stesse
/// della voce "Animale Guida" del Passport.
///
/// **Cosa misura**, sulla finestra vera del Realme (1080x2158 a densita' 3,
/// 221 pixel sopra la barra del titolo, letti con uiautomator): dopo la
/// rivelazione il pulsante sta sotto il nome dell'animale e sopra "Scendi",
/// e "Scendi" resta sopra la piega per tutti e dodici gli animali; toccato,
/// il pulsante apre il popup con le qualita' del corpus del Passport
/// (natura, dono, lezione, quando ti guida, invito), che si chiude; prima
/// della rivelazione il pulsante non c'e', perche' direbbe il nome.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const altezza = 2158 / 3;

  Future<void> apri(WidgetTester tester, int discese,
      {String nome = 'Lupo'}) async {
    tester.view.physicalSize = const Size(1080, 2158);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 221);
    tester.view.viewPadding = const FakeViewPadding(top: 221);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            key: ValueKey('$nome$discese'),
            userSign: Zodiac.sagittarius,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(discese, nome: nome),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'DOPO LA RIVELAZIONE IL PULSANTE STA SOTTO IL NOME E IL POPUP HA LE '
      'QUALITA\' DEL PASSPORT', (tester) async {
    await apri(tester, 5);
    final pulsante = find.byKey(const Key('viaggio_il_tuo_animale'));
    expect(pulsante, findsOneWidget,
        reason: 'dopo la rivelazione la soglia non ha il pulsante del tuo '
            'animale');
    final r = tester.getRect(pulsante);
    final nome =
        tester.getRect(find.byKey(const Key('viaggio_nome_riconosciuto')));
    expect(r.top, greaterThanOrEqualTo(nome.bottom - 0.5),
        reason: 'il pulsante non sta sotto il nome dell\'animale');
    expect(r.bottom, lessThanOrEqualTo(altezza),
        reason: 'il pulsante non si vede senza scorrere');
    await tester.tap(pulsante);
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('viaggio_qualita_dell_animale')), findsOneWidget,
        reason: 'il pulsante non apre il popup delle qualita\'');
    final corpus = GuideAnimalCorpus.di('Lupo');
    for (final (chiave, testo) in [
      ('animal_natura', corpus.natura),
      ('animal_dono', corpus.dono),
      ('animal_lezione', corpus.lezione),
      ('animal_quando', corpus.quando),
      ('animal_invito', corpus.invito),
    ]) {
      await tester.dragUntilVisible(find.byKey(Key(chiave)),
          find.byKey(const Key('viaggio_qualita_dell_animale')),
          const Offset(0, -200));
      await tester.pumpAndSettle();
      final testi = [
        for (final e in find
            .descendant(
                of: find.byKey(Key(chiave)), matching: find.byType(Text))
            .evaluate())
          (e.widget as Text).data,
      ];
      expect(testi, contains(testo),
          reason: 'nel popup manca $chiave col testo del Passport: $testi');
    }
    await tester.dragUntilVisible(
        find.byKey(const Key('viaggio_qualita_chiudi')),
        find.byKey(const Key('viaggio_qualita_dell_animale')),
        const Offset(0, -200));
    await tester.tap(find.byKey(const Key('viaggio_qualita_chiudi')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('viaggio_qualita_dell_animale')), findsNothing,
        reason: 'il popup non si chiude');
  });

  testWidgets(
      'SCENDI RESTA SOPRA LA PIEGA DEL REALME, per tutti e dodici gli '
      'animali, anche col pulsante nuovo', (tester) async {
    // La prima stesura, in una fascia in cima alla soglia, spingeva Scendi a
    // 690-746 in una finestra di 719; la seconda, con l'immagine a 280, a 735
    // col Cavallo.
    final sotto = <String>[];
    for (final a in AnimalCatalog.animals) {
      await apri(tester, 5, nome: a.name);
      final scendi =
          tester.getRect(find.byKey(const Key('viaggio_azione_scendi')));
      final bottone =
          tester.getRect(find.byKey(const Key('viaggio_il_tuo_animale')));
      if (scendi.bottom > altezza) {
        sotto.add('${a.name} ${scendi.bottom.toStringAsFixed(0)}');
      }
      expect(bottone.bottom, lessThanOrEqualTo(scendi.top),
          reason: '${a.name}: il pulsante non sta sopra Scendi');
    }
    expect(sotto, isEmpty,
        reason: 'Scendi finisce sotto la piega (${altezza.toStringAsFixed(0)}) '
            'per: ${sotto.join(', ')}');
  });

  testWidgets('PRIMA DELLA RIVELAZIONE IL PULSANTE NON C\'E\'', (tester) async {
    await apri(tester, 2);
    expect(find.byKey(const Key('viaggio_il_tuo_animale')), findsNothing,
        reason: 'prima della quarta il pulsante direbbe il nome dell\'animale');
  });
}
